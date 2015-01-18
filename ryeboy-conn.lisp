(in-package :ryeboy)


(defun make-connection (&key (connection-type :tcp) (host "localhost") (port 5555))
  (usocket:socket-stream
   (usocket:socket-connect host port
                           :element-type '(unsigned-byte 8)
                           :protocol (if (eq :tcp connection-type)
                                         :stream :datagram))))
