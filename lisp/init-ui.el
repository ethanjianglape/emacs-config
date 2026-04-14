;;; init-ui.el --- Visual appearance -*- lexical-binding: t -*-

;;; Line numbers
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)

;;; Modeline
(column-number-mode 1)

;;; Font
;; (set-face-attribute 'default nil :family "Iosevka" :height 130)

;;; Theme — placeholder
;; (use-package modus-themes :config (load-theme 'modus-vivendi t))

(provide 'init-ui)
;;; init-ui.el ends here
