(defclass value-eql (trigger) 
	((key :initarg key)
	 (value :initarg value)
	 (value-type :initform )
	 (update-type :initarg update-type)
	 (parents :initarg parents)))

