(require 'f)
(require 'with-simulated-input)
(require 'shut-up)

(defvar indentinator-support-path
  (f-dirname load-file-name))

(defvar indentinator-features-path
  (f-parent indentinator-support-path))

(defvar indentinator-root-path
  (f-parent indentinator-features-path))

(defvar indentinator-coverage-path
  (f-join indentinator-root-path "coverage"))

(add-to-list 'load-path indentinator-root-path)

(when (require 'undercover nil t)
  (unless (file-directory-p indentinator-coverage-path)
    (make-directory indentinator-coverage-path))
  ;; Track coverage, but don't send to coveralls (Travis will send it
  ;; to Codecov).
  (undercover "*.el"
              (:report-file (f-join indentinator-coverage-path "report.json"))
              (:send-report nil)))

;; Ensure that we don't load old byte-compiled versions
(let ((load-prefer-newer t))
  (require 'indentinator)
  (require 'espuds)
  (require 'ert))
