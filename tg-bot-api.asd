(defsystem "tg-bot-api"
  :author "Valery Tarakanovskiy <valery.tarakanovskiy@gmail.com>"
  :description "A simple telegram bot for server deployment"
  :version "1.0.0"
  :depends-on (:jonathan :drakma)
  :components ((:module "src"
                  :components ((:file "packages")
                               (:file "util")
                               (:file "bot-api")
                               (:module "update"
                                 :components ((:file "update")
                                              (:module "helper-types"
                                                :components ((:file "bot-command")))))
                               (:file "main")))
               (:file "config")
               (:file "update-hooks")))