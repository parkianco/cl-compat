;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; sockets.lisp - Socket compatibility layer
;;;; Copyright (c) 2024-2026 Parkian Company LLC
;;;; License: BSD-3-Clause

(in-package #:cl-compat)

;;; TCP Sockets

(defun make-tcp-socket ()
  "Create a TCP socket."
  (make-instance 'sb-bsd-sockets:inet-socket :type :stream :protocol :tcp))

(defun make-tcp-server (port &key (backlog 5) (host "0.0.0.0"))
  "Create a TCP server socket listening on PORT."
  (let ((socket (make-tcp-socket)))
    (setf (sb-bsd-sockets:sockopt-reuse-address socket) t)
    (sb-bsd-sockets:socket-bind socket (resolve-host host) port)
    (sb-bsd-sockets:socket-listen socket backlog)
    socket))

(defun accept-connection (server-socket)
  "Accept a connection on SERVER-SOCKET. Returns new socket."
  (sb-bsd-sockets:socket-accept server-socket))

(defun socket-connect (socket host port)
  "Connect SOCKET to HOST:PORT."
  (sb-bsd-sockets:socket-connect socket (resolve-host host) port)
  socket)

(defun socket-send (socket data &key (start 0) end)
  "Send DATA (string or vector) to SOCKET."
  (let* ((bytes (etypecase data
                  (string (sb-ext:string-to-octets data))
                  ((vector (unsigned-byte 8)) data)
                  (vector (coerce data '(vector (unsigned-byte 8))))))
         (end (or end (length bytes))))
    (sb-bsd-sockets:socket-send socket bytes (- end start) :start start :end end)))

(defun socket-receive (socket buffer-size &key (element-type '(unsigned-byte 8)))
  "Receive up to BUFFER-SIZE bytes from SOCKET."
  (let ((buffer (make-array buffer-size :element-type '(unsigned-byte 8))))
    (multiple-value-bind (buf len peer)
        (sb-bsd-sockets:socket-receive socket buffer nil)
      (declare (ignore peer))
      (when (and len (> len 0))
        (let ((result (subseq buf 0 len)))
          (if (eq element-type 'character)
              (sb-ext:octets-to-string result)
              result))))))

(defun socket-close (socket)
  "Close SOCKET."
  (sb-bsd-sockets:socket-close socket))

(defmacro with-tcp-connection ((var host port) &body body)
  "Execute BODY with VAR bound to a connected TCP socket."
  (let ((socket (gensym "SOCKET")))
    `(let ((,socket (make-tcp-socket)))
       (unwind-protect
           (progn
             (socket-connect ,socket ,host ,port)
             (let ((,var ,socket))
               ,@body))
         (socket-close ,socket)))))

;;; UDP Sockets

(defun make-udp-socket (&key port (host "0.0.0.0"))
  "Create a UDP socket, optionally bound to PORT."
  (let ((socket (make-instance 'sb-bsd-sockets:inet-socket
                               :type :datagram :protocol :udp)))
    (when port
      (sb-bsd-sockets:socket-bind socket (resolve-host host) port))
    socket))

(defun udp-send (socket data host port)
  "Send DATA to HOST:PORT via UDP SOCKET."
  (let ((bytes (etypecase data
                 (string (sb-ext:string-to-octets data))
                 ((vector (unsigned-byte 8)) data))))
    (sb-bsd-sockets:socket-send socket bytes nil
                                :address (list (resolve-host host) port))))

(defun udp-receive (socket buffer-size)
  "Receive up to BUFFER-SIZE bytes from UDP SOCKET.
Returns (values data host port)."
  (let ((buffer (make-array buffer-size :element-type '(unsigned-byte 8))))
    (multiple-value-bind (buf len peer)
        (sb-bsd-sockets:socket-receive socket buffer nil)
      (when (and len (> len 0))
        (values (subseq buf 0 len)
                (first peer)
                (second peer))))))

;;; Address utilities

(defun resolve-host (host)
  "Resolve HOST to an IP address vector."
  (etypecase host
    (string
     (if (every (lambda (c) (or (digit-char-p c) (char= c #\.))) host)
         ;; Dotted quad
         (let ((parts (loop for start = 0 then (1+ end)
                            for end = (position #\. host :start start)
                            collect (parse-integer host :start start :end end)
                            while end)))
           (coerce parts '(vector (unsigned-byte 8) 4)))
         ;; Hostname - lookup
         (let ((addr (sb-bsd-sockets:host-ent-address
                      (sb-bsd-sockets:get-host-by-name host))))
           addr)))
    (vector host)))

(defun socket-local-address (socket)
  "Return (values host port) for local side of SOCKET."
  (multiple-value-bind (addr port)
      (sb-bsd-sockets:socket-name socket)
    (values (format nil "~{~D~^.~}" (coerce addr 'list)) port)))

(defun socket-remote-address (socket)
  "Return (values host port) for remote side of SOCKET."
  (multiple-value-bind (addr port)
      (sb-bsd-sockets:socket-peername socket)
    (values (format nil "~{~D~^.~}" (coerce addr 'list)) port)))
