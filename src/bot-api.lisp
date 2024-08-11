(in-package :hunch-test-bot)

(defmacro get-updates-request (offset) 
    '(drakma:http-request 
        (get-api-url "getUpdates") 
        :method :get
        :parameters '(("timeout" 5)
                      ("offset" offset))
        :connection-timeout 15))

(defun long-poll-updates ()
    "Top-level loop. Repeatedly sends requests to get updates for a given bot."
    ; Sets a variable for the last processed updates's ID.
    (let ((offset 0))
        (loop
            (let ((api-answer (get-updates-request offset)))
                ))))

#| 
    Blank start:
    1. Update or no updates received
|#