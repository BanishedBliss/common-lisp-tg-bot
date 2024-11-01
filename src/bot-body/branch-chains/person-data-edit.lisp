(in-package :tg-bot-api/body)


#| Branch Person Edit Menu |#

(defclass branch-person-edit-menu (dialog-branch) ())

(defmethod branch-message ((branch branch-person-edit-menu))
	(let ((person-data-temp (mito:find-dao 'person-data-temp
				 						   :user-id (slot-value update:*user-db* 'id))))
		(format nil "Редактирование тестовых данных: ~%~
				 ФИО: ~A ~A ~A~%~
				 Дата рождения: ~A" 
				 (list 
				 	(slot-value person-data-temp 'last-name)
					(slot-value person-data-temp 'first-name)
					(slot-value person-data-temp 'middle-name)
					(slot-value person-data-temp 'date-of-birth)))))

(defmethod reply-options ((branch branch-person-edit-menu))
	(((:text "Редактировать фамилию"
	   :action ()))))

#| Branch Person Data Edit Last Name |#

(defclass branch-person-edit-data-last-name (branch-person-data-last-name) ())

(defmethod branch-message ((branch branch-person-edit-data-last-name))
	(format nil "Введите новую фамилию:"))

(defmethod read-user-message ((branch branch-person-edit-data-last-name))
	(cond 
		((string= (update:message-text) "")
			(api:text-back "Необходимо ввести фамилию!"))
		(t 
			(let ((person-data-temp (mito:find-dao 'person-data-temp 
									 :user-id (slot-value update:*user-db* 'id))))
				(setf (slot-value person-data-temp 'last-name) (update:message-text))
				(mito:save-dao person-data-temp))
			(run-action '(:next-branch 'branch-person-edit-data-first-name)))))


#| Branch Person Data Edit First Name |#

(defclass branch-person-edit-data-first-name (branch-person-data-first-name) ())

(defmethod branch-message ((branch branch-person-edit-data-first-name))
	(format nil "Введите новое имя:"))

(defmethod reply-markup-type ((branch branch-person-edit-data-first-name))
	(make-instance 'inline-markup))

(defmethod reply-options ((branch branch-person-edit-data-first-name))
	'(((:text "Назад"
		:action (:back)))
	  ((:text "Отменить ввод данных"
	  	:action (:cancel)))))

(defmethod read-user-message ((branch branch-person-edit-data-first-name))
	(cond
		((string= (update:message-text) "")
			(api:text-back "Необходимо ввести имя!"))
		(t
			(let ((person-data-temp (mito:find-dao 'person-data-temp
									 :user-id (slot-value update:*user-db* 'id))))
				(setf (slot-value person-data-temp 'first-name) (update:message-text))
				(mito:save-dao person-data-temp))
			(run-action '(:next-branch 'branch-person-data-middle-name)))))


#| Branch Person Data Edit Middle Name |#

(defclass branch-person-edit-data-middle-name (branch-text-input) ())

(defmethod branch-message ((branch branch-person-edit-data-middle-name))
	(format nil "Введите отчество:"))

(defmethod reply-markup-type ((branch branch-person-edit-data-middle-name))
	(make-instance 'inline-markup))

(defmethod reply-options ((branch branch-person-edit-data-middle-name))
	'(((:text "Назад"
		:action (:back)))
	  ((:text "Отменить ввод данных"
	  	:action (:cancel)))))

(defmethod read-user-message ((branch branch-person-edit-data-middle-name))
	(let ((person-data-temp (mito:find-dao 'person-data-temp
									 :user-id (slot-value update:*user-db* 'id))))
				(setf (slot-value person-data-temp 'first-name) (update:message-text))
				(mito:save-dao person-data-temp))
	(run-action '(:next-branch 'branch-person-data-dob)))


#| Branch Person Data Edit DOB |#

(defclass branch-person-edit-data-dob (dialog-branch) ())

(defmethod branch-message ((branch branch-person-edit-data-dob))
	(format nil "Введите дату рождения:"))

(defmethod reply-markup-type ((branch branch-person-edit-data-dob))
	(make-instance 'inline-markup))

(defmethod reply-options ((branch branch-person-edit-data-dob))
	`(,(date-data-page-render)
	  ((:text "Назад"
		:action (:back)))
	  ((:text "Отменить ввод данных"
	  	:action (:cancel)))))

(defclass branch-person-edit-first-name (dialog-branch))