(in-package :ryeboy)


(defun write-sized (value n stream)
  (let ((value (ldb (byte n 0) value)))
    (loop for i from (/ n 8) downto 1
       do
         (write-byte (ldb (byte 8 (* (1- i) 8)) value) stream))))

(defun read-sized (n stream &optional (signed? nil))
  (let ((unsigned-value 0)
        (byte-size (/ n 8)))
    (dotimes (i byte-size)
      (setf unsigned-value (+ (* unsigned-value #x100)
                              (read-byte stream))))
    (if signed?
        (if (>= unsigned-value (ash 1 (1- (* 8 byte-size))))
            (- unsigned-value (ash 1 (* 8 byte-size)))
            unsigned-value)
        unsigned-value)))

(defmacro define-binary-type (name size)
  (labels ((create-symbol (fmt name)
             (intern (format nil fmt name) 'ryeboy)))
    (let ((value (gensym "value"))
          (stream (gensym "stream"))
          (write-fun-name (create-symbol "WRITE-~A" name))
          (read-fun-name (create-symbol "READ-~A" name)))
      `(progn
         (defun ,write-fun-name (,value ,stream)
           (write-sized ,value ,size ,stream))
         (defun ,read-fun-name (,stream &key (signed? nil))
           (read-sized ,size ,stream signed?))))))

(define-binary-type int 32)
