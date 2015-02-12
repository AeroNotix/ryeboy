(in-package :ryeboy)


(defgeneric set-metric (event metric)
  (:documentation "Set the metric type on the event"))

(defgeneric set-attributes (event attributes)
  (:documentation "Set the attributes on the event"))

(defmethod set-metric ((event com.aphyr.riemann:event) (metric integer))
  (setf (com.aphyr.riemann:metric-sint64 event) metric)
  event)

(defmethod set-metric ((event com.aphyr.riemann:event) (metric float))
  (setf (com.aphyr.riemann:metric-f event) metric)
  event)

(defmethod set-metric ((event com.aphyr.riemann:event) (metric double-float))
  (setf (com.aphyr.riemann:metric-d event) metric)
  event)

(defmethod set-attributes ((event com.aphyr.riemann:event) (attributes hash-table))
  )

(defun thing->bytes (thing)
  (let* ((size (pb:octet-size thing))
         (buffer (make-array size :element-type '(unsigned-byte 8))))
    (pb:serialize thing buffer 0 size)
    buffer))

(defun bytes->event (bytes)
  (let ((e (make-instance 'com.aphyr.riemann:event)))
    (pb:merge-from-array e bytes 0 (length bytes))
    e))

(defun make-event (&key
                     (time (get-unix-time))
                     (metric 0)
                     (host (machine-instance))
                     state service description tags ttl attrs)
  (let ((event (make-instance 'com.aphyr.riemann:event)))
    (setf (com.aphyr.riemann:time event) time)
    (setf (com.aphyr.riemann:host event) (protocol-buffer:string-field host))
    (when state
      (setf (com.aphyr.riemann:state event) (protocol-buffer:string-field state)))
    (when service
      (setf (com.aphyr.riemann:service event) (protocol-buffer:string-field service)))
    (when description
      (setf (com.aphyr.riemann:description event) (protocol-buffer:string-field description)))
    (when tags
      (setf (com.aphyr.riemann:tags event)
            (map 'vector #'protocol-buffer:string-field tags)))
    (when ttl
      (setf (com.aphyr.riemann:ttl event) (float ttl)))
    (when attrs
      (setf (com.aphyr.riemann:attributes event) attrs))
    (when metric
      (set-metric event (float metric))
      (set-metric event metric))
    event))
