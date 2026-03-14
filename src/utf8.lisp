;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; utf8.lisp - UTF-8 encoding/decoding
;;;; Copyright (c) 2024-2026 Parkian Company LLC
;;;; License: BSD-3-Clause

(in-package #:cl-compat)

;;; UTF-8 Encoding

(defun utf8-encode (string)
  "Encode STRING to UTF-8 bytes."
  (sb-ext:string-to-octets string :external-format :utf-8))

(defun utf8-decode (bytes &key (start 0) end)
  "Decode UTF-8 BYTES to a string."
  (sb-ext:octets-to-string bytes :external-format :utf-8 :start start :end end))

(defun utf8-length (string)
  "Return the number of bytes needed to encode STRING as UTF-8."
  (length (utf8-encode string)))

;;; UTF-8 Validation

(defun utf8-valid-p (bytes &key (start 0) end)
  "Return T if BYTES contains valid UTF-8."
  (let ((end (or end (length bytes)))
        (i start))
    (loop while (< i end)
          do (let ((b (aref bytes i)))
               (cond
                 ;; ASCII
                 ((< b #x80)
                  (incf i))
                 ;; 2-byte sequence
                 ((= (logand b #xe0) #xc0)
                  (unless (and (< (+ i 1) end)
                               (= (logand (aref bytes (+ i 1)) #xc0) #x80))
                    (return nil))
                  (incf i 2))
                 ;; 3-byte sequence
                 ((= (logand b #xf0) #xe0)
                  (unless (and (< (+ i 2) end)
                               (= (logand (aref bytes (+ i 1)) #xc0) #x80)
                               (= (logand (aref bytes (+ i 2)) #xc0) #x80))
                    (return nil))
                  (incf i 3))
                 ;; 4-byte sequence
                 ((= (logand b #xf8) #xf0)
                  (unless (and (< (+ i 3) end)
                               (= (logand (aref bytes (+ i 1)) #xc0) #x80)
                               (= (logand (aref bytes (+ i 2)) #xc0) #x80)
                               (= (logand (aref bytes (+ i 3)) #xc0) #x80))
                    (return nil))
                  (incf i 4))
                 ;; Invalid leading byte
                 (t (return nil))))
          finally (return t))))

;;; Character-level operations

(defun utf8-char-length (char)
  "Return the number of bytes needed to encode CHAR as UTF-8."
  (let ((code (char-code char)))
    (cond
      ((< code #x80) 1)
      ((< code #x800) 2)
      ((< code #x10000) 3)
      (t 4))))

(defun utf8-string-char-count (bytes &key (start 0) end)
  "Return the number of characters in UTF-8 BYTES."
  (let ((end (or end (length bytes)))
        (count 0))
    (loop for i from start below end
          for b = (aref bytes i)
          ;; Count bytes that are not continuation bytes
          unless (= (logand b #xc0) #x80)
          do (incf count))
    count))

;;; Streaming UTF-8 decoder

(defstruct utf8-decoder
  (state :ground)
  (bytes-needed 0 :type fixnum)
  (codepoint 0 :type fixnum))

(defun utf8-decoder-feed (decoder byte)
  "Feed BYTE to DECODER. Returns character if complete, NIL otherwise."
  (with-slots (state bytes-needed codepoint) decoder
    (case state
      (:ground
       (cond
         ((< byte #x80)
          (code-char byte))
         ((= (logand byte #xe0) #xc0)
          (setf state :continuation
                bytes-needed 1
                codepoint (logand byte #x1f))
          nil)
         ((= (logand byte #xf0) #xe0)
          (setf state :continuation
                bytes-needed 2
                codepoint (logand byte #x0f))
          nil)
         ((= (logand byte #xf8) #xf0)
          (setf state :continuation
                bytes-needed 3
                codepoint (logand byte #x07))
          nil)
         (t
          (error "Invalid UTF-8 leading byte: ~X" byte))))
      (:continuation
       (unless (= (logand byte #xc0) #x80)
         (error "Invalid UTF-8 continuation byte: ~X" byte))
       (setf codepoint (logior (ash codepoint 6) (logand byte #x3f)))
       (decf bytes-needed)
       (when (zerop bytes-needed)
         (setf state :ground)
         (code-char codepoint))))))
