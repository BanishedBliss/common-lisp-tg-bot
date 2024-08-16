(in-package :api-response)

(defclass hook-evaluation (has-raw-plist) 
	())

(defmethod make-instance :after ((h-eval hook-evaluation))
	)

(defclass connection () 
	(indicator :accessor indicator)
	(c-type :accessor c-type))

(defmethod set-key ((con-inst connection) indicator)
	(setf (indicator con-inst) indicator))

(defmethod set-value-type ((con-inst connection) value)
	(setf (c-type con-inst) :array))

(defmethod read-value-type ((con-inst connection) value)
	"Determines JSON value type, associated with a key"
	(cond 
		((listp value)
			(cond 
				((listp (car value))
					(set-value-type con-inst :array))
				(t 
					(set-value-type con-inst :object))))
		(t 
			(set-value-type con-inst :plain))))

(progn 
	(:in :|entities| (:array)))

(defmethod eval-update ())

(defun on-command ()
	(getf :|entities|))

(defclass conditions () 
	())

(defun on-command (:start)
	(is :|message|)
	(has (:|entities| (:array )))
	())

(:in (:|entities| :array) :one ((eql :|type| "bot-command") (eql :|offset| 0)))

'(:when (((:|entities| :array) ) ))
'(:when (((:|entities| :array) :|type|) "bot_command"))
'(:location ((:|entities| :array) :|type|))

(defun start-update-analysis (update-type update-plist)
	(let ((connection (make-instance 'connection)))
		(loop for (indicator value) on update-plist
			do (set-key connection indicator)
			do (read-value-type connection value)
			do )))

(defclass search-chain ()
	((key :accessor key :initarg key)
	 (value-action :accessor value-action :initarg value-action)
	 ()))

(defclass search-chain-array 
	((key)
	 (with-elements)
	 (with-results)))

(defmethod next-chain-action ((s-chain search-chain) ))



(progn 
	(when (plist-key-exists key plist)
		(let ((k-value (getf plist key))))
			(if (listp k-value)
				(if (listp (first k-value))
					(case-1)
					(case-2))
				())))

(defun is-bot-command () 
	)

(defun )

(defun plist-key-exists (key plist) 
	"Determines if plist has the given key (non-recursively)."
	(loop for (indicator value) on plist
		when (eql indicator key)
		return t))

#| 
(defclass trigger)

(defclass array-has-one (trigger)
	(key :initarg key)
	())

(defclass value-eql (trigger)
	(key :initarg key)
	(value :initarg value)
	(update-type)
	(parents :initarg parents)

(deftype trigger '(member 
	:array-has-one
	:))

(defclass hook-trigger
	(type ))
break-point ((key)

has-bot-command '((:name :|entities| :type array :check :has-one))


on-command ((has-bot-command))
|#