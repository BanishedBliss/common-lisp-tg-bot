(in-package :tg-bot-api)

(defun main ()
    "Main entry point for the Telegram Bot server."
    (load-config)
    (set-my-commands)
    (long-poll-updates)
    ; (sleep most-positive-fixnum)
    )