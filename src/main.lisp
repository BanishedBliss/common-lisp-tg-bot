(in-package :tg-bot-api)

(defun main ()
    "Main entry point for the Telegram Bot server."
    (env:load-config)
    (connect-to-db)
    (set-my-commands)
    (long-poll-updates)
    ; (sleep most-positive-fixnum)
    )