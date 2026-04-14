;;; early-init.el --- Early initialization -*- lexical-binding: t -*-

;; Runs before the package system and GUI is initialized.

;;; Performance

;; Defer garbage collection during startup
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))

;; Suppress native-comp warnings
(setq native-comp-async-report-warnings-errors 'silent)

;;; Package

;; Disable package.el early so it doesn't load at all — we use elpaca
(setq package-enable-at-startup nil)

;;; UI — suppress before frame creation to avoid flicker

(setq default-frame-alist
      '((menu-bar-lines . 0)
        (tool-bar-lines . 0)
        (vertical-scroll-bars . nil)
        (horizontal-scroll-bars . nil)))

(setq frame-inhibit-implied-resize t
      inhibit-startup-screen t)

;;; early-init.el ends here
