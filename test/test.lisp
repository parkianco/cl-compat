;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(defpackage #:cl-compat.test
  (:use #:cl #:cl-compat)
  (:export #:run-tests))

(in-package #:cl-compat.test)

(defun run-tests ()
  (format t "Running professional test suite for cl-compat...~%")
  (assert (initialize-compat))
  (format t "Tests passed!~%")
  t)
