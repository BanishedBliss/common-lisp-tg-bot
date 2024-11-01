(in-package :tg-bot-api/body)

(defclass command-start (command-input) ())
(defmethod on-command ((command command-start))
    "Receives '/start' command. 
     Resets dialog state, erases user data. Sends initial dialog options"
    (db-util:reset-dialog-state)
	(update-user-dialog (make-instance 'branch-initial)))

(defmethod on-message ((message message-input))
	"On received message read message as raw text input or a selected keyboard option, 
	 depending on the dialog state."
	(or (and (subtypep (class-of update:*current-branch*) 
				  	   (find-class 'branch-text-input))
			 (read-user-message update:*current-branch*)))
		(option-action-by-text update:message-text))

(defmethod on-callback-button ((callback callback-button-input))
	(option-action-by-data update:callback-data))