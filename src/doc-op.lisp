;;;;; -*- mode: common-lisp;   common-lisp-style: modern;    coding: utf-8; -*-
;;;;
;;;; deoxabyte asdf extensions for cldoc 

(in-package :cldoc)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CLDOC ASDF extension
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defclass cldoc (asdf:static-file)
  ((target-system :initform nil
                  :initarg :target-system
                  :accessor target-system
                  :documentation "The system to be documented e.g. :cl-system-utilities"))
  (:documentation "An ASDF component that represents a CLDOC configuration"))


(defclass doc-op (asdf:operation)
  ()
  (:documentation "An ASDF operation that extracts docstring
  documentation from Lisp code using CLDOC."))


(defmethod asdf:source-file-type ((c cldoc) (s asdf:module))
  ;; The cldoc pathname is a directory, so has pathname-type NIL
  nil)


(defmethod asdf:operation-done-p ((op doc-op) (c cldoc))
  nil)


(defmethod asdf:perform ((op doc-op) (c asdf:component))
  nil)


(defmethod asdf:perform ((op doc-op) (c asdf:cl-source-file))
  nil)


(defmethod asdf:explain ((o doc-op)(c cldoc))
  (format t "~&;;; Generating Documentation for  ~A~%" (slot-value c 'target-system)))


(defmethod asdf:perform :around ((op doc-op) (c cldoc))
  (format t "~&;;; Generating Documentation for ~A in directory~%;;;  ~A~%"
    (slot-value c 'target-system)
    (slot-value c 'asdf::absolute-pathname))
  (call-next-method))


(defmethod asdf:perform ((op doc-op)(c asdf:system))
  (let* ((target c)
          (path  (asdf:system-relative-pathname target "doc/api/")))
    (unless (find-package :cldoc)  (asdf:operate 'asdf:load-op :cldoc))
    (funcall (intern (string 'extract-documentation) :cldoc)
      (intern (string 'html) :cldoc) (namestring path) target)
;    (format t path)
    ))


(defmethod asdf:perform ((op doc-op) (c cldoc))
  (let* ((target (asdf:find-system (target-system c)))
          (path  (asdf:system-relative-pathname target
                   (pathname (slot-value
                               (car (remove-if-not #'(lambda (x) (typep x 'cldoc))
                                      (asdf:module-components target)))
                               'asdf::relative-pathname)))))
    (unless (find-package :cldoc)  (asdf:operate 'asdf:load-op :cldoc))
    (funcall (intern (string 'extract-documentation) :cldoc)
      (intern (string 'html) :cldoc) (namestring path) target)
    ))

(defun document-system (system &key force)
  "Extracts documentation from SYSTEM using ASDF and CLDOC. When
FORCE is T, forces the operation."
  (asdf:operate 'doc-op system :force force)
  (values))


(import '(cldoc:doc-op cldoc:document-system cldoc:cldoc) :cl-user)
(import '(cldoc:doc-op cldoc:document-system cldoc:cldoc) :asdf)

;;; EXAMPLE .asd:
;;
;; (in-package :cl-user)
;;
;; (eval-when (:load-toplevel :compile-toplevel :execute)
;;   (asdf:load-system :cldoc))
;;
;; (asdf:defsystem :xxxx
;;   :description "yyyy"
;;   :long-description "zzzz"
;;   :version "0.2.0"
;;   :author "Dan Lentz"
;;   :serial t
;;   :components ((:file "package")
;;                 (:file "foo")
;;                 (:cldoc          :xxxx-documentation
;;                                  :target-system :xxxx
;;                   :pathname "doc/html/")))

;;; EXAMPLE repl:
;;
;; CL-USER> (asdf:load-system :xxxx)
;; ....
;; CL-USER> (asdf:document-system :xxxx)
;; ....
;; CL-USER> (asdf:print-system :xxxx)
;; ....
