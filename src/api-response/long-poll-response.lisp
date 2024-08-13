(in-package :api-response)

(defclass long-poll-response ()
	((raw-plist 
		:accessor raw-plist
		:initarg :plist 
		:initform (error "Must suply a JSON plist of a response."))
	 (updates 
	 	:accessor updates
		:initform '())
	 (last-update-id
	 	:accessor last-update-id
		:initform 0)
	 (has-ok :initform nil)
	 (is-ok :initform nil)
	 (has-results :initform nil :accessor has-results))
	 (:documentation ""))

(defmethod analyze-plist ((response-plist long-poll-response))
	"Reads JSON's basic information about request"
	(loop for (indicator value) on (raw-plist response-plist) by #'cddr
		do (check-integrity response-plist indicator value)))

(defmethod check-integrity ((response-plist long-poll-response) indicator value)
	"Checkes response's validity. Determines response type to decide on the course of action."
	;; OK status checks
	(when (eql indicator :|ok|) 
		(setf (slot-value response-plist 'has-ok) t)
		(when (eql value t)
			(setf (slot-value response-plist 'is-ok) t)))
	;; Results array checks
	(when (and (eql indicator :|result|)
			   (listp value)
			   (< 0 (length value)))
		(setf (has-results response-plist) t)))

(defmethod eval-plist ((response-plist long-poll-response))
	"Reacts to the type of response received"
	(cond ((slot-value response-plist 'has-ok) 
				(cond ((slot-value response-plist 'is-ok)
							;; Evaluate updates on successful poll
							(when (slot-value response-plist 'has-resuls)
								(eval-updates response-plist)))
					  (t (log-errors response-plist))))
		  (t (telegram-bot-api:log-data "Received malformed JSON-response while long polling."))))

(defmethod eval-updates ((response-plist long-poll-response))
	"Reads JSON results object and evaluates updates to lisp objects"
	(let (update-list (getf (raw-plist response-plist) :|result|)) 
		;; Push updates to api-response slot
		(loop for update in update-list
			do (push (make-instance 'update 
									:update-type (first update)
									:plist update)))
		;; Take note of the last update's ID
		(setf (last-update-id response-plist) 
			(getf (first (updates response-plist)) 
				  :|update_id|))
		;; Reverse updates' stack
		(nreverse (updates response-plist))))

(defmethod log-errors ((response-plist long-poll-response))
	"Collects errors received in JSON, formats and logs them."
	(let* ((error-entries '())
		   (error-strings '())
		   (errors-plist (getf (raw-plist response-plist) :|errors|))
		   (errors-descriptions (getf (raw-plist response-plist) :|descriptions|)))
		;; Collect error codes and descriptions from JSON
		(loop for (error-code error-cases) in errors-plist
			do (loop for (error-case error-array) in error-cases
					do (push `(,error-code 
							   ,error-case 
							   ,(getf errors-descriptions error-case)) 
							error-entries)))
		;; Log errors collected
		(telegram-bot-api:log data 
					(format nil "~{Error: ~S - ~S - ~S~^~%~}" error-entries))))