(in-package :ryeboy)


(define-condition riemann-error-response ()
  ((error-type :initarg :name :reader error-type)
   (error-msg  :initarg :msg  :reader error-msg))
  (:report
   (lambda (condition stream)
     (format stream
             "Error ~:(~A~) ~A"
             (error-type condition)
             (error-msg condition)))))

(defun make-connection (&key (connection-type :tcp) (host "localhost") (port 5555))
  (usocket:socket-stream
   (usocket:socket-connect host port
                           :element-type '(unsigned-byte 8)
                           :protocol (if (eq :tcp connection-type)
                                         :stream :datagram))))

(defun make-msg (&rest events)
  (let* ((msg (make-instance 'com.aphyr.riemann:msg))
         (events (make-array (list (length events))
                             :element-type 'com.aphyr.riemann:event
                             :initial-contents events)))
    (setf (com.aphyr.riemann:events msg) events)
    msg))

(defun handle-response (response request-type)
  (if (eq :events request-type)
      T
      (com.aphyr.riemann:events response)))

(defun read-reply (conn request-type)
  (let* ((wire-size (read-int conn))
         (buf (make-array wire-size :element-type '(unsigned-byte 8))))
    (read-sequence buf conn)
    (let ((response (bytes->msg buf)))
      (when (com.aphyr.riemann:has-ok response)
        (if (com.aphyr.riemann:ok response)
            (handle-response response request-type)
            (error (make-instance 'riemann-error-response
                                  :msg (protocol-buffer:string-value
                                        (com.aphyr.riemann:error response))
                                  :name request-type)))))))

(defun send-msg (conn msg req-type)
  (let ((encoded (thing->bytes msg)))
    (write-int (length encoded) conn)
    (write-sequence encoded conn)
    (finish-output conn)
    (read-reply conn req-type)))

(defun send-event (conn event)
  ;; TODO: UDP connections aren't length prefixed, namsay
  (let ((msg (make-msg event)))
    (send-msg conn msg :events)))

(defun send-events (conn &rest events)
  (let ((msg (apply #'make-msg events)))
    (send-msg conn msg :events)))

(defun query (conn query-string)
  (let* ((msg (make-instance 'com.aphyr.riemann:msg))
         (query (make-query query-string)))
    (setf (com.aphyr.riemann:query msg) query)
    (send-msg conn msg :query)))
