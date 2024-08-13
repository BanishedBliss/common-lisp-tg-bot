(in-package :api-response)

(defclass message-entity (has-raw-plist) 
	(;(message-object :accessor message-object :initarg message-object)
	 (entity-type :accessor entity-type :initarg entity-type)
	 (offset :accessor offset :initarg offset)
	 (entity-length :accessor entity-length :initarg entity-length)
	 (url :accessor url :initarg url)
	 (user :accessor user :initarg user)
	 (language :accessor language :initarg language)
	 (custom_emoji_id :accessor custom_emoji_id :initarg custom_emoji_id)))

(defmethod initialize-instance :after ((m-entity message-entity))
	())