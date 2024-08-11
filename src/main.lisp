(in-package :hunch-test-bot)

(defvar *bot-server* nil 
    "Stores web server instance for further management.") 


(defun start-web-server ()
    "Starts the Hunchentoot web server."
    
    (setf *bot-server* (make-instance 'hunchentoot:easy-acceptor
                            :port (get-env :server-internal-port)
                            :document-root (get-env :web-root-path)))
    (hunchentoot:start *bot-server*))

(defun main ()
    "Main entry point for the Telegram Bot server."
    (load-config)
    (start-web-server)
    
    ; (sleep most-positive-fixnum)
    )