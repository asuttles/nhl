(uiop:define-package nhl
    (:use #:cl)
  (:export #:main))

(in-package #:nhl)

(defparameter *conference-order*
  '(("Eastern Conference" "Atlantic" "Metropolitan")
    ("Western Conference" "Central"  "Pacific")))

(defparameter *NHL-STANDINGS-API* "https://api-web.nhle.com/v1/standings/now")
(defparameter *NHL-SCHEDULES-API* "https://api-web.nhle.com/v1/schedule/now")

(defparameter *TZ* "US/Eastern")

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

;;; PRINT-STANDINGS
;;; Print Conference Headers and Divisional Standings
(defun print-standings ()
  (terpri)
  ;; Collect and Sort NHL Standings Data
  (let ((division
	  (reverse-division-lists
	   (group-by-division
	    (get-team-records)))))
    ;; Iter Conferences
    (dolist (conf-list *conference-order*)
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

;;; GET-WEEKLY-SCHEDULE
;;; Return a List of Hashes for Upcomming Week of Games
(defun get-weekly-schedule ()
  (gethash "gameWeek"
	   (yason:parse
	    (dex:get *NHL-SCHEDULES-API*))))

;;; GET-TODAYS-GAME-HASH
;;; Return a Hash for all of Today's Games
(defun get-todays-game-hash (games-list)
  (let ((today-date (today)))
    (find-if (lambda (next-games)
	       (string= today-date
			(gethash "date" next-games)))
	     games-list)))

;;; GET-TODAYS-GAME-LIST
;;; Return the List of Games for Today's Game Hash
(defun get-todays-game-list ()  
  (gethash "games"
	   (get-todays-game-hash
	    (get-weekly-schedule))))

;;; GET-GAME-TIME
;;; Return the Game Start Time from a game Hash Object 
(defun get-game-time (game)
  (local-time:reread-timezone-repository)
  (let* ((utc (gethash "startTimeUTC" game))
	 (tz (local-time:find-timezone-by-location-name *TZ*))
	 (local (local-time:parse-timestring utc))
	 (format '((:hour12 2) ":" (:min 2) " " :ampm "  " :short-weekday)))
    (local-time:format-timestring
     nil local :timezone tz :format format)))

;;; GET-TEAM-NAME
;;; Return Team Abbrev and Nickname from Team Hash Object
(defun get-team-name (team)
  (format nil "~A ~A"
	  (gethash "abbrev" team)
	  (gethash "default"
		   (gethash "commonName" team))))
  
;;; PRINT-MATCHUPS
;;; Print Today's NHL Matchups
(defun print-matchups ()
  (format t "~% Today's NHL Matchups  - ~A Time Zone~%~%" *TZ*)
  (dolist (game (get-todays-game-list))
    (format t " ~30A~A~% ~30A~%~%"
	    (get-team-name (gethash "awayTeam" game))
	    (Get-game-time game)
	    (get-team-name (gethash "homeTeam" game)))))


;;; HELP

;;; PRINT-HELP
;;; Print a Help Message
(defun print-help ()
  (format t "Help me!~%"))


;;; MAIN PROGRAM

;;; PARSE-ARGUMENTS
;;; Parse Command-Line Arguments
(defun parse-arguments (args)
  (loop for arg in args
	collect
	(cond ((string= arg "-s") :standings)
	      ((string= arg "-m") :matchups)
	      ((string= arg "-h") :help)
	      (t (error "Unknown argument: ~A" arg)))))

;;; RUN
;;; Parse Arguments and Execute Options
(defun run (args)
  (handler-case
      (let ((options (parse-arguments args)))

	(when (or
	       (null options)
	       (member :help options))
	  (print-help)
	  (return-from run 0))

	(when (member :standings options)
	  (print-standings))

	(when (member :matchups options)
	  (print-matchups))

	(return-from run 0))

    (error (e)
      (format *error-output* "~A~%" e)
      (print-help)
      (return-from run 1))))


;;; MAIN (Public)
(defun main ()
  (sb-ext:exit
   :code
   (run (uiop:command-line-arguments))))
