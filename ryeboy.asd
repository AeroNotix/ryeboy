;; -*- mode: common-lisp -*-
(defsystem :ryeboy
  :version "0.0.1"
  :author "Aaron France aaron.l.france@gmail.com"
  :description "Riemann client"
  :licence "BSD"
  :serial t
  :components ((:file "packages")
               (:file "proto")
               (:file "ryeboy-conn")
               (:file "ryeboy"))
  :depends-on (:alexandria
               :protobuf
               :usocket))
