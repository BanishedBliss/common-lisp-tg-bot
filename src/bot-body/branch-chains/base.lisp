(in-package :tg-bot-api/body)

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