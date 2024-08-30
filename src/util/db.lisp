(in-package :tg-bot-api/util/db)

(defun init-user ()
    "Finds or creates a user record in DB."
    (let ((user-db (mito:find-dao 'user :user-id (getf update:*current-user* :|id|))))
        (if user-db user-db 
			(mito:create-dao 'user :user-id (getf update:*current-user* :|id|)))))

(defun init-dialog-state (user-id)
	"Finds or creates a dialog state record in DB."
	(let ((dialog-state-db (mito:find-dao 'dialog-state :user-id (slot-value update:*user-db* 'id))))
		(if dialog-state-db dialog-state-db
			(mito:create-dao 'dialog-state 
				:user-id (slot-value update:*user-db* 'id)))))

(defun reset-dialog-state ()
	"Resets dialog state when the bot is given a /start command."
	(and (not (string= 
				(slot-value update:*dialog-state-db* 'branch) 
				"branch-initial")) 
		 (setf (slot-value update:*dialog-state-db* 'branch) "branch-initial")
		 (setf (slot-value update:*dialog-state-db* 'breadcrumbs) "")
		 (setf (slot-value update:*dialog-state-db* 'people-data-offset) 0)
		 (mito:save-dao update:*dialog-state-db*))
	(mito:delete-by-values 'person-info :creator-id (slot-value update:*user-db* 'id))) 