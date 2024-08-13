(in-package :api-response)

(defstruct (bot-command 
	(:constructor %extract-command))
	command
	text)

(defun extract-command (message-text message-entity)
	(%extract-command 
		:command (values (intern 
					(subseq message-text 0 (entity-length message-entity)) 
					"KEYWORD"))
		:text (subseq m-text (1+ (entity-length entity)))))