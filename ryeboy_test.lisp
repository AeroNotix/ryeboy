(in-package :cl-user)
(defpackage ryeboy-test
  (:use :cl :prove :ryeboy))
(in-package :ryeboy-test)


(let ((conn (make-connection)))
  (ok (send-event conn (make-event)))
  (ok (send-events conn (make-event) (make-event) (make-event)))
  (let ((ht (make-hash-table :test #'equal)))
    (setf (gethash "foo" ht) "bar")
    (setf (gethash "foo1" ht) "bar")
    (setf (gethash "foo2" ht) "bar")
    (setf (gethash "foo3" ht) "bar")
    (setf (gethash "foo4" ht) "bar")
    (ok (send-events conn (make-event :attrs ht)))
    (ok (send-events conn
                     (make-event :attrs ht)
                     (make-event :attrs ht)
                     (make-event :attrs ht)
                     (make-event :attrs ht)))
    (let ((events (list (make-event :tags '("foo" "bar" "baz"))
                        (make-event :metric 123)
                        (make-event :metric 123.123)
                        (make-event :metric (float 123))
                        (make-event :ttl 0)
                        (make-event :ttl 102983102938109238)
                        (make-event :state "foobar")
                        (make-event :description "foobar")
                        (make-event :service "foobar")
                        (make-event :tags '("foo" "bar" "baz")
                                    :metric 123
                                    :ttl 0
                                    :state "foobar"
                                    :description "foooo"
                                    :service "fooobar"
                                    :host "fooo"
                                    :attrs ht))))
      (dolist (event events)
        (ok (send-event conn event)))))
  (is-error (query conn "totally doesn't make sense as a query") 'riemann-error-response))

(pass "Everything is A-OK")

(when (> (prove.suite:failed (prove.suite:current-suite)) 0)
  (sb-ext:exit :code -1))
