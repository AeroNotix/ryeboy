;; -*- mode: common-lisp -*-
(defsystem :ryeboy
  :version "0.0.1"
  :author "Aaron France aaron.l.france@gmail.com"
  :description "Riemann client"
  :licence "BSD"
  :serial t
  :components ((:file "packages")
               (:file "proto")
               (:file "binary")
               (:file "time")
               (:file "ryeboy-protocol")
               (:file "ryeboy-conn"))
  :depends-on (:alexandria
               :protobuf
               :usocket)
  :in-order-to ((test-op (test-op ryeboy-test))))

(defsystem :ryeboy-test
  :depends-on (:ryeboy :prove)
  :defsystem-depends-on (:prove-asdf)
  :components
  ((:test-file "ryeboy_test"))
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run) :prove) c)))
