(in-package :tg-bot-api)

(defclass breadcrumbs () 
    ((branch-stack :initform (read-from-string (slot-value update:*dialog-state-db* 'breadcrumbs-stack)) 
                   :accessor branch-stack))
    (:documentation "Class for breadcrumbs stack manipulations."))

(defclass bcrumbs-next-branch () 
    ((class-string :initarg class-string :accessor class-string)
     (found :initform nil :accessor next-branch-in-past))
    (:documentation "Class for breadcrumbs next branch manipulation in loops."))

(defclass bcrumbs-prev-branch ()
    ((class-string :initform nil :accessor class-string))
    (:documentation "Class for searching previous branch in breadcrumbs."))

(defmethod save-breadcrumbs ((bcrumbs breadcrumbs))
    "Saves breadcrumbs stack to dialog state in DB."
    (setf (slot-value update:*dialog-state-db* 'breadcrumbs-stack) (branch-stack bcrumbs)))

(defmethod add-next-branch ((next-branch dialog-branch) &key (is-chain-start nil))
    "Adds next branch to the breadcrumbs stack. 
     If branch already in stack, removes all the following branches to 
     keep breadcrumbs concise."
    (let* ((bcrumbs (make-instance 'breadcrumbs))
           (bcrumbs-next-branch (make-instance 'bcrumbs-next-branch 
                                               'class-string (class-name (class-of next-branch)))))
        (setf (branch-stack bcrumbs) (loop-next-branch (branch-stack bcrumbs) next-branch))
        (and (null (next-branch-in-past bcrumbs))
             (setf (branch-stack bcrumbs) 
                   (add-branch-deep (branch-stack bcrumbs) next-branch is-chain-start)))
        (save-breadcrumbs bcrumbs)))

(defmethod loop-next-branch (bcrumbs-list (next-branch bcrumbs-next-branch))
    "Loops in branch stack and returns a new value. 
     Returns a new branch stack with removing every branch after next-branch in stack, 
        if the next branch is found in breadcrumbs. 
     Returns the same branch stack if next-branch was not found in stack."
    (loop for index from 0
          for element in bcrumbs-list
          if (listp element)
            do (setf (nth index bcrumbs-list) (loop-next-branch element next-branch))
          else 
            when (string= element (class-string next-branch))
                do (setf (next-branch-in-past next-branch) t)   and
                do (dotimes (n index) (pop bcrumbs-list))       and
                do (return bcrumbs-list)
          finally (return bcrumbs-list)))

(defmethod add-branch-deep (bcrumbs-list (next-branch bcrumbs-next-branch) &optional (is-chain-start nil)) 
    "Loops in branch stack in search of first deepest dialog chain and 
     appends next branch to the stack."
    (let ((first-element (first bcrumbs-list)))
        (if (listp first-element)
            (setf bcrumbs-list (add-branch-deep first-element next-branch))
            (if is-chain-start
                (push (list (class-string next-branch)) bcrumbs-list)
                (push (class-string next-branch) bcrumbs-list)))
        bcrumbs-list))

(defun close-chain ()
    "Closes last opened dialog chain."
    (let ((bcrumbs (make-instance 'breadcrumbs)))
        (setf (branch-stack bcrumbs) 
              (find-and-close-chain (branch-stack bcrumbs)))
        (save-breadcrumbs bcrumbs)))

(defun find-and-close-chain (branch-list &optional (depth 0))
    "Returns breadcrumbs list without the first deepest list - last opened dialog chain."
    (if (listp (first branch-list))
        (let ((returned-branch-list (find-and-close-chain (first branch-list) (1+ depth))))
            (if (null returned-branch-list)
                (cdr branch-list)
                (cons returned-branch-list (rest branch-list))))
        (if (< 0 depth)
            nil
            branch-list)))

(defun previous-branch-string ()
    "Removes last breadcrumb and returns previous branch name string."
    (let ((bcrumbs (make-instance 'breadcrumbs))
          (bcrumbs-prev-branch (make-instance 'bcrumbs-prev-branch)))
        (setf (branch-stack bcrumbs)
              (remove-current-branch (branch-stack bcrumbs) bcrumbs-prev-branch))
        (save-breadcrumbs bcrumbs)
        (class-string bcrumbs-prev-branch)))

(defun current-branch-string ()
    "Finds current branch."
    (find-current-branch (branch-stack (make-instance 'breadcrumbs))))

(defun find-current-branch (branch-list)
    "Loops in branch stack and finds current branch."
    (if (listp (first branch-list))
        (find-current-branch (first branch-list))
        branch-list))

(defun remove-current-branch (branch-list bcrubms-prev-branch &optional (depth 0))
    "Returns breadcrumbs list without the last breadcrumb. 
     Closes dialog chain if its the first breadcrumb in it.
     Does not remove initial breadcrumb."
    (if (listp (first branch-list))
        (let ((returned-branch-list (remove-current-branch (first branch-list) 
                                                           bcrubms-prev-branch 
                                                           (1+ depth))))
            (if (null returned-branch-list)
                (cdr branch-list)
                (cons returned-branch-list (rest branch-list))))
        (cond
            ((< 0 depth)
                (setf (class-string bcrubms-prev-branch) (car branch-list))
                (cdr branch-list))
            (t 
                (cond 
                    ((< 1 (length branch-list))
                        (setf (class-string bcrubms-prev-branch) (car branch-list))
                        (cdr branch-list))
                    (t 
                        branch-list))))))