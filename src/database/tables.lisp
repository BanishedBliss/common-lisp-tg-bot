(in-package :tg-bot-api)

(defun load-tables ()
	(mito:deftable migration () 
		((file-name :col-type :text)))

	(mito:deftable user ()
		((user-id :col-type :bigint
				  :primary-key t)
		 (dialog-branch :col-type (:varchar 64))
		 (dialog-layer :col-type (or (:varchar 64) :null))
		 (dialog-page :col-type (or (:integer) :null))
		 (dialog-data :col-type (or (:integer) :null))))

	(mito:deftable person-info ()
		((creator-id :references (user user-id))
		 (name :col-type (:varchar 128))
		 (date-of-birth :col-type :date)))

	(mito:ensure-table-exists 'migration)
	(mito:ensure-table-exists 'user)
	(mito:ensure-table-exists 'person-info))