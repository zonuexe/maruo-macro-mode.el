;;; maruo-macro-mode.el --- Major mode for editing Hidemaru/Maruo macro script

;; Copyright (C) 2016 USAMI Kenta

;; Author: USAMI Kenta <tadsan@zonu.me>
;; Created: 4 May 2016
;; Keywords: programming editor macro

;; This file is NOT part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This is a major-mode for editing Hidemaru/Maruo editor macro script.


;;; Code:
(require 'imenu)

(defgroup maruo-macro nil
  "Hidemaru/Maruo editor macro script."
  :group 'languages)

(defcustom maruo-macro-mode-use-tab t
  "Indentation can insert tabs in Maruo macro mode if this is non-nil.")

(defcustom maruo-macro-mode-offset 4
  "Indentation of Maruo macro statement.")

(defconst maruo-macro--re-keywords
  (regexp-opt
   '("if" "else" "return" "endmacro" "message" "while" "call"
     "result" "yes" "no" "true" "false" "eof" "version" "platform"))
  "Rexexp matching Maruo macro language keyword.")

(defconst maruo-macro--re-variable-name
  "\\(\\(?:$$?\\|##?\\)[_A-Za-z][_A-Za-z0-1]*\\)"
  "Rexexp matching Maruo macro variable name.")

(defconst maruo-macro--re-subroutine-name
  "^\\([_A-Za-z][_A-Za-z0-1]*\\):"
  "Rexexp matching Maruo macro subroutine name.")

(defconst maruo-macro--re-argument-variable
  "\\(\\$\\$\\|##\\)[0-9]"
  "Rexexp matching Maruo macro subroutine argument variable.")

(defvar maruo-macro-mode-keywords
  (list
   (cons maruo-macro--re-variable-name font-lock-variable-name-face)
   (cons maruo-macro--re-argument-variable font-lock-variable-name-face)
   (cons maruo-macro--re-subroutine-name font-lock-function-name-face)
   (cons maruo-macro--re-keywords font-lock-keyword-face))
  "Font lock keywords for Maruo macro.")

(defconst maruo-macro-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?_  "_" table)
    (modify-syntax-entry ?/  ". 124" table)
    (modify-syntax-entry ?+  "." table)
    (modify-syntax-entry ?-  "." table)
    (modify-syntax-entry ?*  "." table)
    (modify-syntax-entry ?\n ">" table)
    table))

;; (defvar maruo-macro-imenu-generic-expression
;;   (list
;;    (list nil maruo-macro--re-subroutine-name 1)
;;    (list "Variables" maruo-macro--re-variable-name 0)))

(defun maruo-macro--index-re (regexp)
  "Return list of keywords that searched by REGEXP."
  (let (index)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward regexp (point-max) t)
        (push (cons (match-string 1) (match-beginning 1)) index)))
    (nreverse index)))

(defun maruo-macro-imenu-create-index ()
  "Create imenu index for Maruo macro."
  (let ((variables   (maruo-macro--index-re maruo-macro--re-variable-name))
        (subroutines (maruo-macro--index-re maruo-macro--re-subroutine-name)))
    (list
     (cons "Variables"   variables)
     (cons "Subroutines" subroutines))))


;;;###autoload
(define-derived-mode maruo-macro-mode prog-mode "[秀]macro"
  "Major mode for editing Maruo macro."
  (set-syntax-table maruo-macro-mode-syntax-table)

  ;;(setq imenu-generic-expression maruo-macro-imenu-generic-expression)
  (setq imenu-create-index-function 'maruo-macro-imenu-create-index)
  (setq-local indent-tabs-mode nil)
  (setq-local comment-start "//")
  (setq-local comment-end "")
  (setq font-lock-defaults '(maruo-macro-mode-keywords))

  (setq tab-width maruo-macro-mode-offset)
  (setq indent-tabs-mode maruo-macro-mode-use-tab)

  (setq-local indent-line-function 'indent-to-left-margin))

;;;###autoload
(defalias 'hidemaru-macro-mode 'maruo-macro-mode)

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.mac\\'" . maruo-macro-mode))

(provide 'maruo-macro-mode)
;;; maruo-macro-mode.el ends here
