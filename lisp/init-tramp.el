;;; init-tramp.el --- TRAMP remote file access -*- lexical-binding: t -*-

;; Lightweight config for occasional remote file access via SSH.
;; Not intended for full-time remote development — use VS Code for that.

;;; Core settings

(setq tramp-default-method "ssh"
      tramp-verbose 2
      remote-file-name-inhibit-locks t
      remote-file-name-inhibit-auto-save-visited t
      remote-file-name-inhibit-cache 10)

;;; SSH connection multiplexing

;; ControlMaster reuses the existing SSH connection so subsequent TRAMP
;; operations on the same host don't pay the full handshake cost.
(with-eval-after-load 'tramp
  (setq tramp-ssh-controlmaster-options
        (concat "-o ControlMaster=auto "
                "-o ControlPath=~/.ssh/master-%%r@%%h:%%p "
                "-o ControlPersist=yes "
                "-o ServerAliveInterval=60 "
                "-o ServerAliveCountMax=10")))

;;; Auto-revert

;; Don't poll remote files for changes — each poll is an SSH round-trip.
(setq auto-revert-remote-files nil)

;;; recentf: skip readability checks for remote paths

;; recentf checks file-readable-p when loading its list, which opens SSH
;; connections to every recently visited host. Skip the check for remote paths.
(with-eval-after-load 'recentf
  (setq recentf-keep '(file-remote-p file-readable-p)))

(provide 'init-tramp)
;;; init-tramp.el ends here
