;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; uuid.lisp - UUID generation
;;;; Copyright (c) 2024-2026 Parkian Company LLC
;;;; License: BSD-3-Clause

(in-package #:cl-compat)

;;; UUID structure

(defstruct (uuid (:constructor %make-uuid))
  (bytes (make-array 16 :element-type '(unsigned-byte 8) :initial-element 0)
         :type (simple-array (unsigned-byte 8) (16))))

;;; Random number generation for UUID v4

(defun get-random-bytes (n)
  "Get N random bytes using system entropy."
  (let ((bytes (make-array n :element-type '(unsigned-byte 8))))
    ;; Try to use /dev/urandom on Unix
    (handler-case
        (with-open-file (f "/dev/urandom" :element-type '(unsigned-byte 8))
          (read-sequence bytes f)
          bytes)
      (error ()
        ;; Fall back to CL random (less secure but works everywhere)
        (dotimes (i n)
          (setf (aref bytes i) (random 256)))
        bytes))))

;;; UUID v4 generation

(defun make-uuid ()
  "Generate a random UUID (version 4)."
  (let ((bytes (get-random-bytes 16)))
    ;; Set version to 4 (bits 4-7 of byte 6)
    (setf (aref bytes 6) (logior (logand (aref bytes 6) #x0f) #x40))
    ;; Set variant to RFC 4122 (bits 6-7 of byte 8)
    (setf (aref bytes 8) (logior (logand (aref bytes 8) #x3f) #x80))
    (%make-uuid :bytes bytes)))

;;; UUID string conversion

(defun uuid-string (uuid)
  "Convert UUID to standard string representation."
  (let ((bytes (uuid-bytes uuid)))
    (format nil "~(~2,'0X~2,'0X~2,'0X~2,'0X-~2,'0X~2,'0X-~2,'0X~2,'0X-~2,'0X~2,'0X-~2,'0X~2,'0X~2,'0X~2,'0X~2,'0X~2,'0X~)"
            (aref bytes 0) (aref bytes 1) (aref bytes 2) (aref bytes 3)
            (aref bytes 4) (aref bytes 5)
            (aref bytes 6) (aref bytes 7)
            (aref bytes 8) (aref bytes 9)
            (aref bytes 10) (aref bytes 11) (aref bytes 12) (aref bytes 13)
            (aref bytes 14) (aref bytes 15))))

(defmethod print-object ((uuid uuid) stream)
  (print-unreadable-object (uuid stream :type t)
    (write-string (uuid-string uuid) stream)))

(defun parse-uuid (string)
  "Parse UUID from standard string representation."
  (let ((cleaned (remove #\- string))
        (bytes (make-array 16 :element-type '(unsigned-byte 8))))
    (unless (= (length cleaned) 32)
      (error "Invalid UUID string: ~A" string))
    (loop for i from 0 below 16
          for pos = (* i 2)
          do (setf (aref bytes i)
                   (parse-integer cleaned :start pos :end (+ pos 2) :radix 16)))
    (%make-uuid :bytes bytes)))

;;; UUID comparison

(defun uuid= (uuid1 uuid2)
  "Return T if UUID1 and UUID2 are equal."
  (equalp (uuid-bytes uuid1) (uuid-bytes uuid2)))

;;; UUID utilities

(defun uuid-version (uuid)
  "Return the version of UUID."
  (ash (logand (aref (uuid-bytes uuid) 6) #xf0) -4))

(defun uuid-variant (uuid)
  "Return the variant of UUID."
  (let ((byte8 (aref (uuid-bytes uuid) 8)))
    (cond
      ((zerop (logand byte8 #x80)) :ncs)
      ((= (logand byte8 #xc0) #x80) :rfc4122)
      ((= (logand byte8 #xe0) #xc0) :microsoft)
      (t :future))))
