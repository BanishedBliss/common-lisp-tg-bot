(in-package :tg-bot-api)

#| 
1. Main long poll loop
2. Response state actions
3. Response integrity checks
4. Failsafe for unsupported update type
|#

#| Main long poll loop |#

(setf drakma:*drakma-default-external-format* :UTF8)

(defun long-poll-updates ()
    "Top-level loop. Repeatedly sends requests to get updates for a given bot."
    ; Sets a variable for storing the last processed updates's ID.
    (let ((offset 0)) (loop
        (let* ((api-answer   	(api:get-updates-request offset))
               (response-plist 	(jonathan:parse 
                             		(flexi-streams:octets-to-string 
										api-answer))))

            (print "Parsed plist:")	; TODO: Remove debug code.
            (prin1 response-plist)

            ;; Validate response integrity and look for any results.
            (let ((response-state (make-instance 'response-state)))
				(and (response-ok-check response-state (getf response-plist :|ok|))
					 (response-results-check response-state (getf response-plist :|result|)))
				;; Fire an appropriate action for response state.
				(response-state-action response-state response-plist)
				;; Modify offset parameter to get next updates.
                (when (getf response-data :has-results)
                    (setf offset 
                        (1+ (getf response-data :last-update-id)))))))))



#| Response state actions |#

(defmethod response-state-action 
	((state response-has-results) response-plist)
	"Apropriate action for response with results"
	"Evaluates individual updates' hooks and finds the last update's ID"
	(let ((updates-list (getf response-plist :|result|))
		  (updates-ids '()))

		(loop 
			:for (update-type update-plist update-id-key update-id) 
			:in updates-list
			:do (push update-id updates-ids)
			:do (update:init update-plist)
			:do (eval-update-hooks update-type update-plist))
			
		(update:destroy)
		(setf (last-update-id state) 
		      (first updates-ids))))

(defmethod response-state-action 
	((state response-no-results) response-plist)
	"Apropriate action for response with no results."
	(srv-util:log-data "No results received."))

(defmethod response-state-action 
	((state response-not-ok) response-plist)
	"Apropriate action for response with OK value 'false'.
	 Collects errors received in JSON, formats and logs them."
	(let* ((error-entries '())
		   (error-strings '())
		   (errors-plist (getf response-plist :|errors|))
		   (errors-descriptions (getf response-plist :|descriptions|)))
		;; Collect error codes and descriptions from JSON
		(loop for (error-code error-cases) on errors-plist by #'cddr
			do (loop for (error-case error-array) on error-cases by #'cddr
					do (push (list  error-code 
							   		error-case 
							   		(getf errors-descriptions error-case)) 
						error-entries)))
		;; Log errors collected
		(srv-util:log-data 
            (format nil "~{Error: ~S - ~S - ~S~^~%~}" error-entries))))

(defmethod response-state-action 
	((state malformed-response) response-plist)
	"Apropriate action for response with no OK value received."
	(srv-util:log-data "Received malformed JSON-response while long polling."))



#| Response integrity checks |#

(defmethod response-ok-check ((state response-state) ok-value)
	"Checks for presence of OK and its value in response."
	(and ok-value
		(change-class state 'response-has-ok)
		(and ok-value
			(change-class state 'response-is-ok))))

(defmethod response-results-check ((state response-state) result-value)
	"Checks for presence of results in response."
	(and (listp result-value)
		 (< 0 (length result-value)
		 (change-class state 'response-has-results))))



#| Failsafe for unsupported update type |#

(defmethod eval-update-hooks ((update-type t) update-plist)
    "Handle unsupported update types."
	(srv-util:log-data (format nil "Update of type ~A was received and not handled." update-type)))


#| 
(defun long-poll-updates ()
    "Top-level loop. Repeatedly sends requests to get updates for a given bot."
    ; Sets a variable for storing the last processed updates's ID.
    (let ((offset 0)) (loop
        (let* ((api-answer   (api:get-updates-request offset))
               (parsed-plist (jonathan:parse 
                             	(flexi-streams:octets-to-string api-answer))))

            (print "Parsed plist:")
            (prin1 parsed-plist)

            ;; Read response and modify offset parameter to get next updates.
            (let ((response-data (read-updates parsed-plist)))
                (when (getf response-data :has-results)
                    (setf offset 
                        (1+ (getf response-data :last-update-id)))))))))

(defun read-updates (response-plist)
	"Reads the incoming long poll response: 
     checks for response validity/errors, 
     proceeds to an appropriate action."
	(let ((response-data (check-integrity response-plist)))
		(cond 
			((getf response-data :has-ok) 
				(cond ((getf response-data :is-ok)
					;; Evaluate updates on successful poll
					(cond 
						((getf response-data :has-results)
							(setf (getf response-data :last-update-id) 
								  (eval-updates response-plist)))
						(t 
							(srv-util:log-data "No results received."))))
					(t (log-errors response-plist))))
		  	(t (srv-util:log-data "Received malformed JSON-response while long polling.")))
        response-data))

(defun check-integrity (response-plist)
	"Runs checks for valid JSON received, success/faliure and presence of new updates.
	 Returns a plist of checks passed/failed."
	(let ((checks (list :has-ok nil 
						:is-ok nil 
						:has-results nil)))

		(loop :for  (indicator value) on response-plist by #'cddr
			  ;; If successful response:
			  :when (eql indicator :|ok|)
			  :do   (progn 
			  		    (setf (getf checks :has-ok) t)
			  		    (when (eql value t)
			  		    	(setf (getf checks :is-ok) t)))
			  ;; If any results:
			  :when (and (eql indicator :|result|)
			  			 (listp value)
			  			 (< 0 (length value)))
			  :do   (setf (getf checks :has-results) t))

		checks))

(defun eval-updates (response-plist)
	"Evaluates individual updates' hooks and returns the last update's ID"
	(let ((updates-list (getf response-plist :|result|))
          (updates-ids '()))

		(loop 
            :for    (update-type 
                     update-plist 
                     update-id-key 
                     update-id) 
            :in updates-list
			:do (push update-id updates-ids)
	        :do (setf *current-update* update-plist)
			:do (setf *current-user* (getf update-plist :|from|))
			:do (setf *current-user-db* (db-util:init-user))
            :do (eval-update-hooks update-type update-plist))
		
		(setf )
		(setf *current-user* nil)
        (setf *current-update* nil)
        (first updates-ids)))

(defun log-errors (response-plist)
	"Collects errors received in JSON, formats and logs them."
	(let* ((error-entries '())
		   (error-strings '())
		   (errors-plist (getf response-plist :|errors|))
		   (errors-descriptions (getf response-plist :|descriptions|)))
		;; Collect error codes and descriptions from JSON
		(loop for (error-code error-cases) on errors-plist by #'cddr
			do (loop for (error-case error-array) on error-cases by #'cddr
					do (push (list  error-code 
							   		error-case 
							   		(getf errors-descriptions error-case)) 
						error-entries)))
		;; Log errors collected
		(srv-util:log-data 
            (format nil "~{Error: ~S - ~S - ~S~^~%~}" error-entries))))
|#