(in-package :ryeboy)


(defun make-connection (&key (connection-type :tcp) (host "localhost") (port 5555))
  (usocket:socket-stream
   (usocket:socket-connect host port
                           :element-type '(unsigned-byte 8)
                           :protocol (if (eq :tcp connection-type)
                                         :stream :datagram))))

(defun send-event (conn event)
  ;; TODO: UDP connections aren't length prefixed, namsay
  (let ((encoded (thing->bytes event)))
    (write-int (length encoded) conn)
    (write-sequence (thing->bytes event) conn)
    (finish-output conn)
    (values)))
