(in-package :tg-bot-api)

;;; Contains hooks registration 
(defmethod on-command (update-plist 
                       (command (eql :start))
                       text)
    (declaim (ignorable text))
    (reply "It worked!"))