(in-package :tg-bot-api)

(defstruct (bot-command 
	(:constructor %extract-command))
	name
	text)

(defun extract-command (message-text enitity-length)
	(%extract-command 
		:name (values 
				(intern
					(string-upcase (subseq message-text 1 enitity-length)) 
				"KEYWORD"))
		:text (if (< enitity-length (length message-text)) 
					(subseq message-text (1+ enitity-length))
					"")))

(defun get-bot-command-length (entities-plist)
    "Looks through message entities array and returns bot command length or nil if none found."
	(loop for array-element in entities-plist
		when (and (eql (getf array-element :|offset|) 0)
				  (string= (getf array-element :|type|) "bot_command"))
		return (getf array-element :|length|)))