(in-package :tg-bot-api)

(defclass reply-markup-type () ())
(defmethod initialize-instance :after ((markup reply-markup-type))
	(if (eql (class-of markup) 
			 (find-class reply-markup-type))
		(error "reply-markup-type is an abstract class and cannot be instantiated")))

(defgeneric compile-reply-markup (markup reply-options)
	(:documentation "Compiles a reply markup to send via api:send-message, 
	 given the markup type and reply options are supplied."))

(defmethod get-reply-buttons ((branch dialog-branch))
	"Extracts buttons from reply options of a branch"
	(let (buttons-markup)
		;; Loop for rows in options
		(loop with row-markup = nil
			  for row in (reply-options branch)
		 	  	 ;; Loop for cols in options
			  do (loop with button-markup
			   		   for col in row
			  		   when (getf row :data)
					   		do (setf (getf button-markup :|callback_data|) 
									 (getf row :data))
					   do (setf (getf button-markup :|text|) 
					   		    (getf row :text)) 
					   do (push button-markup row-markup))
			  do (push (reverse row-markup) buttons-markup))
		buttons-markup))


#| Markup Types |#

(defclass keyboard-markup-rs (reply-markup-type) ()) 

(defmethod compile-reply-markup ((markup keyboard-markup-rs) reply-options)
	``(:|reply_markup| (
		:|keyboard| ,(get-reply-buttons reply-options)
		:|resize_keyboard| t)))