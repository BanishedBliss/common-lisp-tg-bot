(in-package :telegram-bot-api)

#| Sections:
    1. Env config logic
    2. Bot API
    3. Rest
|#

#|    Env config logic    |#

(defparameter *config* (make-hash-table)
    "Sets up config storage.")

(defmacro set-config (key-value-pair) 
    "Loads config from config.lisp to an easily accessible hash table."
    '(setf (gethash (first key-value-pair) *config*) (second key-value-pair)))

(defun load-config ()
    "Initializes config variables. 
     Should be called before server starts."
    (loop for (indicator value) in *env*
        do (setf (gethash indicator *config*) value))
    ;(makunbound '*env*)
    )

;; TODO: Add a check for the required variables

(defun get-env (name)
    "Gets an env variable via passed key, i.e. :bot-api-key.
     Can only be used after loading config via (load-config)"
    (gethash name *config* nil))


#|    Bot API    |#

(defun get-api-url (api-route) 
    (format nil "https://api.telegram.org/bot~A/~A" 
        (get-env :bot-api-key)
        api-route))

(defun log-data (data)
    "Writes data to log"
    (prin1 data))


#|    Rest   |#

(defun path-from-app-root (path)
    "Get absolute path from the application's root directory.
     Path parameter should be a strings with a trailing slash, i.e. src/www/"
    (asdf:system-relative-pathname
        "hunch-test-bot"
        path))