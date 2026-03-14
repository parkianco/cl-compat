;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; features.lisp - Feature detection
;;;; Copyright (c) 2024-2026 Parkian Company LLC
;;;; License: BSD-3-Clause

(in-package #:cl-compat)

;;; Feature detection predicates

(defun feature-available-p (feature)
  "Return T if FEATURE is available on this platform."
  (case feature
    (:threads #+sb-thread t #-sb-thread nil)
    (:64-bit (= (integer-length most-positive-fixnum) 62))
    (:unicode t)  ; SBCL always has unicode
    (:bsd-sockets t)  ; SBCL always has this
    (:ipv6 t)
    (otherwise (member feature *features*))))

;;; Feature macros

(defmacro when-feature (feature &body body)
  "Execute BODY only if FEATURE is available at load time."
  (if (feature-available-p feature)
      `(progn ,@body)
      nil))

(defmacro if-feature (feature then &optional else)
  "Execute THEN if FEATURE is available, otherwise ELSE."
  (if (feature-available-p feature)
      then
      else))

;;; Runtime feature checking

(defun check-feature (feature &optional error-message)
  "Signal an error if FEATURE is not available."
  (unless (feature-available-p feature)
    (error (or error-message
               (format nil "Feature ~A is not available" feature)))))

;;; Platform info

(defun platform-info ()
  "Return alist of platform information."
  `((:lisp-implementation . ,(lisp-implementation-type))
    (:lisp-version . ,(lisp-implementation-version))
    (:machine-type . ,(machine-type))
    (:machine-version . ,(machine-version))
    (:software-type . ,(software-type))
    (:software-version . ,(software-version))
    (:threads . ,(feature-available-p :threads))
    (:64-bit . ,(feature-available-p :64-bit))))
