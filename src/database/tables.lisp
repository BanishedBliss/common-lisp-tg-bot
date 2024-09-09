(in-package :tg-bot-api)

(defun load-tables ()
	(mito:deftable migration () 
		((file-name :col-type :text)))

	(mito:deftable user ()
		((id :col-type :unsigned
		 	 :primary-key t)
		 (user-id :col-type :bigint
				  :primary-key t)))

	(mito:deftable dialog-state ()
		((user-id :references (user id))
		 (branch :col-type (:varchar 128) :initform "branch-initial")
		 (breadcrumbs-stack :col-type (:varchar 128) :initform "")  ;; watch out for breadcrumbs length
		 (people-data-offset :col-type :integer :initform 0)))

	(mito:deftable person-data-temp ()
		((user-id :references (user id))
		 (last-name :col-type (:varchar 64) :initform "")
		 (first-name :col-type (:varchar 64) :initform "")
		 (middle-name :col-type (:varchar 64) :initform "")))

	(mito:deftable person-data ()
		((id :col-type :unsigned
			 :primary-key t)
		 (user-id :references (user id))
		 (last-name :col-type (:varchar 128))
		 (first-name :col-type (:varchar 128))
		 (middle-name :col-type (:varchar 128) :initform "")
		 (date-of-birth :col-type :date)))

	(mito:ensure-table-exists 'migration)
	(mito:ensure-table-exists 'user)
	(mito:ensure-table-exists 'person-info))