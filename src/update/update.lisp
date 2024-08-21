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
                    (text-back message-text))))))

(defgeneric on-command (update-plist command text))

(defmethod no-applicable-method (on-command &rest rest)
    (text-back "Я не знаю такую команду."))

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

(defun send-message (chat-id text parameters)
    "Receives chat-id and text for message. 
     Also receives parameters plist, containing fields in sendMessage API reference."
    (send-json-to-route "sendMessage"
        (merge-plist `(:|chat_id| ,chat-id :|text| ,text) 
                      parameters)))