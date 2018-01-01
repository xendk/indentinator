;; This file contains your project specific step definitions. All
;; files in this directory whose names end with "-steps.el" will be
;; loaded automatically by Ecukes.

(Given "^I am in a new buffer \"\\([^\"]+\\)\" with the content:$"
  "Switches to buffer and ensure it has the given content."
  (lambda (buffer contents)
    ;; Ensure we're starting afresh.
    (ignore-errors (kill-buffer buffer))
    (Given "I am in buffer \"%s\"" buffer)
    (Given "I clear the buffer")
    (When "I insert:" contents)))

(And "^wait for idle timers$"
  "Wait for the given seconds."
  (lambda ()
    ;; Apparently we need to trigger idle-timers twice, as wsi doesn't
    ;; seem to pick up the added timers the first time?
    (wsi-simulate-idle-time nil)
    (wsi-simulate-idle-time nil)))

(Then "^the buffer should contain:$"
  "Asserts that the current buffer matches some text."
  (lambda (expected)
    (let ((actual (buffer-string))
          (message "Expected '%s' to be equal to '%s', but was not."))
      (cl-assert (s-equals? expected actual) nil message expected actual))))

(When "^I quietly turn on \\(.+\\)$"
  "Turns on some mode, without output cluttering test output."
  (lambda (mode)
    (let ((v (vconcat [?\C-u ?\M-x] (string-to-vector mode))))
      (shut-up (execute-kbd-macro v)))))
