(defun people-data-page-renderer ()
	;; Aquire necessary information for the menu
	(let* ((people-data-offset-value  	(slot-value update:*dialog-state-db* 'people-data-offset))
		   (people-per-page 			(env:get-env :people-data-per-page))
		   (people-per-user				(env:get-env :max-people-data-per-user))
		   (people-data-count 			(mito:count-dao 'person-data
											(where (:= :creator-id (slot-value update:*user-db* 'id)))))
		   (people-data 				(mito:select-dao 'person-data
											(where (:= :creator-id (slot-value update:*user-db* 'id)))
											(limit people-per-page)
											(offset people-data-offset-value))))
		;; Add aquired people data to menu and append nav buttons
		(loop with people-list = nil 
		      for person-data in people-data
			  do (push (list (list
								:key (write-to-string (slot-value person-data 'id)) 
								:text (get-person-name-and-dob person-data))) 
					   people-list)
			  finally (return (cond 
			  					;; Nav buttons are needed
								((< people-per-page people-data-count)
									(let ((nav-buttons nil)) 
										;; Prev button if needed
										(when (< 0 people-data-offset-value)
											(push (get-prev-button) nav-buttons))
										;; Page number
										(get-page-number people-data-offset-value
														 people-per-page)
										;; Next button if needed
										(when (< (- people-data-count 
													people-data-offset-value) 
												 people-per-page)
											(push (get-next-button )))
										;; Render and return people menu
										(t 	(if nav-buttons 
												(push (list nav-buttons) 
														people-list))
											(reverse people-list))))
								;; Nav buttons are not needed. Return people menu
								(t (reverse people-list)))))))

(defun get-person-name-and-dob (person-data)
	(concatenate 'string 
				 (string-trim 
					(format nil "~{~A~^ ~}" (list
						(slot-value person-data 'last-name)
						(slot-value person-data 'first-name)
						(slot-value person-data 'middle-name))))
				 "-"
				 (slot-value person-data 'date-of-birth)))

(defun get-prev-button ()
	(list :key "prev"
		  :text "пред."))

(defun get-page-number (offset per-page)
	(list :key "page-number"
		  :text (concatenate 'string 
							 (write-to-string (+ 1 (/ offset per-page)))
							 " стр.")))

(defun get-next-button ()
	(list :key "next"
		  :text "след."))