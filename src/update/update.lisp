(in-package :tg-bot-api)

(defmethod eval-update-hooks ((update-type t) update-plist)
	(log-data (format nil "Update of type ~A was received and not handled." update-type)))

(defmethod eval-update-hooks ((update-type (eql :|message|)) 
                               update-plist)
	"Evaluates updates of Message type. 
	 Sets update's type-object slot value to Message object."	
    (let ((bot-command-length (get-bot-command-length 
                                    (getf update-plist :|entities|))))
        (if bot-command-length 
            (let ((bot-command (extract-command 
                                    (getf update-plist :|text|)
                                     bot-command-length))) 
                (on-command update-plist
                            (bot-command-name bot-command) 
                            (bot-command-text bot-command)))
                            
            (let ((message-text (getf update-plist :|text|)))
                (when (< 0 (length message-text))
                    (on-message update-plist message-text))))))

(defmethod no-applicable-method (on-command &rest rest)
    (text-back "Я не знаю такую команду."))

(defgeneric on-command (update-plist command text))

(defgeneric on-message (update-plist text))