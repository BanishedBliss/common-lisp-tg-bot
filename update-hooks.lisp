(in-package :tg-bot-api)

(defmethod on-command (update-plist 
                       (command (eql :start))
                       text)
    (declare (ignorable text))
    (reply "Бот работает!"))