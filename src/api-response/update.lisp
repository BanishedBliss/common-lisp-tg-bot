(in-package :api-response)

(defparameter *current-update* nil)

(defclass update (has-raw-plist)
	((update-type
		:accessor update-type
		:initarg update-type)
	 (type-object 
	 	:accessor type-object
	 	:initform nil)))

(defmethod initialize-instance :after ((update-inst update) &rest args)
	(setf *current-update* update-inst)
	(eval-update update-inst (update-type update-inst)))

(defgeneric eval-update (update-inst update-type))

(defmethod eval-update ((update-inst update) (update-type t))
	(telegram-bot-api:log-data (format nil "Update of type ~A was received and not handled." update-type)))

(defmethod eval-update ((update-inst update) 
						(update-type (eql :|message|)))
	"Evaluates updates of Message type. 
	 Sets update's type-object slot value to Message object."
	(let ((message-plist (raw-value :|message| update-inst)))
		(let ((bot-command-length (get-bot-command-length 
									 (getf message-plist :|entities|))))
			(if bot-command-length 
				(let ((bot-command (extract-command 
										(getf message-plist :|text|)
										(getf bot-command-length :|length|))))
					(return-from eval-update 
						(on-command update-inst
									(command bot-command) 
							    	(text bot-command))))))

		
		
		#| 
		(setf (type-object update-inst) (make-instance 'message 
			:update-instance update-inst
			:message_id 	(getf message-plist :|message_id|)
			:text 			(getf message-plist :|text|)
			:date 			(getf message-plist :|date|) 
			:chat 			(make-instance 'chat :plist (getf message-plist :|chat|))
			:from 			(make-instance 'user :plist (getf message-plist :|from|))
			:entities 		(loop for entity-plist on (getf message-plist :|entities|)
								collect (make-instance 'message-entity :plist entity-plist))))
						|#		
		))

(defun get-bot-command-length (plist-array)
	(loop for array-element on plist-array by #'cddr
		when (eql (getf array-element :|type|) "bot_command")
		return (getf array-element :|length|)))


(defun plist-key-exists (key plist) 
	"Determines if plist has the given key (non-recursively)."
	(loop for (indicator value) on plist by #'cddr
		when (eql indicator key)
		return t))

(defgeneric on-command (update command text))

(defun reply (text)
	(drakma:http-request
		(telegram-bot-api:get-api-url "sendMessage")
		:method :post
		:parameters `(("chat_id" . ,(getf (getf (getf *current-update* 
														:|message|) 
														:|chat|) 
														:|id|))
					  ("text" . ,text))))


(defun get-updates-request (offset) 
    "Sends request to Telegram Bot API to receive latest bot updates."
    (drakma:http-request 
        (concatenate 'string (get-api-url "getUpdates")
                             "?timeout=5&offset="
                             (write-to-string offset))
        :method :get
        :connection-timeout 15))