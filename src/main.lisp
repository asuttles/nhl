(uiop:define-package nhl
    (:use #:cl)
  (:export #:main))

(in-package #:nhl)

(defparameter *conference-order*
  '(("Eastern Conference" "Atlantic" "Metropolitan")
    ("Western Conference" "Central"  "Pacific")))

(defparameter *NHL-STANDINGS-API* "https://api-web.nhle.com/v1/standings/now")
(defparameter *NHL-SCHEDULES-API* "https://api-web.nhle.com/v1/schedule/now")


;;;; STANDINGS

;;; GET-TEAM-RECORDS
;;; Return a list of hashes containing NHL team records
(defun get-team-records ()
  (gethash "standings" 
	   (yason:parse (dex:get *NHL-STANDINGS-API*))))

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
	  (stkWL (or (gethash "streakCode" team)  "-"))
	  (stkNo (or (gethash "streakCount" team) "-")))
      
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


;;;; SCHEDULES

;;; TODAY
;;; Return Today's Date in ISO Format
(defun today ()
  (multiple-value-bind (second minute hour day month year)
      (get-decoded-time)
    (declare (ignore second minute hour))
    (format nil "~4,'0D-~2,'0D-~2,'0D" year month day)))

;;; GET-NHL-WEEKLY-SCHEDULE
;;; Return a List of Hashes for Upcomming Week of Games
(defun get-nhl-weekly-schedule ()
  (gethash "gameWeek"
	   (yason:parse
	    (dex:get *NHL-SCHEDULES-API*))))

;;; GET-TODAYS-GAME-HASH
;;; Return a Hash for all of Today's Games
(defun get-todays-game-hash (games-list)
  (let ((today-date ;(today)))
	  "2026-09-29"))
    (find-if (lambda (next-games)
	       (string= today-date
			(gethash "date" next-games)))
	     games-list)))

;;; GET-TODAYS-GAME-LIST
;;; Return the List of Games for Today's Game Hash
(defun get-todays-game-list ()  
  (gethash "games"
	   (get-todays-game-hash
	    (get-nhl-weekly-schedule))))


(defun get-game-time (game)
  (let* ((utc (gethash "startTimeUTC" game))
	 (tz (local-time:find-timezone-by-location-name "US/Eastern"))
	 (local (local-time:parse-timestring utc))
	 (format '((:hour12 2) ":" (:min 2) " " :ampm "  " :short-weekday)))
    (local-time:format-timestring
     nil local :timezone tz :format format)))

  
(defun get-team-name (team)
  (format nil "~A ~A"
	  (gethash "abbrev" team)
	  (gethash "default"
		   (gethash "commonName" team))))
  

(defun print-matchups ()
  (format t "~%  Today's NHL Matchups~%~%")
  (dolist (game (get-todays-game-list))
    (format t " ~30A~A~% ~30A~%~%"
	    (get-team-name (gethash "awayTeam" game))
	    (Get-game-time game)
	    (get-team-name (gethash "homeTeam" game)))))


;;; Publically exported Main 
(defun main ()
  (print-nhl-standings))
