(defsystem "nhl"
  :version "0.0.1"
  :author "Andrew Suttles"
  :license "BSD 2-Clause"
  :depends-on (:dexador
	       :yason)
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description "Print NHL Standings and Matchups in the Terminal"
  :in-order-to ((test-op (test-op "nhl/tests"))))

(defsystem "nhl/tests"
  :author "Andrew Suttles"
  :license "BSD 2-Clause"
  :depends-on ("nhl"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for nhl"
  :perform (test-op (op c) (symbol-call :rove :run c)))
