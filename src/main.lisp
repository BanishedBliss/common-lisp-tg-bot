(in-package :hunch-test-bot)

(defun main ()
    "Main entry point for the Telegram Bot server."
    (load-config)
    (long-poll-updates)
    ; (sleep most-positive-fixnum)
    )