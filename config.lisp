(in-package :hunch-test-bot)

(defparameter *env* `(
    (:bot-api-key "7362297110:AAGh9fcnM8j-VMQ-zUF1dRkgy1tcSww1O7U")
    (:server-url "84.244.31.180:80")
    (:server-internal-port 3333)
    (:web-root-path ,(path-from-app-root "src/www/"))
))

#| Restart server after making changes to *env*

:bot-api-key            - A string. Get one via Telegram Bot @BotFather
:server-internal-port            - default value: 3333
:web-root-path          - default value: ,(path-from-app-root "src/www/")
|#