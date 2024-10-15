(defclass command-start (command-input) ())
(defmethod on-command ((command command-start))
    "Receives '/start' command. 
     Resets dialog state, erases user data. Sends initial dialog options"
    (db-util:reset-dialog-state)
	(update-user-dialog (make-instance 'branch-initial)))

(defmethod on-message ((message message-input))
	"On received message read message as raw text input or a selected keyboard option, 
	 depending on the dialog state."
	(or (and (subtypep (class-of update:*current-branch*) 
				  	   (find-class 'branch-text-input))
			 (read-user-message update:*current-branch*)))
		(option-action-by-text update:message-text))

(defmethod on-callback-button ((callback callback-button-input))
	(option-action-by-data update:callback-data))


#| Branch Initial |#

(defclass branch-initial (dialog-branch) ())

(defmethod branch-message ((branch branch-initial))
	(format nil "Этот бот может сгенерировать сразу несколько шаблонных документов ~
				 для группы людей, подставив их данные в необходимые места.~%~@
				 Он также может взаимодействовать с другими приложениями, сервисами и ~
				 сайтами.~%~% Для демонстрации функционала, предоставленные Вами тестовые ~
				 данные будут выгружены на сайт-заглушку: http://84.244.31.180"))

(defmethod reply-options ((branch branch-initial))
	'(((:text "Сгенерировать шаблонные документы" 
		:action ((:next-branch 'branch-generate))))
	  ((:text "Взаимодействовать с сервисом в интернете" 
		:action ((:next-branch 'branch-interact))))))


#| Branch Generate |#

(defclass branch-generate (dialog-branch) ())

(defmethod branch-message ((branch branch-generate))
	(format nil "Для генерации шаблонных документов нужно добавить тестовые данные людей.~%~%~
				 Если Вы этого ещё не сделали или хотите отредактировать их список, ~
				 выберите соответствующую опцию на данном этапе."))

(defmethod reply-options ((branch branch-generate))
	'(((:text "Добавить данные"
		:action ((:next-chain 'branch-people-data))))
	  ((:text "Назад"
	    :action (:back))
	   (:text "Сгенерировать"
	    :action ((:next-branch 'branch-generate-finish))))))


#| Branch Interact |#

(defclass branch-interact (dialog-branch) ())

(defmethod branch-message ((branch branch-interact))
	(format nil "Для взаимодействия с сервисом в интернете нужно добавить тестовые данные людей.~%~%~
				 Если Вы этого ещё не сделали или хотите отредактировать их список, ~
				 выберите соответствующую опцию на данном этапе."))

(defmethod reply-options ((branch branch-interact))
	'(((:text "Добавить данные"
		:action ((:next-chain 'branch-people-data))))
	  ((:text "Назад" 
	    :action (:back))
	   (:text "Отправить данные" 
	    :action ((:next-branch 'branch-interact-finish))))))


#| Branch People Data |#

(defclass branch-people-data (dialog-branch) ())

(defmethod branch-message ((branch branch-people-data))
	(format nil "Ваши тестовые данные.~% ~
				 Всего записей: ~A~%~%~" 
				(mito:count-dao 'person-data 
					(where (:= :user-id 
							   (slot-value update:*user-db* 'id))))))

(defmethod reply-markup-type ((branch branch-people-data))
	(make-instance 'inline-markup))

(defmethod reply-options ((branch branch-people-data))
	`(,(people-data-page-render)
	  ((:text "Назад"
	   	:action (:back))
	   (:text "Добавить"
	    :action ((:next-chain 'branch-person-data-last-name))))))


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

#| Branch Interact Finish |#

(defclass branch-interact-finish (dialog-branch) ())

(defmethod branch-message ((branch branch-interact-finish))
	(format nil ""))		; TODO

(defmethod reply-options ((branch branch-interact-finish))
	'(((:text "В начало"
		:action ((:next-branch 'branch-initial))))))


#| Branch Generate Finish |#

(defclass branch-generate-finish (dialog-branch) ())

(defmethod branch-message ((branch branch-generate-finish))
	(format nil ""))		; TODO

(defmethod reply-options ((branch branch-generate-finish))
	'(((:text "В начало"
		:action ((:next-branch 'branch-initial))))))