(defpackage #:telegram-bot-api
      (:use #:cl)
      (:export #:main #:log-data #:get-api-url))

(defpackage #:api-response
      (:use #:cl)
      (:export #:read-updates #:reply #:on-command
            ; class
            long-poll-response
            any-results))

(defpackage #:hook-declarations
      (:use #:cl #:telegram-bot-api #:api-response))