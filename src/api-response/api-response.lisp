(in-package :api-response)

(defun read-updates (parsed-plist)
	"Reads the incoming long poll response, fires update hooks and returns the response object for further management."
	(let (response-object (make-instance 
							'long-poll-response 
							:plist parsed-plist))
		(analyze-plist response-object)
		(eval-plist response-object)
		response-object))

#| List of field name I had to replace:
     1. Message - quote 		=> quote_of
	 2. MessageEntity - type	=> entity_type
	 3. MessageEntity - length 	=> entity_length
	 4. Chat - type				=> chat_type
|#