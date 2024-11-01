(in-package :tg-bot-api/body)


#| Branch Person Data Last Name |#

(defclass branch-person-data-last-name (branch-text-input) ())

(defmethod branch-message ((branch branch-person-data-last-name))
	(format nil "Введите фамилию:"))

(defmethod reply-markup-type ((branch branch-person-data-last-name))
	(make-instance 'inline-markup))

(defmethod reply-options ((branch branch-person-data-last-name))
	'(((:text "Отменить ввод данных"
		:action (:back)))))

(defmethod read-user-message ((branch branch-person-data-last-name))
	(cond 
		((string= (update:message-text) "")
			(api:text-back "Необходимо ввести фамилию!"))
		(t 
			(let ((person-data-temp (mito:find-dao 'person-data-temp 
									 :user-id (slot-value update:*user-db* 'id))))
				(setf (slot-value person-data-temp 'last-name) (update:message-text))
				(mito:save-dao person-data-temp))
			(run-action '(:next-branch 'branch-person-data-first-name)))))


#| Branch Person Data First Name |#

(defclass branch-person-data-first-name (branch-text-input) ())

(defmethod branch-message ((branch branch-person-data-first-name))
	(format nil "Введите имя:"))

(defmethod reply-markup-type ((branch branch-person-data-first-name))
	(make-instance 'inline-markup))

(defmethod reply-options ((branch branch-person-data-first-name))
	'(((:text "Назад"
		:action (:back)))
	  ((:text "Отменить ввод данных"
	  	:action (:cancel)))))

(defmethod read-user-message ((branch branch-person-data-first-name))
	(cond
		((string= (update:message-text) "")
			(api:text-back "Необходимо ввести имя!"))
		(t
			(let ((person-data-temp (mito:find-dao 'person-data-temp
									 :user-id (slot-value update:*user-db* 'id))))
				(setf (slot-value person-data-temp 'first-name) (update:message-text))
				(mito:save-dao person-data-temp))
			(run-action '(:next-branch 'branch-person-data-middle-name)))))


#| Branch Person Data Middle Name |#

(defclass branch-person-data-middle-name (branch-text-input) ())

(defmethod branch-message ((branch branch-person-data-middle-name))
	(format nil "Введите отчество:"))

(defmethod reply-markup-type ((branch branch-person-data-middle-name))
	(make-instance 'inline-markup))

(defmethod reply-options ((branch branch-person-data-middle-name))
	'(((:text "Назад"
		:action (:back)))
	  ((:text "Отменить ввод данных"
	  	:action (:cancel)))))

(defmethod read-user-message ((branch branch-person-data-middle-name))
	(let ((person-data-temp (mito:find-dao 'person-data-temp
									 :user-id (slot-value update:*user-db* 'id))))
				(setf (slot-value person-data-temp 'first-name) (update:message-text))
				(mito:save-dao person-data-temp))
	(run-action '(:next-branch 'branch-person-data-dob)))


#| Branch Person Data DOB |#

(defclass branch-person-data-dob (dialog-branch) ())

(defmethod branch-message ((branch branch-person-data-dob))
	(format nil "Введите дату рождения:"))

(defmethod reply-markup-type ((branch branch-person-data-dob))
	(make-instance 'inline-markup))

(defmethod reply-options ((branch branch-person-data-dob))
	`(,(date-data-page-render)
	  ((:text "Назад"
		:action (:back)))
	  ((:text "Отменить ввод данных"
	  	:action (:cancel)))))