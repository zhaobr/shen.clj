(defproject shen.clj "0.1.6-SNAPSHOT"
  :description "Shen is a portable functional programming language by Mark Tarver"
  :license {:name "Shen License"
            :url "http://www.shenlanguage.org/license.html"}
  :url "https://github.com/hraberg/shen.clj"
  :dependencies [[clojure "1.4.0"]]
  :dev-dependencies [[marginalia "0.7.0"]
                     [lein-difftest "1.3.7"]]
  :repositories [["sonatype snapshots"
                  "https://oss.sonatype.org/content/repositories/snapshots/"]]
  :main shen.install
  :aot [shen.primitives shen.install shen])
