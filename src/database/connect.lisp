(in-package :tg-bot-api)

(defun connect-to-db ()
	"Connects the app to database via mito. Loads tables and runs migrations."
	(case (get-env :db-connection)
		(:mysql
			(mito:connect-toplevel :mysql
					   :host (get-env :mysql-host)
                       :database-name (get-env :mysql-db-name)
                       :username (get-env :mysql-user)
                       :password (get-env :mysql-password))))
	
	(load-tables)
	(run-new-migrations))

(defun run-new-migrations ()
	"Runs new migrations found in migrations folder."
	(let ((new-migrations (get-new-migrations)))
		(loop for migration in new-migrations
			do (load migration)
			do (mito:create-dao 'migration 
					:file-name (namestring migration)))))

(defun get-new-migrations ()
	"Gets a list of finished migrations from DB, 
	 compares it to the migration files present 
	 and returns a list of new migration files."
	(let ((finished-migrations 
				(loop for migration in (mito:retrieve-dao 'migration) 
						collect (pathname (slot-value migration 'file-name))))
		  (migration-files 
		   		(directory (migrations-wildpath))))

		(remove-if  (lambda (migration) 
						(member migration finished-migrations :test #'equal)) 
					migration-files)))