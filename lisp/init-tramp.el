;;; init-tramp.el --- TRAMP / remote file performance -*- lexical-binding: t -*-

;; Consolidates all TRAMP tuning for VDI (SSH) and devcontainer workflows.

;;; ──────────────────────────────────────────────
;;; Core settings

(setq tramp-default-method "ssh"
      tramp-verbose 2
      tramp-copy-size-limit (* 1024 1024)
      tramp-use-scp-direct-remote-copying t
      remote-file-name-inhibit-locks t
      remote-file-name-inhibit-auto-save-visited t
      ;; Cache remote file attributes briefly — avoids a round-trip on every
      ;; stat/access check while still reflecting changes made by other processes.
      remote-file-name-inhibit-cache 10)

;;; ──────────────────────────────────────────────
;;; SSH connection multiplexing

;; ControlMaster=auto: the first TRAMP connection opens a master socket and
;; subsequent connections reuse it without renegotiating auth.  ControlPersist
;; keeps the master alive after the last session so the next command reconnects
;; in milliseconds instead of doing a full handshake.
;; ServerAliveInterval sends a keepalive every 60 s so the VDI doesn't drop
;; the connection during idle periods (e.g. while reading or context-switching).
(with-eval-after-load 'tramp
  (setq tramp-ssh-controlmaster-options
        (concat "-o ControlMaster=auto "
                "-o ControlPath=~/.ssh/master-%%r@%%h:%%p "
                "-o ControlPersist=yes "
                "-o ServerAliveInterval=60 "
                "-o ServerAliveCountMax=10")))

;;; ──────────────────────────────────────────────
;;; Disable VC for remote files

;; vc-mode runs git/hg status probes on every remote buffer visit, generating
;; SSH round-trips.  Magit handles all real git operations.
(defun my/tramp-disable-vc ()
  (when (file-remote-p default-directory)
    (setq-local vc-handled-backends nil)))
(add-hook 'find-file-hook #'my/tramp-disable-vc)
(add-hook 'dired-mode-hook #'my/tramp-disable-vc)

;;; ──────────────────────────────────────────────
;;; Auto-revert

;; Auto-revert polls file mtime — one SSH round-trip per poll interval.
(setq auto-revert-remote-files nil)

;;; ──────────────────────────────────────────────
;;; recentf: keep remote paths without blocking startup

;; recentf verifies file readability when loading its list, which would open
;; SSH connections to every recently visited VDI host.  Keep a path if it's
;; remote (skip the check) or locally readable.
(with-eval-after-load 'recentf
  (setq recentf-keep '(file-remote-p file-readable-p)))

;;; ──────────────────────────────────────────────
;;; eglot over TRAMP

;; withhold-process-id: avoids PID mismatches inside container runtimes.
;; Longer connect timeout for VDI sessions that are slow to warm up on first use.
(with-eval-after-load 'eglot
  (setq eglot-withhold-process-id t
        eglot-connect-timeout 60))

;;; ──────────────────────────────────────────────
;;; helm + tramp-rpc: fix first-visit empty directory listing

;; Helm sets non-essential=t when building file candidates to avoid blocking
;; on slow completions.  tramp-rpc sees this and skips connection setup,
;; returning an empty listing on first visit to an /rpc: path.  Binding
;; non-essential=nil for rpc paths forces the connection to be established so
;; the first directory display works correctly.
(with-eval-after-load 'helm-files
  (advice-add 'helm-ff-directory-files :around
              (lambda (orig dir &rest args)
                (if (string-match-p "\\`/rpc:" (or dir ""))
                    (let ((non-essential nil))
                      (apply orig dir args))
                  (apply orig dir args)))))

;;; ──────────────────────────────────────────────
;;; tramp-rpc: binary-protocol TRAMP backend

;; Uses a lightweight Rust server on the remote to handle file ops via
;; MessagePack-RPC instead of shelling out — 2-38x faster for stat-heavy
;; operations (magit, projectile indexing).  Requires Emacs 30.1+.
;; Access remote files with /rpc:host:/path instead of /ssh:host:/path.
;; Note: multi-hop to docker containers (/rpc:vdi|docker:container:) is
;; unverified — fall back to /ssh:vdi|docker:container: for those.
(use-package tramp-rpc
  :ensure (:host github :repo "ArthurHeymans/emacs-tramp-rpc" :files ("lisp/*.el"))
  :after tramp
  :config
  (setq tramp-rpc-deploy-never-deploy t
        tramp-rpc-deploy-remote-binary-path "/home/ethan.lape@torc.ai/.cache/emacs/tramp-rpc/tramp-rpc-server"))

;;; ──────────────────────────────────────────────
;;; Multi-hop: VDI → devcontainer

;; TRAMP multi-hop syntax to open a devcontainer inside a VDI over SSH:
;;   C-x C-f /ssh:vdi-host|docker:container-name:/workspace/path
;;
;; To avoid typing the full hop every time, configure a proxy so TRAMP
;; automatically routes docker connections through the right VDI host:
;;   M-x my/tramp-add-vdi-proxy
;;
;; Or hardcode it here for a fixed setup:
;;   (add-to-list 'tramp-default-proxies-alist
;;                '("my-container" nil "/ssh:my-vdi-host:"))

(defun my/tramp-add-vdi-proxy (vdi-host container)
  "Route TRAMP docker connections to CONTAINER through VDI-HOST via SSH.
After calling this, open the container with just /docker:CONTAINER:/path."
  (interactive (list (read-string "VDI hostname: ")
                     (read-string "Container name (regexp ok): ")))
  (add-to-list 'tramp-default-proxies-alist
               `(,container nil ,(format "/ssh:%s:" vdi-host)))
  (message "TRAMP: /docker:%s: → ssh:%s → docker" container vdi-host))

(provide 'init-tramp)
;;; init-tramp.el ends here
