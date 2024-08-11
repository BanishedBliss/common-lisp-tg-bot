(defsystem "hunch-test-bot"
  :author "Valery Tarakanovskiy <valery.tarakanovskiy@gmail.com>"
  :description "A simple telegram bot based on Hunchentoot server"
  :version "1.0.0"
  :depends-on (:hunchentoot :jonathan :drakma)
  :components ((:module "src"
                  :components ((:file "packages")
                               (:file "util")
                               (:file "main")
                               (:file "routes")))
               (:file "config")))