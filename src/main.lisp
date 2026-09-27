(uiop:define-package nhl
  (:use #:cl))

(in-package #:nhl)

(defparameter +conference-order+
  '(("Eastern Conference" "Atlantic" "Metropolitan")
    ("Western Conference" "Central"  "Pacific")))

(defconstant +NHL-STANDINGS-API+ "https://api-web.nhle.com/v1/standings/now")


;;; GET-TEAM-RECORDS
;;; Return a list of hashes containing NHL team records
(defun get-team-records ()
  (gethash "standings" 
	   (yason:parse (dex:get +NHL-STANDINGS-API+))))

;;; GROUP-BY-DIVISION
;;; Group team records by division
(defun group-by-division (teams)
  (let ((divisions (make-hash-table :test #'equal)))
    (dolist (team teams divisions)
      (push team (gethash (gethash "divisionName" team) divisions)))))

;;; REVERSE-DIVISION-LISTS
;;; Reverse Divisional Lists to Sort by Points
(defun reverse-division-lists (divisions)
  (maphash (lambda (div team-list)
	     (setf (gethash div divisions)
		   (nreverse team-list)))
	   divisions)
  divisions)

;;; PRINT-DIVISION-STANDINGS
;;; Print Division Standings Sorted by Points
(defun print-division-standings (division team-list)
  (format t "~A Division~%~%" division)
  (format t "Team                      GP   Wins  Loss  OTL    PTS  Strk~%")
  (dolist (team team-list)
    (let ((name (gethash "default" (gethash "teamName" team)))
	  (games (gethash "gamesPlayed" team))
	  (wins  (gethash "regulationPlusOtWins" team))
	  (sow   (gethash "shootoutWins" team))
	  (loss  (gethash "losses" team))
	  (otl   (gethash "otLosses" team))
	  (pts   (gethash "points" team))
	  (stkWL (gethash "streakCode" team))
	  (stkNo (gethash "streakCount" team)))
      (format t "~25A ~5A ~5A ~5A ~5A ~5A ~A~A~%"
	      name games (+ wins sow) loss otl pts stkWL stkNo)))
  (terpri)(terpri))

;;; PRINT-NHL-STANDINGS
;;; Print Conference Headers and Divisional Standings
(defun print-nhl-standings ()
  (terpri)
  ;; Collect and Sort NHL Standings Data
  (let ((division
	  (reverse-division-lists
	   (group-by-division
	    (get-team-records)))))
    ;; Iter Conferences
    (dolist (conf-list +conference-order+)
      (format t "~A~%~%" (car conf-list))
      ;; Iter Divisions
      (dolist (div (cdr conf-list))
	(print-division-standings
	 div (gethash div division))))))
