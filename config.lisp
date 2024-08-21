;;; Contains configuration to start the application with.

(in-package :tg-bot-api)

(defparameter *env* `(
        (:bot-api-key "7362297110:AAGh9fcnM8j-VMQ-zUF1dRkgy1tcSww1O7U")
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