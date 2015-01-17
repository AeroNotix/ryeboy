(in-package :ryeboy)


(defun make-event (&key time state service host description tags ttl attrs metric)
  (let ((event (make-instance 'com.aphyr.riemann:event)))
    (when time
      (setf (com.aphyr.riemann:time event) time))
    (when state
      (setf (state event) (protocol-buffer:string-field state)))
    (when service
      (setf (service event) (protocol-buffer:string-field service)))
    (when host
      (setf (host event) (protocol-buffer:string-field host)))
    (when description
      (setf (description event) (protocol-buffer:string-field description)))
    (when tags
      (setf (tags event) tags))
    (if ttl
        (setf (ttl event) (float ttl))
        (setf (ttl event) 0.0))
    (when attrs
      (setf (attributes event) attrs))
    (when metric
      (set-metric event metric))
    event))

(defgeneric set-metric (event metric)
  (:documentation "Set the metric type on the event"))

(defmethod set-metric ((event com.aphyr.riemann:event) (metric integer))
  (setf (metric-sint64 event) metric)
  event)

(defmethod set-metric ((event com.aphyr.riemann:event) (metric float))
  (setf (metric-f event) metric)
  event)

(defmethod set-metric ((event com.aphyr.riemann:event) (metric double-float))
  (setf (metric-d event) metric)
  event)

(defun thing->bytes (thing)
  (let* ((size (pb:octet-size thing))
         (buffer (make-array size :element-type '(unsigned-byte 8))))
    (pb:serialize thing buffer 0 size)
    buffer))

(defun bytes->event (bytes)
  (let ((e (make-instance 'com.aphyr.riemann:event)))
    (pb:merge-from-array e bytes 0 (length bytes))
    e))
