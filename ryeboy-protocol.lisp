(in-package :ryeboy)


(defgeneric set-metric (event metric)
  (:documentation "Set the metric type on the event"))

(defgeneric set-attributes (event attributes)
  (:documentation "Set the attributes on the event"))

(defmethod set-metric ((event io.riemann.riemann:event) (metric integer))
  (setf (io.riemann.riemann:metric-sint64 event) metric)
  event)

(defmethod set-metric ((event io.riemann.riemann:event) (metric float))
  (setf (io.riemann.riemann:metric-f event) metric)
  event)

(defmethod set-metric ((event io.riemann.riemann:event) (metric double-float))
  (setf (io.riemann.riemann:metric-d event) metric)
  event)

(defun encode-attributes (kv)
  (let* ((k (car kv))
         (v (cdr kv))
         (attr (make-instance 'io.riemann.riemann:attribute)))
    (setf (io.riemann.riemann:key attr) (protocol-buffer:string-field k))
    (setf (io.riemann.riemann:value attr) (protocol-buffer:string-field v))
    attr))

(defmethod set-attributes ((event io.riemann.riemann:event) (attributes hash-table))
  (setf (io.riemann.riemann:attributes event)
        (map '(vector io.riemann.riemann:attribute)
             #'encode-attributes
             (alexandria:hash-table-alist attributes))))

(defun thing->bytes (thing)
  (let* ((size (pb:octet-size thing))
         (buffer (make-array size :element-type '(unsigned-byte 8))))
    (pb:serialize thing buffer 0 size)
    buffer))

;; Make this a macro/defgeneric
(defun bytes->msg (bytes)
  (let ((e (make-instance 'io.riemann.riemann:msg)))
    (pb:merge-from-array e bytes 0 (length bytes))
    e))

;; Make this a macro/defgeneric
(defun bytes->event (bytes)
  (let ((e (make-instance 'io.riemann.riemann:event)))
    (pb:merge-from-array e bytes 0 (length bytes))
    e))

(defun make-event (&key
                     (time (get-unix-time))
                     (metric 0)
                     (host (machine-instance))
                     state service description tags ttl attrs)
  (let ((event (make-instance 'io.riemann.riemann:event)))
    (setf (io.riemann.riemann:time event) time)
    (setf (io.riemann.riemann:host event) (protocol-buffer:string-field host))
    (when state
      (setf (io.riemann.riemann:state event) (protocol-buffer:string-field state)))
    (when service
      (setf (io.riemann.riemann:service event) (protocol-buffer:string-field service)))
    (when description
      (setf (io.riemann.riemann:description event) (protocol-buffer:string-field description)))
    (when tags
      (setf (io.riemann.riemann:tags event)
            (map 'vector #'protocol-buffer:string-field tags)))
    (when ttl
      (setf (io.riemann.riemann:ttl event) (float ttl)))
    (when attrs
      (set-attributes event attrs))
    (when metric
      (set-metric event (float metric))
      (set-metric event metric))
    event))

(defun make-query (query-string)
  (let ((query (make-instance 'io.riemann.riemann:query)))
    (setf (io.riemann.riemann:string query) (protocol-buffer:string-field query-string))
    query))
