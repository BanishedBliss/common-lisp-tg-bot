(in-package :hunch-test-bot)

(defmacro get-updates-request (offset) 
    '(drakma:http-request 
        (get-api-url "getUpdates") 
        :method :get
        :parameters '(("timeout" 5)
                      ("offset" offset))
        :connection-timeout 15))

(defun long-poll-updates ()
    (loop
        (get-updates-request)))

#| 
    Blank start:
    1. Update or no updates received
|#