#| Util Package |#

;; TODO: Export functions.

(defpackage #:tg-bot-api/util/db
      (:use #:cl))

(defpackage #:tg-bot-api/util/server
      (:use #:cl))

(defpackage #:tg-bot-api/util/api
      (:use #:cl))

(defpackage #:tg-bot-api/util/env
      (:use #:cl))

(defpackage #:tg-bot-api/util
      (:use #:cl))

#| Current update package |#

(defpackage #:tg-bot-api/api/current-update
      (:use #:cl))

#| Bot body |#

(defpackage #:tg-bot-api/body
      (:use #:cl))

#| Root Package |#

(defpackage #:tg-bot-api
      (:use #:cl)
      (:export #:main)
      (:local-nicknames (:env       :tg-bot-api/util/env)
                        (:api       :tg-bot-api/util/api)
                        (:srv-util  :tg-bot-api/util/server)
                        (:db-util   :tg-bot-api/util/db)
                        (:util      :tg-bot-api/util)
                        (:update    :tg-bot-api/api/current-update)
                        (:body      :tg-bot-api/body)))