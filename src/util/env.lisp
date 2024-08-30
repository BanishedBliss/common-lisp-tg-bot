(in-package :tg-bot-api/util/env)

(defparameter *config* (make-hash-table)
    "Sets up config storage.")

#| 
(defmacro set-config (key-value-pair) 
    "Loads config from config.lisp to an easily accessible hash table."
    '(setf (gethash (first key-value-pair) *config*) (second key-value-pair)))
|#

(defun load-config ()
    "Initializes config variables. 
     Should be called before server starts."
    (loop for (indicator value) in *env*
        do (setf (gethash indicator *config*) value))
    (makunbound '*env*))

;; TODO: Add a check for the required variables

(defun get-env (name)
    "Gets an env variable via passed key, i.e. :bot-api-key.
     Can only be used after loading config via (load-config)"
    (gethash name *config* nil))