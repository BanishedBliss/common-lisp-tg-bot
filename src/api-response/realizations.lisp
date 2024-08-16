(defclass realization () 
	((trigger :initarg))
	(:documentation ""))

(defun analyze-update (update-plist)
	(let (realizations '())
		(loop for (indicator value) on update-plist
			do (make-instance ))))

(defvar *realizations-queue* '(
	(:update-type :|message| :pretenders '(on-message on-command))
))

(defmethod read-indicator ((r-inst realization) ))

(loop for (indicator value) on plist-object
	do (pass-indicator-to-handler)
	do (pass-value-to-handler))

#|
	Message has bot command 

	Message - key 
	Bot command - list element under |entities| key under message's list of props.
		Case of entity.

	Message data - is list of keys and values. 
	Message - text, the sending, what arrived and tells.


	
 |#

