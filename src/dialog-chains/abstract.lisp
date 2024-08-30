(in-package :tg-bot-api)

(defclass dialog-branch ())
(defclass dialog-branch-next (dialog-branch)
	((message :accessor branch-message) prerender-action))
(defclass dialog-branch-current (dialog-branch))


