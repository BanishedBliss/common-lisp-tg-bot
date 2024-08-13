(defpackage #:telegram-bot-api
      (:use #:cl)
      (:export #:main))

(defpackage #:api-response
      (:use #:cl)
      (:export #:read-updates)
      (:shadowing-import-from #:cl #:quote))