;;; Contains configuration to start the application with.

(in-package :tg-bot-api)

(defparameter *env* `(
        (:bot-api-key "7362297110:AAGh9fcnM8j-VMQ-zUF1dRkgy1tcSww1O7U") ; I know, I just don't care enough.
        (:db-connection :mysql)
        (:mysql-host "MySQL-8.2")
        (:mysql-db-name "tg_bot_api")
        (:mysql-user "root")
        (:mysql-password "")
    )
)

#| Restart server after making changes to *env*

:bot-api-key    - A string. Get one via Telegram Bot @BotFather
|#

(defun set-my-commands () 
    (send-json-to-route "setMyCommands"
        '(:|commands| (
            (
                :|command| "start"
                :|description| "Перезапустить бота." 
            )
        ))))

(defun migrations-wildpath ()
    (merge-pathnames (path-from-app-root "src/database/migrations/") "*.lisp"))
