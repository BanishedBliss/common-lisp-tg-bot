(in-package :tg-bot-api)

(defparameter *current-update* nil)

(defun long-poll-updates ()
    "Top-level loop. Repeatedly sends requests to get updates for a given bot."
    ; Sets a variable for storing the last processed updates's ID.
    (let ((offset 0)) (loop
        (let* ((api-answer  (get-updates-request offset))
               (parsed-plist (jonathan:parse 
                             (flexi-streams:octets-to-string api-answer))))

            (print "Parsed plist:")
            (prin1 parsed-plist)

            ;; Read response and modify offset parameter to get next updates.
            (let ((response-data (read-updates parsed-plist)))
				(print "Response-data log:")
				(terpri)
				(prin1 response-data)
				(terpri)
                (when (getf response-data :has-results)
					(print "Check passed.")
                    (setf offset 
                        (1+ (getf response-data :last-update-id)))))))))

(defun get-updates-request (offset) 
    "Sends request to Telegram Bot API to receive latest bot updates."
    (drakma:http-request 
        (concatenate 'string (get-api-url "getUpdates")
                             "?timeout=5&offset="
                             (write-to-string offset))
        :method :get
        :connection-timeout 15))

(defun read-updates (response-plist)
	"Reads the incoming long poll response: 
     checks for response validity/errors, 
     proceeds to an appropriate action."
	(let ((response-data (check-integrity response-plist)))

		(cond ((getf response-data :has-ok) 
				(cond ((getf response-data :is-ok)
							;; Evaluate updates on successful poll
							(cond 
								((getf response-data :has-results)
									(setf (getf response-data :last-update-id) 
									      (eval-updates response-plist)))
								(t 
									(log-data "No results received."))))
					  (t (log-errors response-plist))))
		  (t (log-data "Received malformed JSON-response while long polling.")))
        
        response-data))

(defun check-integrity (response-plist)
	"Runs checks for valid JSON received, success/faliure and presence of new updates.
	 Returns a plist of checks passed/failed."
	(let ((checks '(:has-ok nil 
					:is-ok nil 
					:has-results nil)))

		(loop for (indicator value) on response-plist by #'cddr
			  ;; If successful response:
			  when  (eql indicator :|ok|)
			  do    (progn 
			  		    (setf (getf checks :has-ok) t)
			  		    (when (eql value t)
			  		    	(setf (getf checks :is-ok) t)))
			  ;; If any results:
			  when  (and (eql indicator :|result|)
			  			(listp value)
			  			(< 0 (length value)))
			  do    (setf (getf checks :has-results) t))

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
            :do (eval-update-hooks update-type update-plist))
		
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
		(log-data 
            (format nil "~{Error: ~S - ~S - ~S~^~%~}" error-entries))))