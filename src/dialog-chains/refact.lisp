(defclass dialog-branch-meta ()
	((breadcrumbs :documentation "Shortest path to any given branch from the initial one") 
	 (render-action :documentation "Action to take place once user selects ")))

(defclass dialog-branch ()
	(branch-message 
	 (resize-keyboard :initform t)))

(defmethod render-user-interface ((chain dialog-chain))
	(api:send-message (api:get-chat-id)
                  (branch-message chain)
                  '(:|reply_markup| (
                        :|keyboard| (
                            ((:|text| "Сгенерировать шаблонные документы"))
                            ((:|text| "Взаимодействовать с сервисом в интернете")))
                        :|resize_keyboard| t))))

(defmethod on-branch-select ((chosen-branch dialog-branch) (previous-branch dialog-branch))
	)

(defclass branch-initial-meta (dialog-branch-meta)
	())
(defclass branch-initial-instance (dialog-branch))
(defclass plain-choice (dialog-branch))
(defclass multiple-backlinks (dialog-branch))
(defclass has-inline-keyboard (dialog-branch))
(defclass has-menu-keyboard (dialog-branch))
(defclass rendered-options (dialog-branch))
(defclass refresh-choise (dialog-branch))

(defclass dialog-env ()
	((response-plist :initarg ) (user-plist ) user-db dialog-state-db ))

(defclass branch-initial (plain-choice)
	((branch-message :initform (format nil "Этот бот может сгенерировать сразу несколько шаблонных документов ~
                               		 для группы людей, подставив их данные в необходимые места.~%~@
                               		 Он также может взаимодействовать с другими приложениями, сервисами и ~
                               		 сайтами.~%~% Для демонстрации функционала, предоставленные Вами тестовые ~
                               		 данные будут выгружены на сайт-заглушку: http://84.244.31.180"))
	 (keyboard-type :initform :|keyboard|)
	 (keyboard :initform '(
		((:|text| ""))
		((:|text| ""))
	 ))))

(defmethod initialize-instance :after ((branch branch-initial &key )))

(defclass branch-people-data ()
	())

(defmethod branch-message ((branch branch-people-data))
	(format nil "Этот бот может сгенерировать сразу несколько шаблонных документов ~
                               		 для группы людей, подставив их данные в необходимые места.~%~@
                               		 Он также может взаимодействовать с другими приложениями, сервисами и ~
                               		 сайтами.~%~% Для демонстрации функционала, предоставленные Вами тестовые ~
                               		 данные будут выгружены на сайт-заглушку: http://84.244.31.180"))

(defmethod branch-keyboard ((branch branch-people-data))
	)

(defun get-people-data)

(defvar *breadcrumbs* (list (list "person-dob" "person-middle" "person-first" "person-last") "people-data" "generate" "initial"))

(defun cancel-bread (list)
	(let ((stack-bread (first list)))
		(cond 
			((listp stack-bread)
				(if (cancel-bread stack-bread)
					(pop stack-bread)
					stack-bread))
			(t (pop list)))))

(defmacro remove-deep-bread (list)
	(let ()))
(first bread)