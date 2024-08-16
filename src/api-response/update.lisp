(in-package :api-response)

(defclass update (has-raw-plist)
	((update-type
		:accessor update-type
		:initarg update-type)
	 (type-object 
	 	:accessor type-object
	 	:initform nil)))

(defmethod initialize-instance :after ((update-inst update))
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
					(return from eval-update 
						(on-command (command bot-command) 
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
	(loop for array-element on plist-array
		when (eql (getf array-element :|type|) "bot_command")
		return (getf array-element :|length|)))


(defun plist-key-exists (key plist) 
	"Determines if plist has the given key (non-recursively)."
	(loop for (indicator value) on plist
		when (eql indicator key)
		return t))

#| 
(defmethod has-command ((update-inst update))
	"Checks if message has an entity 'bot_command'"
	(string= 
		"bot_command"
		(getf (first 
				(getf (raw-plist update-rec) :|entities|)) 
			:|type|)))
|#