(in-package :hook-declarations)

(defmethod api-response:on-command ((update-inst update) 
									(command (eql :start))
									text)
	(declaim (ignorable text))
	(api-response:reply "Command received!"))