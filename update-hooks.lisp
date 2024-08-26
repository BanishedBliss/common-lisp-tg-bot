;;; Contains hooks registration
(in-package :tg-bot-api)

(defmethod on-command (update-plist (command (eql :start))
                                    text)
    "Receives '/start' command. 
     Resets dialog state, erases user data. Sends initial dialog options"
    (declare (ignorable text))
    (branch-initial 
        (init-user (getf *current-user* :|id|))
        update-plist))

(defmethod on-message (update-plist text)
    (format t "Dialog state: ~A~%" (slot-value (get-current-user) 'dialog-branch))
    (print "Message received:")
    (prin1 text)
    (let ((current-user (get-current-user)))
        (alexandria:switch ((slot-value current-user 'dialog-branch) 
                            :test #'equal)
            ("initial"  (response-initial current-user update-plist text))
            ("generate" (response-generate current-user update-plist text))
            ("interact" (response-interact current-user update-plist text)))))

(defun response-initial (current-user update-plist text)
    (alexandria:switch (text :test #'equal)
        ("Сгенерировать шаблонные документы"
            (branch-initial-generate current-user update-plist))
        ("Взаимодействовать с сервисом в интернете"
            (branch-initial-interact current-user update-plist))))

(defun response-generate (current-user update-plist text)
    (if (slot-value current-user 'dialog-layer)
        (if (slot-value current-user 'dialog-data)
            (alexandria:switch (text :test #'equal)
                ("Отмена"
                    ( ))))
        (alexandria:switch (text :test #'equal)
            ("Назад"
                (branch-initial current-user update-plist)))))

(defun response-interact (current-user update-plist text)
    (alexandria:switch (text :test #'equal)
        ("Назад"
            (branch-initial current-user update-plist))))

(defun branch-initial (current-user update-plist)
    (setf (slot-value current-user 'dialog-branch) "initial")
    (mito:save-dao current-user)

    (send-message (get-chat-id update-plist)
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

(defun branch-initial-generate (current-user update-plist)
    (setf (slot-value current-user 'dialog-branch) "generate")
    (setf (slot-value current-user 'dialog-layer) nil)
    (setf (slot-value current-user 'dialog-page) nil)
    (mito:save-dao current-user)

    (send-message (get-chat-id update-plist)
                  (format nil "Для генерации шаблонных документов нужно добавить тестовые данные людей.~@
                               Если Вы этого ещё не сделали или хотите отредактировать их список, ~
                               выберите соответствующую опцию на данном этапе.")
                  `(:|reply_markup| (
                        :|keyboard| (
                            ((:|text| "Добавить/редактировать данные"))
                            ((:|text| "Сгенерировать документы"))
                            ((:|text| "Назад")))
                        :|resize_keyboard| t))))

(defun branch-initial-interact (current-user update-plist)
    (setf (slot-value current-user 'dialog-branch) "interact")
    (setf (slot-value current-user 'dialog-layer) nil)
    (setf (slot-value current-user 'dialog-page) nil)
    (mito:save-dao current-user)

    (send-message (get-chat-id update-plist)
                    (format nil "Для взаимодействия с сервисом в интернете нужно добавить тестовые данные людей.~@
                                Если Вы этого ещё не сделали или хотите отредактировать их список, ~
                                выберите соответствующую опцию на данном этапе.")
                    `(:|reply_markup| (
                        :|keyboard| (
                            ((:|text| "Добавить/редактировать данные"))
                            ((:|text| "Отправить данные на сайт"))
                            ((:|text| "Назад")))
                        :|resize_keyboard| t))))

(defun branch-data-list (current-user update-plist)
    (setf (slot-value current-user 'dialog-layer) "data")
    (setf (slot-value current-user 'dialog-page) 1)
    (setf (slot-value current-user 'dialog-data) nil)
    (mito:save-dao current-user)
    
    (send-message (get-chat-id update-plist)
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