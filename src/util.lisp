(in-package :tg-bot-api)

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

(defun init-user (user-id)
    "Finds or creates a user record in DB, resets their dialog state."
    (let ((db-user (mito:find-dao 'user :user-id user-id)))
        (if db-user
            (progn 
                (setf (slot-value db-user 'dialog-branch) "initial")
                (setf (slot-value db-user 'dialog-layer) nil)
                (setf (slot-value db-user 'dialog-page) nil)
                (setf (slot-value db-user 'dialog-data) nil)
                (mito:delete-by-values 'person-info :creator-id user-id))
            (setf db-user (mito:create-dao 'user 
                                :user-id user-id 
                                :dialog-branch "initial")))
        db-user))

(defun get-current-user ()
    (mito:find-dao 'user 
        :user-id (getf *current-user* :|id|)))

(defun get-chat-id (update-plist)
    (getf (getf update-plist :|chat|) :|id|))

(defun text-back (text)
    "Sends plain text to the current update's chat.
     Does not reply to the actual message received."
	(send-json-to-route "sendMessage"
        `(:|text| ,text 
          :|chat_id| ,(write-to-string 
                            (getf (getf *current-update*  
                                                :|chat|) 
                                                :|id|)))))

(defun send-message (chat-id text &optional (parameters nil))
    "Receives chat-id and text for message. 
     Also receives parameters plist, containing fields in sendMessage API reference."
    (send-json-to-route "sendMessage"
        (merge-plist `(:|chat_id| ,chat-id :|text| ,text) 
                      parameters)))


#|    Rest   |#

(defun merge-plist (p1 p2)
    (loop with notfound = '#:notfound
        for (indicator value) on p1 by #'cddr
        when (eq (getf p2 indicator notfound) notfound) 
        do (progn
                (push value p2)
                (push indicator p2)))
    p2)


(defun path-from-app-root (path)
    "Get absolute path from the application's root directory.
     Path parameter should be a strings with a trailing slash, i.e. src/www/"
    (asdf:system-relative-pathname
        "tg-bot-api"
        path))