(in-package :api-response)

(defclass has-raw-plist () 
	((raw-plist
		:accessor raw-plist 
		:initarg :plist)))

(defmethod raw-value (indicator (obj has-raw-plist))
	(getf (raw-plist obj) indicator))