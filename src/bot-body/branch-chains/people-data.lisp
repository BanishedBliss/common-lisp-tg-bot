(in-package :tg-bot-api/body)

#| Branch People Data |#

(defclass branch-people-data (dialog-branch) ())

(defmethod branch-message ((branch branch-people-data))
	(format nil "Ваши тестовые данные.~% ~
				 Всего записей: ~A~%~%~" 
				(mito:count-dao 'person-data 
					(where (:= :user-id 
							   (slot-value update:*user-db* 'id))))))

(defmethod reply-markup-type ((branch branch-people-data))
	(make-instance 'inline-markup))

(defmethod reply-options ((branch branch-people-data))
	`(,(people-data-page-render)
	  ((:text "Назад"
	   	:action (:back))
	   (:text "Добавить"
	    :action ((:next-chain 'branch-person-data-last-name))))))