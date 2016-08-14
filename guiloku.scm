(define (init-rows size)
  (let ((col (make-vector size 0)))
    (make-vector size (vector-copy col))))

(define  (init-game size)
  (list (cons "size" size)
        (cons "turn" 0)
        (cons "board" (init-rows size))))

;; TODO: Update so that this does a deep-copy
;;       The vectors are not copied here, which is a problem
(define (mark-cell row col player game)
  (let ((cell (cons col player))
        (new-game (list-copy game)))
    (let ((sel-row (vector-ref (cdr (list-ref new-game 2)) row)))
      (vector-set! sel-row col player))
    new-game))
