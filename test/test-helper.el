;;; test-helper.el --- Tests for sequences.el  -*- lexical-binding: t; -*-

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Test helper for eclim.el

;;; Code:
(when (require 'undercover nil t)
  (undercover "*.el" (:exclude "*-test.el")))

(require 'f)

(defvar eclim-test-path
  (f-dirname (f-this-file)))

(defvar eclim-code-path
  (f-parent eclim-test-path))

(add-to-list 'load-path eclim-test-path)
(add-to-list 'load-path eclim-code-path)

(defun eclim-emacs-init (action)
  "Initialize Emacs with Cask packages an invoke ACTION."
  (let* ((load-prefer-newer t)
         (source-directory (locate-dominating-file eclim-test-path "Cask"))
         (pkg-rel-dir (format ".cask/%s.%S/elpa" emacs-major-version emacs-minor-version)))

    (setq package-user-dir (expand-file-name pkg-rel-dir source-directory))
    (package-initialize)

    (message "Running tests on Emacs %s, built at %s"
             emacs-version (format-time-string "%F" emacs-build-time))
    (require 'eclim)
    (require 'elisp-lint)
    (funcall action)))

(defun eclim-lint-files ()
  "Main entry point for linter."
  (eclim-emacs-init
   (lambda ()
     (setq elisp-lint-ignored-validators '("package-format"
                                           "fill-column"
                                           "byte-compile"
                                           "indent"))
     (add-hook 'emacs-lisp-mode-hook
               (lambda ()
                 (setq indent-tabs-mode nil)
                 (setq fill-column 80)))
     (let ((debug-on-error t))
       (elisp-lint-files-batch)))))

(defun eclim-run-tests (&optional eclipse-dir)
  "Main entry point for test runner."
  (when eclipse-dir
    (setq eclim-eclipse-dirs (list eclipse-dir)))

  (eclim-emacs-init
   (lambda ()
     (let ((tests (directory-files "./test" t "test.el")))
       (while tests
         (load-file (car tests))
         (setq tests (cdr tests))))

     ;; File in which `eclim-executable' is set:
     (require 'eclim-common)

     (let ((debug-on-error t)
           (test-selector (if eclim-executable
                              t
                            (message "Warning: No eclim executable found. \
Supply Eclipse directory when testing:
   make test TEST_ECLIPSE_DIR='\"/my/local/eclipse/\"'
   Skipping tests that require the eclim executable.")
                            '(not (tag :eclim-executable-required)))))
       (ert-run-tests-batch-and-exit test-selector)))))


;;; test-helper.el ends here
