;;; init-defaults.el --- Sane built-in defaults -*- lexical-binding: t -*-

;;; Encoding
(set-language-environment "UTF-8")

;;; Files
(setq auto-save-default nil
      make-backup-files nil
      create-lockfiles nil)

;;; History & state
(setq recentf-max-saved-items 200
      savehist-mode 1)
(recentf-mode 1)
(save-place-mode 1)

;;; Native compilation — suppress the async log buffer
(setq native-comp-async-report-warnings-errors 'silent)

;;; Interaction
(setq use-short-answers t              ; y/n instead of yes/no
      confirm-kill-emacs 'yes-or-no-p)

;;; Cursor
(blink-cursor-mode -1)

;;; Editing basics
(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 80)
(delete-selection-mode 1)
(global-auto-revert-mode 1)

(provide 'init-defaults)
;;; init-defaults.el ends here
