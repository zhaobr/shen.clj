(clojure.core/ns shen
  (:refer-clojure :only [])
  (:use [shen.primitives])
  (:require [clojure.core :as core]))

(def ^:dynamic *language* "Clojure")
(def ^:dynamic *implementation* (core/str "Clojure " (core/clojure-version)
                                          " [jvm "(System/getProperty "java.version")"]"))
(def ^:dynamic *port* "0.1.0-SNAPSHOT")
(def ^:dynamic *porters* "Håkan Råberg")

(def ^:dynamic *stinput* core/*in*)
(def ^:dynamic *home-directory* (System/getProperty "user.dir"))

(defun
  macroexpand
  (V510)
  (let
      Y
    (shen-compose (core/remove symbol? (core/map value (value '*macros*))) V510)
    (if (= V510 Y) V510 (shen-walk macroexpand Y))))

(core/defn -main []
  (shen-shen))