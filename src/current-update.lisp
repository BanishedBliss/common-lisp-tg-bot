(in-package :tg-bot-api/api/current-update)

(defparameter *current-update* nil)
(defparameter *current-user* nil)
(defparameter *user-db* nil)
(defparameter *dialog-state-db* nil)

(defun init (update-plist)
	"Initializes update environment for ease of access in main long-poll loop."
	(setf *current-update* update-plist)
	(setf *current-user* (getf update-plist :|from|))
	(setf *user-db* (db-util:init-user (getf *current-user* :|id|)))
	(setf *dialog-state-db* (db-util:init-dialog-state (getf *current-user* :|id|))))

(defun destroy ()
	"Cleans up memory."
	(setf *dialog-state-db* nil)
	(setf *user-db* nil)
	(setf *current-user* nil)
	(setf *current-update* nil))

(defun message-text ()
	"Gets current update's message text"
	(getf *current-update* :|text|))