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
		:action ((:next-branch 'branch-people-data))))
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
		:action ((:next-branch 'branch-people-data))))
	  ((:text "Назад" 
	    :action (:back))
	   (:text "Отправить данные" 
	    :action (:next-branch 'branch-interact-finish)))))


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
	`(,(people-data-page-renderer)
	  ((:text "Назад"
	   	:action (:back))
	   (:text "Добавить"
	    :action ((:next-branch 'person-data-last-name))))))


#| Person Data Last Name |#

(defclass branch-person-data-last-name (branch-text-input))

(defmethod branch-message ((branch branch-person-data-last-name))
	(format nil "Введите фамилию:"))

(defmethod reply-markup-type ((branch branch-people-data))
	(make-instance 'inline-markup))

(defmethod reply-options ((branch branch-person-data-last-name))
	'(((:text "Отменить ввод данных"
		:action (:back)))))

(defmethod read-user-message ((branch person-data-last-name))
	(case 
		((string= (update:message-text) "")
			(api:text-back "Необходимо ввести фамилию!"))
		(t 
			(let ((person-data-temp (mito:find-dao 'person-data-temp 
											:user-id (slot-value update:*user-db* 'id))))))))