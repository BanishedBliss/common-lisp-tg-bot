(in-package :tg-bot-api)

(defgeneric on-callback-button (callback-button-input))

(defmethod eval-update-hooks ((update-type (eql :|callback_query|))
							   update-plist)
	"Evaluates updates of CallbackQuery type."
	(let ((dialog-input (make-instance 'callback-input 'update-plist update-plist)))
		(or (read-input-keyboard-button dialog-input))))

;; TODO: Replace change-class with type checks

(defmethod read-input-keyboard-button ((dialog-input callback-input))
	(change-class dialog-input 'callback-button-input
				  :data (getf update:*current-update* :|data|))
	(on-callback-button dialog-input))