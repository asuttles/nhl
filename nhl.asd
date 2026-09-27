(defsystem "nhl"
  :version "0.1"
  :author "Andrew Suttles"
  :license "BSD 2-Clause"
  :depends-on (:dexador
	       :yason)
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description "Print NHL Standings and Matchups in the Terminal")
