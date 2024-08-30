(defclass command-start (command-input) ())
(defmethod on-command ((command command-start))
    "Receives '/start' command. 
     Resets dialog state, erases user data. Sends initial dialog options"
    (db-util:reset-dialog-state)
	(update-dialog-state (make-instance 'branch-initial)))

(defmethod update-dialog-state ((branch dialog-branch))
	
	(api:send-message (api:get-chat-id)
					  (branch-message branch)
					  (reply-markup branch))) 
