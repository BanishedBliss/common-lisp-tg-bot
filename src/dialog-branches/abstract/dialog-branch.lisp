(in-package :tg-bot-api)

(defclass dialog-branch () (
	(reply-markup-type 
	 :accessor reply-markup-type 
	 :initform (make-instance 'keyboard-markup-rs)
	 :documentation "Instance of reply-markup to define ")))

(defgeneric branch-message (branch)
	(:documentation "Returns branch message to be passed down to 
	 api:sendmessage as dialog state message."))

(defgeneric reply-options (branch dialog-branch)
	(:documentation "A list of rows of buttons to serve as reply options.
	 Row of buttons is a list of buttons to serve as columns.
	 Button is a plist with :text and optional :data and :action attributes.
	 :text attribute is a string displayed on the button.
	 :data is an optional attribute - a string 
	 	with data trigger to be passed to an inline button.
	 :action is an optional attribute, a plist 
	 	with its parameter being name of action and its value is something 
		to be passed down to the actions"))

(defmethod reply-markup ((branch dialog-branch))
	"Returns keyboard form to be passed down to 
	 api:send-message as request parameter"
	(compile-reply-markup (reply-markup-type branch) 
						  (reply-options branch)))

(defmethod update-dialog-state ((branch dialog-branch))
	"Updates current dialog to reflect user's actions."
	(api:send-message (api:get-chat-id)
					  (branch-message branch)
					  (reply-markup branch)))