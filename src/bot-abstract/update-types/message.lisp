(in-package :tg-bot-api)

(defgeneric on-command (command-input))
(defgeneric on-message (message-input))
(defmethod  no-applicable-method (on-command &rest rest)
    (api:text-back "Я не знаю такую команду."))

(defmethod eval-update-hooks ((update-type (eql :|message|)))
	"Evaluates updates of Message type."
    (let ((dialog-input (make-instance 'message-input)))
        (or (read-input-command dialog-input)
            (read-input-message dialog-input))))

(defmethod read-input-command ((dialog-input message-input))
    "Identifies user input as a bot command or returns nil."
    (and (extract-command dialog-input (get-bot-command-length dialog-input))     
         (on-command dialog-input)))

(defun get-bot-command-length (dialog-input)
    "Looks through message entities array and returns bot command length or nil if none found."
	(loop for array-element in update:*current-update*
		when (and (eql (getf array-element :|offset|) 0)
				  (string= (getf array-element :|type|) 
                           "bot_command"))
		return (getf array-element :|length|)))

(defmethod extract-command ((dialog-input message-input) entity-length)
    "Extracts a command from message text"
    (and entity-length
         (change-class dialog-input 'command-input 
                       :name (values (intern (string-upcase 
                                (subseq (update:message-text) 1 entity-length)) 
                                "KEYWORD"))
                       :text (if (< entity-length (length (update:message-text))) 
                                   (subseq (update:message-text) (1+ entity-length))
                                   ""))))

(defmethod read-input-message ((dialog-input message-input))
    "Identifies user input as non-empty message"
    (on-message (change-class dialog-input 'text-input)))

