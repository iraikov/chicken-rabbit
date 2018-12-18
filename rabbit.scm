;; Rabbit stream cipher 
;; written by Martin Boesgaard, Mette Vesterager, Thomas Christensen and Erik Zenner
;; public domain
;; key is 128 bit == 16 characters
;; iv is 64 bit = 8 characters

;; Based on lambdanative rabbit lib, ported to Chicken Scheme by Ivan Raikov

(module rabbit

        (debuglevel make-context destroy-context! encode! decode!)

	(import scheme (chicken base) (chicken foreign) (chicken blob) (chicken format))

        (define debuglevel (make-parameter 0))
        (define (logger level . x)
          (if (>= (debuglevel) level) (apply printf (append (list "rabbit: ") x))))


#>
#define C_bytevector_length(x)      (C_header_size(x))
#include "rabbitlib.c"
<#


(define (make-context key)  ;; key must be at least 24 bytes
  (logger 1 "make-context " (blob->string key))
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


(define (destroy-context! ctx)
  (logger 1 "destroy-context " ctx)
  ((foreign-lambda* void ((nonnull-c-pointer ctx))
#<<END
     _rabbit_destroy(ctx);
END
   ) ctx)
)

(define (encode! ctx v)
  (logger 2 "encode/decode " ctx " " v)
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

(define decode! encode!)

)
