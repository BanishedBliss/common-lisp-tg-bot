(in-package :api-response)

(defstruct (bot-command 
	(:constructor %extract-command))
	command
	text)

(defun extract-command (message-text enitity-length)
	(%extract-command 
		:command (values (intern 
					(subseq message-text 1 enitity-length) 
					"KEYWORD"))
		:text (subseq message-text (1+ enitity-length))))