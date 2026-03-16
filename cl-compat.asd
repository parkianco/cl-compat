(asdf:defsystem #:cl-compat
  :depends-on (#:alexandria #:bordeaux-threads)
  :components ((:module "src"
                :components ((:file "package")
                             (:file "cl-compat" :depends-on ("package"))))))