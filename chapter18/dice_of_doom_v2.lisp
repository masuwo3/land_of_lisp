(load "dice_of_doom_v1.lisp")
(load "lazy.lisp")

(defparameter *board-size* 4)
(defparameter *board-hexnum* (* *board-size* *board-size*))

(defun add-passing-move (board player spare-dice first-move moves)
  (if first-move
      moves
      (lazy-cons (list nil
                       (game-tree (add-new-dice board player
                                                (1- spare-dice))
                                  (mod (1+ player) *num-players*)
                                  0
                                  t))
                 moves)))

(defun attacking-moves (board cur-player spare-dice)
  (labels ((player (pos)
                   (car (aref board pos)))
           (dice (pos)
                 (cadr (aref board pos))))
          (lazy-mapcan 
            (lambda (src)
              (if (eq (player src) cur-player)
                  (lazy-mapcan 
                    (lambda (dst)
                      (if (and (not (eq (player dst) 
                                        cur-player))
                               (> (dice src) (dice dst)))
                          (make-lazy
                            (list (list (list src dst)
                                        (game-tree (board-attack board 
                                                                 cur-player
                                                                 src 
                                                                 dst 
                                                                 (dice src))
                                                   cur-player
                                                   (+ spare-dice (dice dst))
                                                   nil))))
                          (lazy-nil)))
                    (make-lazy (neighbors src)))
                  (lazy-nil)))
            (make-lazy (loop for n below *board-hexnum*
                             collect n)))))