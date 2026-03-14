;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; cl-compat.asd - SBCL compatibility layer
;;;; Copyright (c) 2024-2026 Parkian Company LLC
;;;; License: BSD-3-Clause

(asdf:defsystem #:cl-compat
  :description "SBCL compatibility layer for threading, sockets, UUID, and UTF-8"
  :author "Parkian Company LLC"
  :license "BSD-3-Clause"
  :version "0.1.0"
  :serial t
  :components ((:file "package")
               (:module "src"
                :serial t
                :components ((:file "features")
                             (:file "threading")
                             (:file "sockets")
                             (:file "uuid")
                             (:file "utf8")))))

(asdf:defsystem #:cl-compat/test
  :description "Tests for cl-compat"
  :depends-on (#:cl-compat)
  :serial t
  :components ((:module "test"
                :components ((:file "test-compat"))))
  :perform (asdf:test-op (o c)
             (let ((result (uiop:symbol-call :cl-compat.test :run-tests)))
               (unless result
                 (error "Tests failed")))))
