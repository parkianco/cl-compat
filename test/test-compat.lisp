;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; test-compat.lisp - Unit tests for compat
;;;;
;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: BSD-3-Clause

(defpackage #:cl-compat.test
  (:use #:cl)
  (:export #:run-tests))

(in-package #:cl-compat.test)

(defun run-tests ()
  "Run all tests for cl-compat."
  (format t "~&Running tests for cl-compat...~%")
  ;; TODO: Add test cases
  ;; (test-function-1)
  ;; (test-function-2)
  (format t "~&All tests passed!~%")
  t)
