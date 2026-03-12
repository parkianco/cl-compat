;;;; package.lisp - cl-compat package definition
;;;; Copyright (c) 2024-2026 Parkian Company LLC
;;;; License: BSD-3-Clause

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require :sb-bsd-sockets))

(defpackage #:cl-compat
  (:use #:cl)
  (:export
   ;; Feature detection
   #:when-feature
   #:if-feature
   #:feature-available-p

   ;; Threading
   #:make-thread
   #:current-thread
   #:thread-name
   #:thread-alive-p
   #:join-thread
   #:destroy-thread
   #:thread-yield
   #:all-threads
   #:with-thread-bindings

   ;; Locks
   #:make-lock
   #:acquire-lock
   #:release-lock
   #:with-lock-held
   #:try-lock

   ;; Condition variables
   #:make-condition-variable
   #:condition-wait
   #:condition-notify
   #:condition-broadcast

   ;; Semaphores
   #:make-semaphore
   #:signal-semaphore
   #:wait-semaphore
   #:try-semaphore

   ;; Sockets
   #:make-tcp-socket
   #:make-tcp-server
   #:accept-connection
   #:socket-connect
   #:socket-send
   #:socket-receive
   #:socket-close
   #:with-tcp-connection
   #:make-udp-socket
   #:udp-send
   #:udp-receive
   #:socket-local-address
   #:socket-remote-address

   ;; UUID
   #:make-uuid
   #:parse-uuid
   #:uuid-bytes
   #:uuid-string
   #:uuid=

   ;; UTF-8
   #:utf8-encode
   #:utf8-decode
   #:utf8-length
   #:utf8-valid-p))
