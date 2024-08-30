(in-package :tg-bot-api)

#|    Rest   |#

(defun merge-plist (p1 p2)
    (loop with notfound = '#:notfound
        for (indicator value) on p1 by #'cddr
        when (eq (getf p2 indicator notfound) notfound) 
        do (progn
                (push value p2)
                (push indicator p2)))
    p2)


(defun path-from-app-root (path)
    "Get absolute path from the application's root directory.
     Path parameter should be a strings with a trailing slash, i.e. src/www/"
    (asdf:system-relative-pathname
        "tg-bot-api"
        path))