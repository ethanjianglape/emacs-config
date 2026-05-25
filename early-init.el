;;; early-init.el --- Early initialization -*- lexical-binding: t -*-

;; Runs before the package system and GUI is initialized.

;;; Performance

;; Maximize GC threshold during startup; gcmh takes over afterwards.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

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
        (horizontal-scroll-bars . nil)
        (fullscreen . maximized)
        (cursor-type . bar)))

(setq frame-inhibit-implied-resize t
      inhibit-startup-screen t)

;;; early-init.el ends here
