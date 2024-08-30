(in-package :tg-bot-api/util/api)

(defun get-url (api-route) 
    (format nil "https://api.telegram.org/bot~A/~A" 
        (env:get-env :bot-api-key)
         api-route))

(defun get-updates-request (offset) 
    "Sends request to Telegram Bot API to receive latest bot updates."
    (drakma:http-request 
        (concatenate 'string (api:get-url "getUpdates")
                             "?timeout=5&offset="
                             (write-to-string offset))
        :method :get
        :connection-timeout 15))

(defun send-json-to-route (route json-plist)
	"Posts JSON to the provided bot API route.
	 Recevies a route string and a plist compatiable with jonathan json lib."
	(drakma:http-request
            (api:get-url route)
            :method :post
            :content (jonathan:to-json json-plist)
            :content-type "application/json"))

(defun get-chat-id ()
    (getf (getf update:*current-update* :|chat|) :|id|))

(defun text-back (text)
    "Sends plain text to the current update's chat.
     Does not reply to the actual message received."
	(send-json-to-route "sendMessage"
        `(:|text| ,text 
          :|chat_id| ,(write-to-string 
                            (getf (getf update:*current-update* :|chat|) 
                                                                :|id|)))))

(defun send-message (chat-id text &optional (parameters nil))
    "Receives chat-id and text for message. 
     Also receives parameters plist, containing fields in sendMessage API reference."
    (send-json-to-route "sendMessage"
        (util:merge-plist `(:|chat_id| ,chat-id :|text| ,text) 
                      parameters)))