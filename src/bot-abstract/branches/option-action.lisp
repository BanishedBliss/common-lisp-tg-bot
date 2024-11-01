(in-package :tg-bot-api)

(defclass option-action () ((params :initarg params :accessor action-params)))
    (defclass action-next-branch (option-action) ())
        (defclass action-finish-next (action-next-branch) ())
    (defclass action-next-chain (option-action) ())
    (defclass action-back (option-action) ())
    (defclass action-cancel (option-action) ())

(defgeneric run-action (action)
    (:documentation "Trigger a sequence of actions to move dialog to the next step."))

(defmacro make-branch-action (action)
    `(make-instance (intern
        (concatenate 'string 
            "action-" (string ,(if (listp action)
                                   (first action)
                                   action))))
        'params ,(if (listp action)
                     (rest action))))

(defun run-option-actions (action-list)
    "Iterates over a list of actions, calling them sequentially.
     Saves new dialog state to DB."
    (loop for action in action-list
          do (run-action (make-branch-action action)))
    (mito:save-dao update:*dialog-state-db*))

(defmethod next-branch-obj ((action action-next-branch))
    (make-instance (find-class (first (action-params action)))))

(defmethod run-action ((action action-next-branch))
    ;(branch-prerender-actions (next-branch-obj action))
    (update-user-dialog (next-branch-obj action))
    (add-next-branch (next-branch-obj action)))

(defmethod run-action ((action action-next-chain))
    (update-user-dialog (next-branch-obj action)
    (add-next-branch (next-branch-obj action) :is-chain-start t)))

(defmethod run-action ((action action-back))
    (update-user-dialog (make-instance (find-class (previous-branch-string)))))

(defmethod run-action ((action action-cancel))
    (close-chain)
    (update-user-dialog (current-branch-string)))

(defmethod run-action ((action action-finish-next))
    (close-chain)
    (change-class action 'action-next-branch)
    (run-action action))