(in-package :tg-bot-api)

(defclass dialog-branch () ())

(defgeneric branch-message (branch)
	(:documentation "Returns branch message to be passed down to api:sendmessage as dialog state message."))

(defgeneric reply-markup (branch)
	(:documentation "Returns keyboard form to be passed down to api:send-message as request parameter"))

(defmethod update-dialog-state ((branch dialog-branch))
	"Updates current dialog to reflect user's actions."
	(api:send-message (api:get-chat-id)
					  (branch-message branch)
					  (reply-markup branch)))

(defmacro keyboard-markup-rs (buttons)
	"Wrapps keyboard buttons in an appropriate form to send via API"
	``(:|reply_markup| (
		:|keyboard| ,buttons
		:|resize_keyboard| t)))

(defclass reply-markup () ())
(defclass keyboard-markup-rs () 
	((reply-markup `(:|reply_markup| (
						:|keyboard| ,buttons
						:|resize_keyboard| t))))) 