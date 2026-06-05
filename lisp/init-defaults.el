;;; init-defaults.el --- Sane built-in defaults -*- lexical-binding: t -*-

;;; Encoding
(set-language-environment "UTF-8")

;;; Files
(setq auto-save-default nil
      make-backup-files nil
      create-lockfiles nil)

;;; History & state
(setq recentf-max-saved-items 200)
(recentf-mode 1)
(savehist-mode 1)
(save-place-mode 1)

;;; Native compilation — suppress the async log buffer
(setq native-comp-async-report-warnings-errors 'silent)

;;; Performance

;; Smarter GC: high threshold while active, collect during idle time.
;; Replaces the manual post-startup reset in early-init.el.
(use-package gcmh
  :ensure t
  :config
  (gcmh-mode 1))

;; Disable bidi (right-to-left text) reordering — irrelevant for code,
;; expensive on every line of every buffer.
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bidi-mirroring t)

;; Prevent GC pauses from compacting the font cache (relevant given the
;; number of nerd-icon glyphs loaded by the UI packages).
(setq inhibit-compacting-font-caches t)

;; Defer font-lock updates slightly so keystrokes feel immediate.
(setq jit-lock-defer-time 0.1)

;;; Interaction
(setq use-short-answers t              ; y/n instead of yes/no
      confirm-kill-emacs 'yes-or-no-p)

;; Clicking the echo area opens *Messages* by default — disable it.
(define-key minibuffer-inactive-mode-map [mouse-1] #'ignore)

;;; Cursor
(blink-cursor-mode -1)

;;; Editing basics
(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 80)
(delete-selection-mode 1)
(global-auto-revert-mode 1)

(setq remote-file-name-inhibit-locks t
      tramp-use-scp-direct-remote-copying t
      remote-file-name-inhibit-auto-save-visited t)

(setq tramp-copy-size-limit (* 1024 1024) ;; 1MB
      tramp-verbose 2)

(provide 'init-defaults)
;;; init-defaults.el ends here
