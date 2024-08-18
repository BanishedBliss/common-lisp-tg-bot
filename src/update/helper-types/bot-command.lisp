(in-package :tg-bot-api)

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

(defun get-bot-command-length (entities-plist)
    "Looks through message entities array and returns bot command length or nil if none found."
	(loop for array-element in entities-plist
		when (eql (getf array-element :|type|) "bot_command")
		return (getf array-element :|length|)))