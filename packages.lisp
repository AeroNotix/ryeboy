(defpackage ryeboy
  (:use #:cl)
  (:export
   #:make-connection
   #:make-event
   #:send-event
   #:send-events
   #:query
   #:riemann-error-response
   ))
