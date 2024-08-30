(in-package :tg-bot-lib)

#| Abstract |#

(defclass dialog-input ()
	((user :accessor user :initarg user)
	 (dialog-state :accessor dialog-state :initarg nil)
	 (message :initarg message)
	 (input :accessor input)))

(defmethod initialize-instance :after ((input dialog-input) &rest args)
	(setf (dialog-state input) 
		  (mito:find-dao 'dialog-state 
		  				 :user-id (id (user input)))))

(defclass dialog-input-type ()
	(()))

(defclass dialog-keyboard-button (dialog-input-type)
	((text )))

(defclass dialog-keyboard-callback (dialog-input-type)
	((data )))

(defclass dialog-chain ()
	((render-action :initform nil)
	 (backlink :initform nil)
	 (backlink-action :initform nil)
	 (cancel-link :initform nil)
	 (cancel-link-action :initform nil)))

(defmethod backlink-dialog ((chain dialog-chain) (input dialog-input) &rest args)
	(setf (slot-value user 'dialog-input) "initial")
	(backlink-action chain)
	(render (back-link chain)))

(defmethod cancel-dialog ((chain dialog-chain) &rest args)
	(cancel-link-action chain)
	(render (cancel-link chain)))


#| Constructors |#

(defun make-callback-chain (user callback-plist)
	(make-instance 'dialog-input 
				   :user user 
				   :bot-message-id (get-bot-dialog-message callback-plist)
				   :input (make-instance 'dialog-keyboard-callback 
								 		 :data (getf callback-plist :|data|))))

(defun make-text-chain (user message-plist)
	(make-instance 'dialog-input 
				   :user user
				   :bot-message-id (mito:) 							;; TODO
				   :input (make-instance 'dialog-keyboard-button 
				   						 :text (getf message-plist :|text|)))) 

(defun get-bot-dialog-message (callback-plist)
	(let ((may-be-inaccessible-message (getf callback-plist :|message|)))
		(cond 
			((eql (getf may-be-inaccessible-message :|date|) 0)
				nil)
			(t (getf may-be-inaccessible-message :|message_id|)))))


#| Dialog chains |#

(defclass chain-initial (dialog-chain)
	(render-action "initial text"))

(defclass chain-generate (dialog-chain)
	(message "generate text"))

(defclass chain-interact (dialog-chain))

(defclass chain-people-data (dialog-chain)
	((back-link )
	 (message ) ))

(defclass chain-interact-people-data (dialog-chain))

#| Dialog Breadcrumbs |#

(defun init-dialog-branches ()
	(let ((breadcrumb-index nil))
		(loop for branch in *dialog-branches*
			do (push (get-outgoing-breadcrumbs)
					 breadcrumb-index))))

(defun get-outgoing-breadcrumbs ()
	)

(defvar *dialog-branches* (list 
	(:key :|initial| 
		  :text "welcome"
		  :type :|branch|
		  :link-type :|keyboard|
		  :links (list '(:key :|generate| :text "generate") 
		  			   '(:key :|interact| :text "interact"))
		  :has-back nil
		  :is-initial t)
	(:key :|generate| 
		  :link-type :|keyboard|
		  :type :branch
		  :links (list '(:key :|people-data| :text "people-data") 
		  			   '(:key :|run-generate| :text "run-generate")) 
		  :has-back t)
	(:key :|interact| 
		  :link-type :|keyboard|
		  :type :|branch|
		  :links (list '(:key :|people-data| :text "people-data") 
		  			   '(:key :|run-interact| :text "run-interact")) 
		  :has-back t)
	(:key :|run-generate|
		  :links "Generate finished. Here are files:"
		  :link-type :|keyboard|
		  :has-back t
		  :has-home t)
	(:key :run-interact 
		  :text "Interact finished"
		  :link-type :|keyboard|
		  :has-back t
		  :has-home t)
	(:key :|people-data| 
		  :link-type :|inline|
		  :links (list `(:key :|people-data-page| :multiple (people-data-page-renderer)))
		  :has-back t
		  :back-text "Save and return")
	(:key :|person-data-last-name|
		:link-type :|inline|
		:input-handler '(person-data-last-name-input)
		:next :|person-data-first-name|
		:has-back t)
	(:key :|person-data-first-name|
		:link-type :|inline|
		:input-handler '(person-data-first-name-input)
		:next :|person-data-middle-name|
		:has-back t
		:has-cancel t
		:cancel-text "Отменить добавление")
	(:key :|person-data-middle-name|
		:link-type :|inline|
		:input-handler '(person-data-middle-name-input)
		:next :|person-data-date|
		:has-back t
		:has-cancel t
		:cancel-text "Отменить добавление")
	(:key :|person-data-date|
		:link-type :|inline|
		:input-handler '(person-data-date-input)
		:has-back t
		:has-cancel t
		:cancel-text "Отменить добавление")
))

(defvar *branches* (list 
	(:name "base-branch" :path (
		:|initial| :|generate| :|people-data| :|add-person| 
	))))

(defvar *dialog-sections* (list
	(:name "base-section" :type :places (list 
		:|initial|)
	())))


(defun people-data-page-renderer ()
	;; Aquire necessary information for the menu
	(let* ((current-user-db-id  		(slot-value update:*user-db* 'id))
		   (people-data-offset-value  	(slot-value update:*dialog-state-db* 'people-data-offset))
		   (people-per-page 			(env:get-env :people-data-per-page))
		   (people-per-user				(env:get-env :max-people-data-per-user))
		   (people-data-count 			(mito:count-dao 'person-data
											(where (:= :creator-id current-user-db-id))))
		   (people-data 				(mito:select-dao 'person-data
											(where (:= :creator-id current-user-db-id))
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