;;; Contains configuration to start the application with.

(in-package :tg-bot-api)

(defparameter *env* `(
        (:bot-api-key "7362297110:AAGh9fcnM8j-VMQ-zUF1dRkgy1tcSww1O7U")
        (:db-connection :mysql)
        (:mysql-host "MySQL-8.2")
        (:mysql-db-name "tg_bot_api")
        (:mysql-user "root")
        (:mysql-password "")
        (:people-data-per-page 5)
        (:max-people-data-per-user 10)
    )
)

#| Restart server after making changes to *env*

:bot-api-key    - A string. Get one via Telegram Bot @BotFather
|#

(defun set-my-commands () 
    (api:send-json-to-route "setMyCommands"
        '(:|commands| (
            (
                :|command| "start"
                :|description| "Перезапустить бота." 
            )
        ))))

(defun migrations-wildpath ()
    (merge-pathnames (util:path-from-app-root "src/database/migrations/") "*.lisp"))