(use-modules (sly)
             (sly signal)
             (sly math vector)
             (sly math rect)
             (sly render camera)
             (sly render color)
             (sly render sprite)
             (sly input mouse)
             (srfi srfi-26)
             (ice-9 match))

;; Game definition
(define (init-rows size)
  (let ((col (make-vector size 0)))
    (make-vector size (vector-copy col))))

(define  (init-game size starting-player)
  (list (cons "size" size)
        (cons "turn" starting-player)
        (cons "board" (init-rows size))))

(define (get-next-player game)
  (let ((curr (assoc-ref game "turn")))
    (cond
     ((= curr 0) 1)
     ((= curr 1) 2)
     ((= curr 2) 1))))

(define (mark-cell position game)
  (let ((new-game (copy-tree game))
        (success #t)
        (row (vy position))
        (col (vx position)))
    (if (or (< row 0)
            (< col 0))
        (set! success #f)
        (let ((sel-row (vector-ref (cdr (list-ref new-game 2)) row))
              (player (assoc-ref new-game "turn")))
          (if (= (vector-ref sel-row col) 0)
              (let ((next-player (get-next-player new-game)))
                (vector-set! sel-row col player)
                (set! new-game (assoc-set! new-game "turn" next-player)))
              (set! success #f))))
    (values new-game success)))

;; The UI
(sly-init)

(define resolution (vector2 640 480))
(define cell-size 32)

(define-signal board-size 15)

;; Lifted out of sly/examples/mines.scm
(define-signal center-position
  (signal-let ((board-size board-size))
              (v- (v* 1/2 resolution)
                  (/ (* board-size cell-size) 2))))

;; Lifted out of sly/examples/mines.scm
(define (enumerate-map proc lst)
  (let ((ls (vector->list (assoc-ref (signal-ref lst) "board"))))
    (define (iter k ls)
      (match ls
        (() '())
        ((x . rest)
         (cons (proc x k) (iter (1+ k) rest)))))

    (iter 0 lst)))

(define go-white
  (load-sprite "images/go_white.png"))

(define go-black
  (load-sprite "images/go_black.png"))

(define cell-base-sprite
  (load-sprite "images/base.png"))

(define (cell-overlay-sprite cell)
  (cond
        ((= cell 1) go-black)
        ((= cell 2) go-white)
        (else #f)))

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
   (signal-map (cut list 'place-stone <>) stone-pos)))

(define (start-game)
  (init-game 15 1))

(define-signal board
  (signal-fold (lambda (op board)
                 (match op
                   ('null board)
                   ('restart (start-game))
                   (('place-stone p) (mark-cell p board))))
               (start-game)
               command))


(define render-cell
  (let ((offset (vector2 (/ cell-size 2) (/ cell-size 2))))
    (lambda (cell)
      (render-begin
       (render-sprite cell-base-sprite)
       (let ((overlay (cell-overlay-sprite cell)))
         (if overlay
             (move offset (render-sprite overlay))
             render-nothing))))))

(define-signal board-view
  (signal-let ((board board))
              (define (render-column cell x)
                (move (vector2 (* x cell-size) 0)
                      (render-cell cell)))

              (define (render-row row y)
                (move (vector2 0 (* y cell-size))
                      (list->renderer (enumerate-map render-column row))))

              (list->renderer (enumerate-map render-row (make-signal board)))))

(define camera
  (2d-camera #:area (make-rect (vector2 0 0) resolution)
             #:clear-color black))

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
