;;; indentinator.el --- Automatically indent code.   -*- lexical-binding: t; -*-

;; Copyright (C) 2017  Thomas Fini Hansen

;; Author: Thomas Fini Hansen <xen@xen.dk>
;; Created: December 22, 2017
;; Version: 0.0.1
;; Package-Requires: ((emacs "24") (seq))
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:

;; Mode line indicator indicating running indent.

;; Maybe advice save-buffer when indenting is running.

;; When stopped: note down last line changed in xen-aborted-indents
;; (use a mark).
;; When stopping indent because X lines in a row didn't change, delete
;; from xen-aborted-indents where mark is between start of
;; indent and end of indent.
;; Continue indenting from first in xen-aborted-indents, rinse and repeat.

;; An after-change-functions that notes down changed pairs. Idle
;; function processes them. It indents the last one first. Afterwards
;; it idle indents afterwards. After that again, it starts with the
;; earliest region and loops them through (need to mark the regions
;; with markers?).

;; Doens't indent current line. Feature?

(require 'seq)

(defvar indentinator-idle-timer nil
  "Idle timer for processing indentation.")

(defvar indentinator-start-marker (make-marker)
  "Marks the start of the current indent run.")
(make-variable-buffer-local 'indentinator-start-marker)

(defvar indentinator-current-marker (make-marker)
  "The marker of the next indent action.")
(make-variable-buffer-local 'indentinator-current-marker)

(defvar indentinator-last-indented-marker nil
  "The marker of the last indented position.")
(make-variable-buffer-local 'indentinator-last-indented-marker)

(defvar indentinator-aborted-markers (list)
  "Markers for `indentinator-current-marker' of aborted indents.")
(make-variable-buffer-local 'indentinator-aborted-markers)

(defvar indentinator-indenting nil
  "Whether an indenting action is currently in progress.")
(make-variable-buffer-local 'indentinator-indenting)

(defvar indentinator-debug nil
  "Enables debugging output.")

(defun indentinator-toggle-debug ()
  "Toggle debugging."
  (interactive)
  (setq indentinator-debug (not indentinator-debug)))

(define-minor-mode indentinator-mode nil
  :lighter (:eval (if indentinator-idle-timer " ->" ""))
  (if indentinator-mode
      (add-hook 'after-change-functions 'indentinator-after-change-function t t)
    (remove-hook 'after-change-functions 'indentinator-after-change-function t)))

(defun indentinator-after-change-function (start end _len)
  "Handles buffer change between START and END.

BEG and END mark the beginning and end of the change text.  _LEN
is ignored.

Schedules re-indentation of following text."
  (when (and (not indentinator-indenting)
             (not undo-in-progress)
             indentinator-mode)
    (let ((indentinator-indenting t))
      (when indentinator-debug
        (message "indentinator: after-change %d %d" start end))
      ;; Set up an idle timer to reindent after the changed region.
      (save-excursion
        (forward-line 1)
        (set-marker indentinator-start-marker (point))
        (setq indentinator-current-marker
              (copy-marker indentinator-start-marker))
        (setq indentinator-last-indented-marker nil)
        (setq indentinator-idle-timer
              (run-with-idle-timer
               0.1
               nil
               'indentinator-idle-timer-function))))))

(defun indentinator-indent ()
  "Testing function."
  (interactive)
  (save-excursion
    ;; Ignore the field boundaries mentioned in the documentation for
    ;; beginning-of-line.
    (forward-line 0)
    (set-marker indentinator-start-marker (point)))
  (setq indentinator-current-marker
        (copy-marker indentinator-start-marker))
  (setq indentinator-last-indented-marker nil)
  (setq indentinator-idle-timer
        (run-with-idle-timer
         0.1
         nil
         'indentinator-idle-timer-function)))

(defun indentinator-idle-timer-function ()
  "Idle timer function for re-indenting text."
  (when indentinator-idle-timer
    (cancel-timer indentinator-idle-timer)
    (setq indentinator-idle-timer nil))
  
  (let ((indentinator-indenting t)
        (previous-current (copy-marker indentinator-current-marker)))
    ;;(force-mode-line-update)
    (when (indentinator-indent-one)
      (setq indentinator-last-indented-marker
            (copy-marker indentinator-current-marker)))
    ;; Move marker to next indent point.
    (save-excursion
      (goto-char (marker-position indentinator-current-marker))
      (forward-line)
      (set-marker indentinator-current-marker (point)))
    (if (and (not (equal indentinator-current-marker previous-current))
             (or (not indentinator-last-indented-marker)
                 (> 4 (count-lines (marker-position indentinator-last-indented-marker)
                                   (marker-position indentinator-current-marker)))))
        (if (input-pending-p)
            ;; Pending input, abort. Append current position to aborted list.
            (setq indentinator-aborted-markers (cons indentinator-current-marker
                                                     indentinator-aborted-markers))
          ;; Schedule next indent.
          (setq indentinator-idle-timer
                (run-with-idle-timer
                 (time-add (current-idle-time) 0.01)
                 nil
                 'indentinator-idle-timer-function)))
      ;; Else handle previously aborted indents.
      (progn
        ;; Filter out aborted markers we'd accidentally processed in the
        ;; last indent.
        (setq indentinator-aborted-markers
              (seq-filter (lambda (marker)
                            (and (> (marker-position marker)
                                    (marker-position indentinator-start-marker))
                                 (< (marker-position marker)
                                    (marker-position indentinator-current-marker))))
                          indentinator-aborted-markers))
        (when indentinator-aborted-markers
          (setq indentinator-start-marker (car indentinator-aborted-markers))
          (setq indentinator-aborted-markers (cdr indentinator-aborted-markers))
          (setq indentinator-current-marker (copy-marker indentinator-start-marker))
          (setq indentinator-last-indented-marker nil)
          (setq indentinator-idle-timer
                (run-with-idle-timer
                 (time-add (current-idle-time) 0.01)
                 nil
                 'indentinator-idle-timer-function)))))))

(defun indentinator-indent-one ()
  "Re-indent one line at `indentinator-current-marker'.

Return whether the line changed."
  (save-excursion
    (let ((tick (buffer-chars-modified-tick)))
      (goto-char (marker-position indentinator-current-marker))
      (when indentinator-debug
        (message "indentinator: indent %d" (marker-position indentinator-current-marker)))
      (cl-letf (((symbol-function 'message) #'ignore))
        (ignore-errors (funcall indent-line-function)))
      (not (= tick (buffer-chars-modified-tick))))))

(provide 'indentinator)
;;; indentinator.el ends here
