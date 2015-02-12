(in-package :ryeboy)


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

(defun send-event (conn event)
  ;; TODO: UDP connections aren't length prefixed, namsay
  (let* ((msg (make-msg event))
         (encoded (thing->bytes event)))
    (write-int (length encoded) conn)
    (write-sequence (thing->bytes msg) conn)
    (finish-output conn)
    (values)))
