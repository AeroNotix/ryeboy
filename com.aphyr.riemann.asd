(defsystem #:com.aphyr.riemann
  :version "0.0.1"
  :description "Riemann protobuf specification"
  :licence "BSD"
  :components ((:file "proto"))
  :depends-on (:protobuf))
