(defclass command-start (command-input) ())
(defmethod on-command ((command command-start))
    "Receives '/start' command. 
     Resets dialog state, erases user data. Sends initial dialog options"
    (db-util:reset-dialog-state)
	(update-dialog-state (make-instance 'branch-initial)))

(defmethod on-message ((message message-input))
	
	(let ((input-branch 
			(make-instance (slot-value *dialog-state-db* 'branch)))
		)))

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
		:action (:next-branch 'branch-generate)))
	  ((:text "Взаимодействовать с сервисом в интернете" 
		:action (:next-branch 'branch-interact)))))