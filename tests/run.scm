(use rabbit srfi-4 test)

(randomize)

(define (random-blob n)
  (let ((v (make-u8vector n)))
    (let loop ((n n))
      (if (> n 0)
          (begin 
            (u8vector-set! v (- n 1) (random 255))
            (loop (- n 1)))
          (u8vector->blob v)))
    ))
                       
(test-group "rabbit 1000 random vectors" 
  (let loop ((n 1000))
    (test-assert
      (if (= n 0) #t 
          (if (let* (
                     (keylen (+ (random 10) 24))
                     (key (random-blob keylen))
                     (datalen (random 100000))
                     (data (random-blob datalen))
                     (ctx (rabbit-make key))
                     )
                (let ((res (not (equal? data (rabbit-decode! ctx (rabbit-encode! ctx data))))))
                  (rabbit-destroy! ctx)
                  res))
              #f 
              (loop (- n 1)))))))

;; eof
