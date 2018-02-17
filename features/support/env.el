(require 'f)
(require 'with-simulated-input)
(require 'shut-up)

(defvar indentinator-support-path
  (f-dirname load-file-name))

(defvar indentinator-features-path
  (f-parent indentinator-support-path))

(defvar indentinator-root-path
  (f-parent indentinator-features-path))

(add-to-list 'load-path indentinator-root-path)

(when (require 'undercover nil t)
  ;; Track coverage, but don't send to coveralls (Travis will send it
  ;; to Codecov).
  (undercover "*.el"
              (:report-file (f-join indentinator-root-path "coverage-final.json"))
              (:send-report nil)))

;; Ensure that we don't load old byte-compiled versions
(let ((load-prefer-newer t))
  (require 'indentinator)
  (require 'espuds)
  (require 'ert))
