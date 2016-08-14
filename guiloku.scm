(use-modules (sly)
             (sly signal)
             (sly math vector)
             (sly math rect)
             (sly render camera)
             (sly render color)
             (sly render sprite)
             (sly input mouse))

;; Game definition
(define (init-rows size)
  (let ((col (make-vector size 0)))
    (make-vector size (vector-copy col))))

(define  (init-game size)
  (list (cons "size" size)
        (cons "turn" 0)
        (cons "board" (init-rows size))))

(define (mark-cell row col next-player game)
  (let ((new-game (copy-tree game))
        (success #t))
    (let ((sel-row (vector-ref (cdr (list-ref new-game 2)) row))
          (player (assoc-ref new-game "turn")))
      (display player)
      (newline)
      (if (= (vector-ref sel-row col) 0)
          (begin (vector-set! sel-row col player)
                 (set! new-game (assoc-set! new-game "turn" next-player)))
          (set! success #f)))
    (values new-game success)))

;; The UI
(sly-init)

(define resolution (vector2 640 480))
(define cell-size 32)

(define go-white
  (load-sprite "images/go_white.png"))

(define go-black
  (load-sprite "images/go_black.png"))

(define camera
  (2d-camera #:area (make-rect (vector2 0 0) resolution)
             #:clear-color black))

(define-signal scene
  (with-camera camera
               (move (vector2 320 240) (render-sprite go-white))))

;; bootstrap it all
(start-sly-repl)

(add-hook! window-close-hook stop-game-loop)

(define game-window (make-window #:title "Guiloku" #:resolution resolution))

(with-window (make-window #:title "Guiloku"
                          #:resolution resolution)
             (run-game-loop scene))
