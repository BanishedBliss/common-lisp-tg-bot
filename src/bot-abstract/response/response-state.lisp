(in-package :tg-bot-api)

;; Abstract class for malformed response state.
(defclass malformed-response () ())

;; Abstract class for response state with errors.
(defclass response-not-ok () ())

;; Abstract class for response state with no results.
(defclass response-no-results () ())

;; Class for unchecked response state. 
;; If unchanged - no successful checks took place, 
;;  so it plays a role of malformed response state.
(defclass response-state (malformed-response) ())

;; Class for response with found OK state.
;; If unchanged - OK value is 'false',
;; so it plays a role of response with errors state.
(defclass response-has-ok (response-state response-not-ok) ())

;; Class for response with OK state confirmed.
;; If unchanged - no results were returned.
;;  so it plays a role of response with no results state.
(defclass response-is-ok (response-has-ok response-no-results) ())

;; Class for response with results found.
;; A final state from which response analysis is fired.
(defclass response-has-results (response-is-ok) 
	(last-update-id :initform nil :accessor last-update-id))