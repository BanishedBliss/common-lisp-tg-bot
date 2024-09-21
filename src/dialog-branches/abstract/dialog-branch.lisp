;;; Contents:
;;; 1. Main class
;;; 2. Child classes

(in-package :tg-bot-api)


#| Main class |#

(defclass dialog-branch () ())

(defgeneric reply-markup-type (branch)
	(:documentation "Returns instance of reply-markup specific for the branch"))

(defmethod reply-markup-type ((branch dialog-branch))
	(make-instance 'keyboard-markup-rs))

(defgeneric branch-message (branch)
	(:documentation "Returns branch message to be passed down to 
	 api:sendmessage as dialog state message."))

(defgeneric reply-options (branch)
	(:documentation "A list of rows of buttons to serve as reply options.
	 Row of buttons is a list of buttons to serve as columns.
	 Button is a plist with :text and optional :data and :action attributes.
	 :text attribute is a string displayed on the button.
	 :data is an optional attribute - a string 
	 	with data trigger to be passed to an inline button.
	 :action is an optional attribute, a plist 
	 	with its parameter being name of action and its value is something 
		to be passed down to the actions"))

(defmethod branch-prerender-actions ((branch dialog-branch))
	"Default prerender action, when dialog option points to the branch"
	t)

(defmethod reply-markup ((branch dialog-branch))
	"Returns keyboard form to be passed down to 
	 api:send-message as request parameter"
	(compile-reply-markup (reply-markup-type branch) 
						  (reply-options branch)))

(defmethod update-user-dialog ((branch dialog-branch))
	"Updates current dialog to reflect user's actions."
	(api:send-message (api:get-chat-id)
					  (branch-message branch)
					  (reply-markup branch)))

;; Option action methods

(defmethod option-action-by-text ((branch dialog-branch))
	"Executes an action associated with the selected option."
	(run-option-action (option-action :text)))

(defmethod option-action-by-data ((branch dialog-branch))
	"Executes and action associated with the selected option"
	(run-option-action (option-action :data)))

(defmacro option-action (look-by)
	"Looks for action in dialog branch options by :text or :data, 
	 depending on the look-by value passed to the macro"
	`(let (found-action) 
		(loop for row in (reply-options branch)
			  do (loop for button in row
					   when ,(cond 
					   			((eql look-by :text) 
									'(string= (getf button :text) update:message-text))
								((eql look-by :data)
									'(string= (getf button :data) update:callback-data)))
					   do (setf found-action (getf button :action))
					   when found-action (return))
			  when found-action (return found-action))))


#| Child classes |#

(defclass branch-text-input (dialog-branch) ())

(defmethod reply-markup-type ((branch branch-text-input)) 
	(make-instance 'inline-markup))

(defgeneric read-user-message (branch)
	(:documentation "Reads message as text for further processing in branch context."))