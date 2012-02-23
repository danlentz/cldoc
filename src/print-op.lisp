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


(defclass print-op (asdf:operation)
  ((program :initarg :program  :initform "/usr/bin/enscript")
    ;; (layout-options   :initarg :layout-options
    ;;   :initform (list "-U2" "-A2")
    (heading-fontspec :initarg :heading-fontspec
      :initform "Helvetica-BoldOblique@10")
    (body-fontspec    :initarg :body-fontspec
      :initform  "Courier-New@9")
    ))


(defmethod asdf:operate ((o print-op)(s asdf:module) &key)
  (mapc #'(lambda (spec) (apply #'asdf:perform (list (car spec) (cdr spec))))
    (asdf::traverse o s)))


(defmethod asdf:explain ((o print-op)(c asdf:component))
  (format t "~%;;; printing ~A~%" (asdf:component-pathname c)))


(defmethod asdf:perform ((o print-op) c)
  t)

(defmethod asdf:perform ((o print-op)(c asdf:source-file))
  (format t "~%;;; printing ~A~%" (asdf:component-pathname c))
  (sb-ext:run-program (slot-value o 'program)
    (list "-U2" "-A2"
      "-F" (slot-value o 'heading-fontspec)
      "-f" (slot-value o 'body-fontspec)
      (format nil "~A" (asdf:component-pathname c)))))


(defmethod asdf:perform ((o print-op)(c asdf:static-file))
  (format t "~%;;; printing ~A~%" (asdf:component-pathname c))
  (sb-ext:run-program (slot-value o 'program)
    (list "-U2" "-A2"
      "-F" (slot-value o 'heading-fontspec)
      "-f" (slot-value o 'body-fontspec)
      (format nil "~A" (asdf:component-pathname c)))))


(defun print-system (system)
  (let ((asdf:*asdf-verbose* t))
    (asdf:operate 'print-op (asdf:find-system system)))
  (values))

(import '(cldoc:print-op cldoc:print-system) :cl-user)
(import '(cldoc:print-op cldoc:print-system) :asdf)

;; (print-system :gs.ebu.asdf)

;;;;;
;; Local Variables:
;; indent-tabs: nil
;; outline-regexp: ";;[;]+"
;; End:
;;;;;
