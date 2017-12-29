(require 'f)
(require 'with-simulated-input)

(defvar indentinator-support-path
  (f-dirname load-file-name))

(defvar indentinator-features-path
  (f-parent indentinator-support-path))

(defvar indentinator-root-path
  (f-parent indentinator-features-path))

(add-to-list 'load-path indentinator-root-path)

;; Ensure that we don't load old byte-compiled versions
(let ((load-prefer-newer t))
  (require 'indentinator)
  (require 'espuds)
  (require 'ert))
