(in-package :api-response)

(defclass update (has-raw-plist)
	((update-type
		:accessor update-type
		:initarg update-type)
	 (type-object 
	 	:accessor type-object
	 	:initform nil)))

(defmethod initialize-instance :after ((update-inst update) &rest args)
	(eval-update update-inst (update-type update-inst)))

(defgeneric eval-update (update-inst update-type))

(defmethod eval-update ((update-inst update) (update-type t))
	(telegram-bot-api:log-data (format nil "Update of type ~A was received and not handled." update-type)))

(defmethod eval-update ((update-inst update) 
						(update-type (eql :|message|)))
	"Evaluates updates of Message type. Sets update's type-object slot value to Message object."	
	(let ((message-plist (raw-value :|message| update-inst)))
		(setf (type-object update-inst) (make-instance 'message 
			:update-instance update-inst
			:message_id 	(getf message-plist :|message_id|)
			:text 			(getf message-plist :|text|)
			:date 			(getf message-plist :|date|) 
			:chat 			(make-instance 'chat :plist (getf message-plist :|chat|))
			:from 			(make-instance 'user :plist (getf message-plist :|from|))
			:entities 		(loop for entity-plist in (getf message-plist :|entities|)
								collect (make-instance 'message-entity :plist entity-plist))))))

#| 
(defmethod has-command ((update-inst update))
	"Checks if message has an entity 'bot_command'"
	(string= 
		"bot_command"
		(getf (first 
				(getf (raw-plist update-rec) :|entities|)) 
			:|type|)))
|#