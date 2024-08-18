(in-package :tg-bot-api)

(defmethod eval-update ((update-type t) update-plist)
	(log-data (format nil "Update of type ~A was received and not handled." update-type)))

(defmethod eval-update ((update-type (eql :|message|)) 
                        update-plist)
	"Evaluates updates of Message type. 
	 Sets update's type-object slot value to Message object."	
    (let ((bot-command-length (get-bot-command-length 
                                    (getf update-plist :|entities|))))
        (if bot-command-length 
            (let ((bot-command (extract-command 
                                    (getf update-plist :|text|)
                                    (getf bot-command-length :|length|))))
                (return-from eval-update 
                    (on-command update-plist
                                (command bot-command) 
                                (text bot-command)))))))

(defgeneric on-command (update-plist command text))

(defun reply (text)
	(drakma:http-request
		(get-api-url "sendMessage")
		:method :post
		:parameters `(("text" . ,text)
                      ("chat_id" . ,(getf (getf *current-update*  
														:|chat|) 
														:|id|)))))

(defun send-message (chat-id text parameters)
    "Receives chat-id and text for message. 
     Also receives parameters pairlis, containing fields in sendMessage API reference."
    (drakma:http-request
		(get-api-url "sendMessage")
		:method :post
		:parameters `(("text" . ,text)
                      ("chat_id" . ,chat-id)
                      ,parameters)))