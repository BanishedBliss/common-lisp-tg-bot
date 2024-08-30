;;; Contains hooks registration
(in-package :tg-bot-api)

(defclass command-start (command-input) ())
(defmethod on-command ((command command-start))
    "Receives '/start' command. 
     Resets dialog state, erases user data. Sends initial dialog options"
    (branch-initial 
        (db-util:init-user(getf update:*current-user* :|id|))
        (update-plist command)))

(defmethod on-message (update-plist text)
    (format t "Dialog state: ~A~%" (slot-value update:*user-db* 'dialog-branch))
    (print "Message received:")
    (prin1 text)
    
    (alexandria:switch ((slot-value update:*user-db* 'dialog-branch) 
                        :test #'equal)
        ("initial"  (response-initial update-plist text))
        ("generate" (response-generate update-plist text))
        ("interact" (response-interact update-plist text))))

(defun response-initial (update-plist text)
    (alexandria:switch (text :test #'equal)
        ("Сгенерировать шаблонные документы"
            (branch-initial-generate update-plist))
        ("Взаимодействовать с сервисом в интернете"
            (branch-initial-interact update-plist))))

(defun response-generate (update-plist text)
    (if (slot-value update:*user-db* 'dialog-layer)
        (if (slot-value update:*user-db* 'dialog-data)
            (alexandria:switch (text :test #'equal)
                ("Отмена"
                    ( ))))
        (alexandria:switch (text :test #'equal)
            ("Назад"
                (branch-initial update-plist)))))

(defun response-interact (update-plist text)
    (alexandria:switch (text :test #'equal)
        ("Назад"
            (branch-initial update-plist))))

(defun branch-initial (update-plist)
    (setf (slot-value update:*user-db* 'dialog-branch) "initial")
    (mito:save-dao update:*user-db*)

    (api:send-message (api:get-chat-id)
                  (format nil "Этот бот может сгенерировать сразу несколько шаблонных документов ~
                               для группы людей, подставив их данные в необходимые места.~%~@
                               Он также может взаимодействовать с другими приложениями, сервисами и ~
                               сайтами.~%~% Для демонстрации функционала, предоставленные Вами тестовые ~
                               данные будут выгружены на сайт-заглушку: http://84.244.31.180")
                  '(:|reply_markup| (
                        :|keyboard| (
                            ((:|text| "Сгенерировать шаблонные документы"))
                            ((:|text| "Взаимодействовать с сервисом в интернете")))
                        :|resize_keyboard| t))))

(defun branch-initial-generate (update-plist)
    (setf (slot-value update:*user-db* 'dialog-branch) "generate")
    (setf (slot-value update:*user-db* 'dialog-layer) nil)
    (setf (slot-value update:*user-db* 'dialog-page) nil)
    (mito:save-dao update:*user-db*)

    (api:send-message (api:get-chat-id)
                  (format nil "Для генерации шаблонных документов нужно добавить тестовые данные людей.~@
                               Если Вы этого ещё не сделали или хотите отредактировать их список, ~
                               выберите соответствующую опцию на данном этапе.")
                  `(:|reply_markup| (
                        :|keyboard| (
                            ((:|text| "Добавить/редактировать данные"))
                            ((:|text| "Сгенерировать документы"))
                            ((:|text| "Назад")))
                        :|resize_keyboard| t))))

(defun branch-initial-interact (update-plist)
    (setf (slot-value update:*user-db* 'dialog-branch) "interact")
    (setf (slot-value update:*user-db* 'dialog-layer) nil)
    (setf (slot-value update:*user-db* 'dialog-page) nil)
    (mito:save-dao update:*user-db*)

    (api:send-message (api:get-chat-id)
                    (format nil "Для взаимодействия с сервисом в интернете нужно добавить тестовые данные людей.~@
                                Если Вы этого ещё не сделали или хотите отредактировать их список, ~
                                выберите соответствующую опцию на данном этапе.")
                    `(:|reply_markup| (
                        :|keyboard| (
                            ((:|text| "Добавить/редактировать данные"))
                            ((:|text| "Отправить данные на сайт"))
                            ((:|text| "Назад")))
                        :|resize_keyboard| t))))

(defun branch-data-list (user update-plist)
    (setf (slot-value update:*user-db* 'dialog-layer) "data")
    (setf (slot-value update:*user-db* 'dialog-page) 1)
    (setf (slot-value update:*user-db* 'dialog-data) nil)
    (mito:save-dao update:*user-db*)
    
    (api:send-message (api:get-chat-id)
                    (format nil "На этапе добавления тестовых данных Вы можете добавить тестовые данные ~
                                 человека и редактировать их. ~%~%Список добавленных людей отобразится под ~
                                 данным сообщением. ~%~%Внимание! Не используйте реальные данные людей! ~
                                 В случае выгрузки на сайт-заглушку они могут быть скомпрометированы! ~
                                 Сайт использует незащищённое соединение и существует ~
                                 исключительно в демонстративных целях!")
                    `(:|reply_markup| (
                        :|keyboard| (
                            ((:|text| "Добавить новые данные"))
                            ((:|text| "Назад")))
                        :|inline_keyboard| (
                            ((:|text| "Тест двойной клавиатуры"))
                        )))))