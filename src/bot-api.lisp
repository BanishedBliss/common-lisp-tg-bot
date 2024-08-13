(in-package :telegram-bot-api)

(defun long-poll-updates ()
    "Top-level loop. Repeatedly sends requests to get updates for a given bot."
    ; Sets a variable for storing the last processed updates's ID.
    (let ((offset 0)) (loop
        (let* ((api-answer  (get-updates-request offset))
               (parsed-plist (jonathan:parse 
                             (flexi-streams:octets-to-string api-answer))))
            
            (print "Parsed plist:")
            (prin1 parsed-plist)

            ;; Read response, modifies offset parameter to get next updates.
            (let ((response-object 
                   (api-response:read-updates parsed-plist)))
                (when (has-results response-object)
                    (setf offset 
                        (1+ (last-update-id response-object)))))))))

(defun get-updates-request (offset) 
    "Sends request to Telegram Bot API to receive latest bot updates."
    (drakma:http-request 
        (concatenate 'string (get-api-url "getUpdates")
                             "?timeout=5&offset="
                             (write-to-string offset))
        :method :get
        :connection-timeout 15))