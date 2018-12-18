(import scheme (chicken base) (chicken random) (chicken blob) rabbit test)
                       
(test-group "rabbit 1000 random vectors" 
  (let loop ((n 1000))
    (test-assert
      (if (= n 0) #t 
          (if (let* (
                     (keylen (+ (pseudo-random-integer 10) 24))
                     (key (random-bytes (make-blob keylen)))
                     (datalen (pseudo-random-integer 100000))
                     (data (random-bytes (make-blob datalen)))
                     (ctx (make-context key))
                     )
                (let ((res (not (equal? data (decode! ctx (encode! ctx data))))))
                  (destroy-context! ctx)
                  res))
              #f 
              (loop (- n 1)))))))

;; eof
