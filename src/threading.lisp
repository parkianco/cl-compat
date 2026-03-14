;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; threading.lisp - Threading compatibility layer
;;;; Copyright (c) 2024-2026 Parkian Company LLC
;;;; License: BSD-3-Clause

(in-package #:cl-compat)

;;; Threads

(defun make-thread (function &key name)
  "Create and start a new thread running FUNCTION."
  #+sb-thread
  (sb-thread:make-thread function :name (or name "unnamed"))
  #-sb-thread
  (error "Threading not supported"))

(defun current-thread ()
  "Return the current thread."
  #+sb-thread sb-thread:*current-thread*
  #-sb-thread nil)

(defun thread-name (thread)
  "Return the name of THREAD."
  #+sb-thread (sb-thread:thread-name thread)
  #-sb-thread nil)

(defun thread-alive-p (thread)
  "Return T if THREAD is still running."
  #+sb-thread (sb-thread:thread-alive-p thread)
  #-sb-thread nil)

(defun join-thread (thread)
  "Wait for THREAD to finish and return its result."
  #+sb-thread (sb-thread:join-thread thread)
  #-sb-thread nil)

(defun destroy-thread (thread)
  "Forcibly terminate THREAD."
  #+sb-thread (sb-thread:terminate-thread thread)
  #-sb-thread nil)

(defun thread-yield ()
  "Yield the CPU to other threads."
  #+sb-thread (sb-thread:thread-yield)
  #-sb-thread nil)

(defun all-threads ()
  "Return list of all threads."
  #+sb-thread (sb-thread:list-all-threads)
  #-sb-thread nil)

(defmacro with-thread-bindings (bindings &body body)
  "Execute BODY with special variable bindings that propagate to child threads."
  `(let ,bindings
     (declare (special ,@(mapcar #'car bindings)))
     ,@body))

;;; Locks (Mutexes)

(defun make-lock (&optional name)
  "Create a new lock (mutex)."
  #+sb-thread (sb-thread:make-mutex :name name)
  #-sb-thread nil)

(defun acquire-lock (lock &optional wait-p)
  "Acquire LOCK. If WAIT-P is NIL, return immediately if lock unavailable."
  #+sb-thread
  (if wait-p
      (sb-thread:grab-mutex lock)
      (sb-thread:grab-mutex lock :waitp nil))
  #-sb-thread t)

(defun release-lock (lock)
  "Release LOCK."
  #+sb-thread (sb-thread:release-mutex lock)
  #-sb-thread nil)

(defmacro with-lock-held ((lock) &body body)
  "Execute BODY while holding LOCK."
  #+sb-thread
  `(sb-thread:with-mutex (,lock)
     ,@body)
  #-sb-thread
  `(progn ,@body))

(defun try-lock (lock)
  "Try to acquire LOCK without blocking. Return T if acquired, NIL otherwise."
  #+sb-thread (sb-thread:grab-mutex lock :waitp nil)
  #-sb-thread t)

;;; Condition Variables

(defun make-condition-variable (&optional name)
  "Create a new condition variable."
  #+sb-thread (sb-thread:make-waitqueue :name name)
  #-sb-thread nil)

(defun condition-wait (cv lock)
  "Wait on condition variable CV, atomically releasing LOCK."
  #+sb-thread (sb-thread:condition-wait cv lock)
  #-sb-thread nil)

(defun condition-notify (cv)
  "Wake one thread waiting on CV."
  #+sb-thread (sb-thread:condition-notify cv)
  #-sb-thread nil)

(defun condition-broadcast (cv)
  "Wake all threads waiting on CV."
  #+sb-thread (sb-thread:condition-broadcast cv)
  #-sb-thread nil)

;;; Semaphores

(defun make-semaphore (&optional (count 0) name)
  "Create a semaphore with initial COUNT."
  #+sb-thread (sb-thread:make-semaphore :name name :count count)
  #-sb-thread (list count))

(defun signal-semaphore (semaphore &optional (count 1))
  "Increment semaphore by COUNT."
  #+sb-thread (sb-thread:signal-semaphore semaphore count)
  #-sb-thread (incf (car semaphore) count))

(defun wait-semaphore (semaphore)
  "Wait on semaphore (decrement)."
  #+sb-thread (sb-thread:wait-on-semaphore semaphore)
  #-sb-thread (decf (car semaphore)))

(defun try-semaphore (semaphore)
  "Try to decrement semaphore without blocking."
  #+sb-thread (sb-thread:try-semaphore semaphore)
  #-sb-thread (when (> (car semaphore) 0) (decf (car semaphore)) t))
