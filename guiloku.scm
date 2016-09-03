(define-module (guiloku))

(use-modules (sly)
             (sly game)
             (sly signal)
             (sly math vector)
             (sly math rect)
             (sly render camera)
             (sly render color)
             (sly render font)
             (sly render sprite)
             (sly input mouse)
             (srfi srfi-1)
             (srfi srfi-9)
             (srfi srfi-26)
             (ice-9 match))

;; Game definition
(define-record-type <cell>
  (make-cell owned? position)
  cell?
  (owned? owned? set-owned!)
  (position position))

;; The UI
(sly-init)
(enable-fonts)

(define font (load-default-font))

(define resolution (vector2 800 600))
(define cell-size 32)

(define-signal player1-owned (list))
(define-signal player2-owned (list))
(define-signal board-size 3)

(define (is-correct-range row col size)
  (and (>= row 0)
       (>= col 0)
       (< row size)
       (< col size)))

(define (mark-cell position board turn)
  ;(format #t "in mark-cell: ~%~a,~%~a,~%~a,~%" position board turn)
  (signal-let ((size board-size)
               (owner turn))
              (let ((row (vy position))
                    (col (vx position))
                    (board board))
                (if (is-correct-range row col size)
                    (let ((cell (make-cell* col row owner))
                          (orig-cell (list-ref (list-ref board row) col)))
                      (if (not (owned? orig-cell))
                          (begin (format #t "marking cell...~%")
                                 (add-cell-to-player cell owner)
                                 (update-player-turn position owner)
                                 (format #t "Well, we are here...~%")
                                 (list-replace board row
                                               (list-replace
                                                (list-ref board row) col cell)))
                          board))
                    board))))

;; Lifted out of sly/examples/mines.scm
(define (list-replace lst k value)
  ;(format #t "list-replace ==> lst: ~a~%" lst)
  (append (take lst k) (cons value (drop lst (1+ k)))))

;; Lifted out of sly/examples/mines.scm
(define-signal center-position
  (signal-let ((board-size board-size))
              (v- (v* 1/2 resolution)
                  (/ (* board-size cell-size) 2))))

;; Lifted out of sly/examples/mines.scm
(define (enumerate-map proc lst)
  (define (iter k ls)
    (match ls
      (() '())
      ((x . rest)
       (cons (proc x k) (iter (1+ k) rest)))))
  (iter 0 lst))

(define go-white
  (load-sprite "images/go_white.png"))

(define go-black
  (load-sprite "images/go_black.png"))

(define cell-base-sprite
  (load-sprite "images/base.png"))

(define (cell-overlay-sprite cell)
  (let ((sprite #nil))
    (cond
     ((member cell (signal-ref player1-owned)) (set! sprite go-black))
     ((member cell (signal-ref player2-owned)) (set! sprite go-white)))
    sprite))

(define (add-cell-to-player cell owner)
  ;(format #t "cell: ~a~%owner: ~a~%" cell owner)
  (let ((sig-to-update (cond
                        ((eq? owner 'player1)
                         (begin (format #t "for player1-owned~%")
                                player1-owned))
                        ((eq? owner 'player2)
                         (begin (format #t "for player2-owned~%")
                                player2-owned)))))
    (signal-set! sig-to-update (append (signal-ref sig-to-update) (list cell)))))

(define (make-cell* x y owner)
  (let* ((owned (not (null? owner)))
         (cell (make-cell owned (vector2 x y))))
    cell))

(define (init-row size y)
  (list-tabulate size (lambda (x)
                        (make-cell* x y #nil))))

(define (make-board size)
  (list-tabulate size (lambda (y) (init-row size y))))

(define-signal cell-position
  (signal-let ((p mouse-position)
               (size board-size)
               (center center-position))
              (vmap floor (v* (v- p center) (/ 1 cell-size)))))

(define-signal stone-pos
  (chain mouse-last-up
         (signal-filter (cut eq? 'left <>) #f)
         (signal-sample-on cell-position)))

(define-signal command
  (signal-merge
   (make-signal 'null)
   (signal-map (cut list 'place-stone <>) stone-pos)
   (signal-constant 'restart (key-down? 'n))))

(define (start-game)
  (make-board (signal-ref board-size)))

(define (init-player-turn)
  (make-signal 'player1))

(define (update-player-turn position pturn)
  ;;(format #t "u-p-t pturn: ~a~%board ~a~%" pturn board)
  (signal-let ((board board)
               (size board-size))
              (let ((row (vy position))
                    (col (vx position))
                    (turn pturn))
                ;;(format #t "~%update-player-turn: row ~a, col ~a, pturn ~a, turn ~a, size ~a~%board ~a~%" row col pturn turn size board)
                (if (is-correct-range row col size)
                    (let ((cell (list-ref (list-ref board row) col)))
                      ;;(format #t "u-p-t: => if => let~%")
                      (if (owned? cell)
                          (begin (format #t "&&&~%")
                                 turn)
                          (cond
                           ((eq? turn 'player1) (begin (format #t "returning 'player2~%")
                                                       'player2))
                           ((eq? turn 'player2) (begin (format #t "returning 'player1~%")
                                                       'player1)))))
                    turn))))

(define-signal player-turn 'player1)

(define-signal board
  (signal-fold (lambda (op board)
                 (match op
                   ('null board)
                   ('restart (start-game))
                   (('place-stone p) (mark-cell p board player-turn))))
               (start-game)
               command))

(define render-cell
  (let ((offset (vector2 (/ cell-size 2) (/ cell-size 2))))
    (lambda (cell)
      (render-begin
       (move offset (render-sprite cell-base-sprite))
       (let ((overlay (cell-overlay-sprite cell)))
         (if overlay
             (move offset (render-sprite overlay))
             render-nothing))))))

(define-signal board-view
  (signal-let ((bd board))
              (define (render-column cell x)
                (move (vector2 (* x cell-size) 0)
                      (render-cell cell)))

              (define (render-row row y)
                (format #t "render-row ==> ~a~%" row)
                (move (vector2 0 (* y cell-size))
                      (list->renderer (enumerate-map render-column row))))

              (list->renderer (enumerate-map render-row bd))))

(define camera
  (2d-camera #:area (make-rect (vector2 0 0) resolution)
             #:clear-color black))

(define (render-message message)
  (move (vector2 (/ (vx resolution) 2)
                 (- (vy resolution) 64))
        (render-sprite
         (make-label font message #:anchor 'center))))

(define-signal status-message
  (let ((player1-wins (render-message "GAME OVER - Player 1 wins! Press N to play again"))
        (player2-wins (render-message "GAME OVER - Player 2 wins! Press N to play again"))
        (offset (vector2 (/ cell-size 2) (/ cell-size 2))))
    (move offset player1-wins)))

(define-signal scene
  (signal-let ((view board-view)
               (status status-message)
               (center center-position))
              (with-camera camera
                           (render-begin
                            status
                            (move center view)))))

;; bootstrap it all
(start-sly-repl)

(add-hook! window-close-hook stop-game-loop)

(define game-window (make-window #:title "Guiloku" #:resolution resolution))

(with-window (make-window #:title "Guiloku"
                          #:resolution resolution)
             (run-game-loop scene))
