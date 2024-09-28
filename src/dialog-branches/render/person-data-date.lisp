(in-package :tg-bot-lib)

(defun date-data-page-render () 
    (let ((menu-state (slot-value update:*dialog-state-db* 'person-data-date-state))
          (year-page (slot-value update:*dialog-state-db* 'person-data-date-year-page))
          (year (slot-value update:*dialog-state-db* 'person-data-date-year))
          (month (slot-value update:*dialog-state-db* 'person-data-date-month)))
        (cond 
            ((string= menu-state "year-select")
                (year-select-page))
            ((string= menu-state "month-select"
                (month-select-page year)))
            ((string= menu-state "day-select"
                (day-select-page year month))))))

(defun year-select-page (start-year)
    "Returns buttons for a year select page og the menu."
    (let (menu-buttons)
        (push menu-buttons (year-nav-buttons start-year))
        (loop with button-row 
              for year from start-year below (+ 25 start-year)
              do (push (list :key (format nil "year-~A" year)
                             :text (format nil "~A" year))
                       menu-buttons)
              when (and (not (eql start-year year)) 
                        (eql (rem (/ (- year start-year) 5))
                             0))
                do (push (reverse button-row) menu-buttons))
        (reverse menu-buttons)))

(defun year-nav-buttons (start-year)
    "Returns a list of nav buttons for a year select page of the menu."
    (let (nav-buttons)
        (if (not (eql start-year 0))
            (push (list :key "prev"
                        :text "Раньше")
                  nav-row))
        (push (list :key "next"
                    :text "Позже"))
        (reverse nav-buttons)))

(defun month-select-page (selected-year) 
    "Returns a list of buttons for a month select page of the menu."
    (list 
        (list 
            (list :key "select-year"
                  :text "Выбор года")
            (list :key "select-year"
                  :text (format nil "~A" selected-year)))
        (list
            (list :key "month-jan"
                  :text "Январь")
            (list :key "month-feb"
                  :text "Февраль")
            (list :key "month-mar"
                  :text "Март"))
        (list 
            (list :key "month-apr"
                  :text "Апрель")
            (list :key "month-may"
                  :text "Май")
            (list :key "month-jun"
                  :text "Июнь"))
        (list 
            (list :key "month-jul"
                  :text "Июль")
            (list :key "month-aug"
                  :text "Август")
            (list :key "month-sep"
                  :text "Сентрябрь"))
        (list 
            (list :key "month-oct"
                  :text "Октябрь")
            (list :key "month-nov"
                  :text "Ноябрь")
            (list :key "month-dec"
                  :text "Декабрь"))))

(defun day-select-page (selected-year selected-month)
      (append
            (list 
                  (list 
                        (list :key "select-year"
                              :text (format nil "~A" selected-year))
                        (list :key "select-month"
                              :text (format nil "~A" selected-month))))
            (loop with days-list
                  with button-row 
                  for day-num from 1 to (get-month-days-count selected-year selected-month)
                  do (push (day-button-format day-num)
                        button-row)
                  when (= 7 (length button-row))
                        do (push button-row days-list)
                  finally (return (reverse (append days-list button-row))))))

(defun day-button-format (day-num)
      (list :key (format nil "day-~A" day-num)
            :text (format nil "~A" day-num)))

(defun get-month-days-count (selected-year selected-month) 
      "Gets an amount of days in a given month of a given year"
      (cond
            ((not (null (position selected-month 
                              (list "Январь" "Март" "Май" "Июль" "Август" "Октябрь" "Декабрь"))))
                  31)
            ((not (null (position selected-month
                              (list "Апрель" "Июнь" "Сентябрь" "Ноябрь"))))
                  30)
            ((string= selected-month "Февраль")
                  (if (= (rem selected-year 4) 0)
                        29
                        28))))