;;;;; -*- mode: lisp; syntax: common-lisp; coding: utf-8; base: 10; -*-
;;;;;
;;;;; print-op.lisp
;;;;;
;;;;;   hardcopy of system source code
;;;;; 
;;;;; Author:      Dan Lentz, Lentz Intergalactic Softworks, Tue Mar  8 23:49:55 2011
;;;;; Maintainer:  <danlentz@gmail.com>
;;;;;
;;;;; Hey!!  Let's watch the' ELEVATOR go UP and DOWN at th' HILTON HOTEL!!
;;;;;

(in-package :cldoc)

(defparameter *enscript-executable* "enscript")

(defclass print-op (asdf:operation)
  ((program :initarg :program  :initform *enscript-executable*)
    (indent :initarg :indent :initform 0)
    (nup :initarg :nup :initform 2)
    (ncol :initarg :ncol :initform 2)
    (media :initarg :media :initform "Letter")
    (heading-fontspec :initarg :heading-fontspec   :initform "Helvetica-BoldOblique@10")
    (body-fontspec    :initarg :body-fontspec      :initform  "Courier-New@9")))

(defmethod asdf:operation-done-p ((o print-op)(c asdf:source-file))
  nil)

(defmethod asdf:operation-done-p ((o print-op)(c asdf:static-file))
  nil)

(defmethod asdf:operate ((o print-op)(s asdf:system) &key)
  (asdf:perform o s)
  (call-next-method))

(defmethod asdf:operate ((o print-op)(s asdf:module) &key)
  (mapc #'(lambda (spec) (apply #'asdf:perform (list (car spec) (cdr spec))))
    (asdf::traverse o s)))


(defmethod asdf:explain ((o print-op)(c asdf:component))
  (format t "~&;;; will print ~A~%" (asdf:component-pathname c)))


(defmethod asdf:perform ((o print-op) c)
  t)

(defmethod asdf:perform ((o print-op)(c asdf:system))
  (format t "~&;;; printing system ~A~%" (asdf:component-pathname c))
  (asdf/run-program:run-program
    (format nil "~A -U~D -A~D -i~Di -M ~A -F ~A -f ~A ~A"
      (slot-value o 'program)
      (slot-value o 'nup)
      (slot-value o 'ncol)
      (slot-value o 'indent)
      (slot-value o 'media)
      (slot-value o 'heading-fontspec)
      (slot-value o 'body-fontspec)
      (asdf:component-pathname c))))
  
(defmethod asdf:perform ((o print-op)(c asdf:source-file))
  (format t "~&;;; printing source ~A~%" (asdf:component-pathname c))
  (asdf/run-program:run-program
    (format nil "~A -U~D -A~D -i~Di -M ~A -F ~A -f ~A ~A"
      (slot-value o 'program)
      (slot-value o 'nup)
      (slot-value o 'ncol)
      (slot-value o 'indent)
      (slot-value o 'media)
      (slot-value o 'heading-fontspec)
      (slot-value o 'body-fontspec)
      (asdf:component-pathname c))))
      
(defmethod asdf:perform ((o print-op)(c asdf:static-file))
  (format t "~&;;; printing static ~A~%" (asdf:component-pathname c))
  (asdf/run-program:run-program
    (format nil "~A -U~D -A~D -i~Di -M ~A -F ~A -f ~A ~A"
      (slot-value o 'program)
      (slot-value o 'nup)
      (slot-value o 'ncol)
      (slot-value o 'indent)
      (slot-value o 'media)
      (slot-value o 'heading-fontspec)
      (slot-value o 'body-fontspec)
      (asdf:component-pathname c))))
      
(defun print-system (system)
  (let ((asdf:*asdf-verbose* t))
    (asdf:operate 'print-op (asdf:find-system system)))
  (values))

(import '(cldoc:print-op cldoc:print-system) :cl-user)
(import '(cldoc:print-op cldoc:print-system) :asdf)

(defun :lpr (system-designator)
  (print-system system-designator))

;; (print-system :gs.ebu.asdf)

;;;;;
;; Local Variables:
;; indent-tabs: nil
;; outline-regexp: ";;[;]+"
;; End:
;;;;;
