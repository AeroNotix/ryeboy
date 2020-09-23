;; -*- mode: common-lisp -*-
(defsystem :ryeboy
  :version "0.0.1"
  :author "Aaron France aaron.l.france@gmail.com"
  :description "Riemann client"
  :licence "BSD"
  :defsystem-depends-on (protobuf)
  :serial t
  :components ((:file "packages")
               (:protobuf-source-file "proto")
               (:file "binary")
               (:file "time")
               (:file "ryeboy-protocol")
               (:file "ryeboy-conn"))
  :depends-on (:alexandria
               :usocket)
  :in-order-to ((test-op (test-op ryeboy/test))))

(defsystem :ryeboy/test
  :version "0.0.1"
  :author "Aaron France aaron.l.france@gmail.com"
  :description "Riemann client test suite"
  :licence "BSD"
  :depends-on (:ryeboy :prove)
  :defsystem-depends-on (:prove-asdf)
  :components
  ((:test-file "ryeboy_test"))
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run) :prove) c)))
