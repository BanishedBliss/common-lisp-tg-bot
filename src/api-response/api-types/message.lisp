(in-package :api-response)

(defclass message (has-raw-plist) 
	(update-instance :initarg update-instance)
	(message_id :initarg message_id :accessor message_id)
	(date :initarg date :accessor date)
	(text :initarg text :accessor text)
	(entities :initarg entities)
	(chat :initarg chat)
	(from :initarg from))

(defmethod initialize-instance :after ((m-object message))
	
	(fire-hooks m-object))

(defmethod fire-hooks ((m-object message))
	"Fires hooks for various message types received."
	(let ((command-struct (get-command m-object)))
		(cond 
			((eql (type-of command-struct) 
				  'bot-command)
				(on-command (m-object (command command-struct) 
									  (text command-struct))))
		  	(t 
				(on-message (m-object))))))

(defmethod get-command ((m-object message))
	"Looks through message entities for bot_command type and 
	 extracts command structure from message text."
	(with-slots ((m-entities entities) (m-text text))
			m-object
		(loop for entity in m-entities
			  when (and 
						(eql "bot_command" (entity-type entity))
						(eql 0 (offset entity))
			  return (extract-command m-text entity)))))

(defgeneric on-command ((message-object message) (command 'keyword) (text 'string))
	(:documentation "Defines a hook for when a message with bot command has been received."))

(defgeneric on-message ((message-object message))
	(:documentation "Defines a hook for when a plain message has been received."))

#| 
(defmethod slot-unbound (class (instance message) slot-name)
	"Return 'nil' if slot had no value in JSON"
	(declare (ignorable class))
	(setf (slot-value instance slot-name) nil))
|#

#| List of all fields in API:
	 message_id message_thread_id from sender_chat sender_boost_count sender_business_bot
	 date business_connection_id chat forward_origin is_topic_message is_automatic_forward 
	 reply_to_message external_reply quote reply_to_story via_bot edit_date 
	 has_protected_content is_from_offline media_group_id author_signature text entities 
	 link_preview_options effect_id animation audio document paid_media photo sticker 
	 story video video_note voice caption caption_entities show_caption_above_media 
	 has_media_spoiler contact dice game poll venue location new_chat_members 
	 left_chat_member new_chat_title new_chat_photo delete_chat_photo group_chat_created 
	 supergroup_chat_created channel_chat_created message_auto_delete_timer_changed 
	 migrate_to_chat_id migrate_from_chat_id pinned_message invoice successful_payment 
	 refunded_payment users_shared chat_shared connected_website write_access_allowed 
	 passport_data proximity_alert_triggered boost_added chat_background_set forum_topic_created 
	 forum_topic_edited forum_topic_closed forum_topic_reopened general_forum_topic_hidden 
	 general_forum_topic_unhidden giveaway_created giveaway giveaway_winners giveaway_completed 
	 video_chat_scheduled video_chat_started video_chat_ended video_chat_participants_invited 
	 web_app_data reply_markup
|#