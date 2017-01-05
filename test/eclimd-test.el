;;; eclimd-test.el --- Tests for eclimd.el           -*- lexical-binding: t; -*-

;; Copyright (C) 2017  Luis Gerhorst

;; Author: Luis Gerhorst
;; Keywords: java, eclipse, eclim

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

;; Tests for functions controling eclimd.

;;; Code:

(require 'eclimd)
(require 'eclim-common)

(ert-deftest eclim-connected-after-sync-start-eclimd ()
  :tags '(:eclim-executable-required)
  (unwind-protect
      (progn
        (let ((eclimd-wait-for-process t))
          (start-eclimd eclimd-default-workspace)
          (should (eclim--connected-p))))
    (stop-eclimd)))

(provide 'eclimd-test)
;;; eclimd-test.el ends here
