;; Rabbit stream cipher 
;; written by Martin Boesgaard, Mette Vesterager, Thomas Christensen and Erik Zenner
;; public domain
;; key is 128 bit == 16 characters
;; iv is 64 bit = 8 characters

;; Based on lambdanative rabbit lib, ported to Chicken Scheme by Ivan Raikov

(module rabbit

        (rabbit-debuglevel
         rabbit-make
         rabbit-destroy!
         rabbit-encode!
         rabbit-decode!)

	(import scheme chicken foreign)
        (import (only extras printf))

        (define rabbit-debuglevel (make-parameter 0))
        (define (rabbit-log level . x)
          (if (>= (rabbit-debuglevel) level) (apply printf (append (list "rabbit: ") x))))


#>
#define C_bytevector_length(x)      (C_header_size(x))
#include "rabbitlib.c"
<#


(define (rabbit-make key)  ;; key must be at least 24 bytes
  (rabbit-log 1 "rabbit-make " (blob->string key))
  ((foreign-safe-lambda* nonnull-c-pointer ((scheme-object key))
#<<END
     int len; void* keydata, *result;
     len   = C_bytevector_length(key);
     keydata  = C_c_bytevector (key);
     result = (void *)_rabbit_make(keydata, len);
     C_return (result);
END
   ) key)
  )


(define (rabbit-destroy! ctx)
  (rabbit-log 1 "rabbit-destroy " ctx)
  ((foreign-lambda* void ((nonnull-c-pointer ctx))
#<<END
     _rabbit_destroy(ctx);
END
   ) ctx)
)

(define (rabbit-encode! ctx v)
  (rabbit-log 2 "rabbit-encode/decode " ctx " " v)
  (if (blob? v) 
      (begin
        ((foreign-lambda* void ((nonnull-c-pointer ctx) (scheme-object v))
#<<EOF
          int len; void* data;
          data  = C_c_bytevector (v);
          len   = C_bytevector_length(v);
          _rabbit_encode(ctx,data,len);
EOF
) ctx v)
        v)
      #f))

(define rabbit-decode! rabbit-encode!)

)
