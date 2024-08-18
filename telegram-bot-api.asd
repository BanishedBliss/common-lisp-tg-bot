(defsystem "telegram-bot-api"
  :author "Valery Tarakanovskiy <valery.tarakanovskiy@gmail.com>"
  :description "A simple telegram bot for server deployment"
  :version "1.0.0"
  :depends-on (:jonathan :drakma)
  :components ((:module "src"
                  :components ((:file "packages")
                               (:file "util")
                               (:module "api-response"
                                  :components ((:module "abstract"
                                                  :components ((:file "has-raw-plist")))
                                               (:module "api-types"
                                                  :components ((:file "bot-command")))
                                               (:file "api-response")
                                               (:file "long-poll-response")
                                               (:file "update")))
                               (:file "bot-api")
                               (:file "main")))
               (:file "config")))