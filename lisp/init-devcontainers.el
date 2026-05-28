;;; init-devcontainers.el --- Dev container support -*- lexical-binding: t -*-

;; Two supported paths — all commands available via M-x:
;;
;; VDI path  (local Docker via devcontainer CLI)
;;   Requires: npm install -g @devcontainers/cli
;;
;; Coder path (remote workspace via SSH)
;;   Requires: coder CLI + run M-x my/coder-config-ssh once to populate ~/.ssh/config

;;; ──────────────────────────────────────────────
;;; Shared: eglot over TRAMP
;;
;; Both paths surface files via TRAMP.  eglot auto-detects TRAMP buffers
;; and runs the language server inside the remote environment — no extra
;; setup needed as long as the container/workspace image has the LSP servers.
;;   - withhold-process-id: avoids PID mismatches on some container runtimes
;;   - connect-timeout:     workspaces can be slow to respond on first connect

(with-eval-after-load 'eglot
  (setq eglot-withhold-process-id t)
  (setq eglot-connect-timeout 60))

;;; ──────────────────────────────────────────────
;;; VDI path: devcontainer CLI

(use-package devcontainer
  :ensure t
  :custom
  (devcontainer-executable "devcontainer"))

(defun my/devcontainer-vterm ()
  "Open a vterm shell inside the current project's devcontainer."
  (interactive)
  (let* ((project-root (or (projectile-project-root) default-directory))
         (buf-name (format "devcontainer: %s"
                           (file-name-nondirectory (directory-file-name project-root))))
         (buf (get-buffer buf-name)))
    (if (and buf (buffer-live-p buf))
        (display-buffer-in-side-window
         buf `((side . bottom) (slot . 0) (window-height . ,my/vterm-height)
               (preserve-size . (nil . t))
               (window-parameters . ((no-delete-other-windows . t)))))
      (let ((vterm-shell (format "devcontainer exec --workspace-folder %s /bin/sh"
                                 (shell-quote-argument project-root))))
        (let ((new-buf (save-window-excursion (vterm buf-name) (current-buffer))))
          (display-buffer-in-side-window
           new-buf `((side . bottom) (slot . 0) (window-height . ,my/vterm-height)
                     (preserve-size . (nil . t))
                     (window-parameters . ((no-delete-other-windows . t))))))))))

;;; ──────────────────────────────────────────────
;;; Coder path: SSH/TRAMP

;; coder config-ssh writes entries like "coder.<workspace>" into ~/.ssh/config.
;; TRAMP then accesses them as /ssh:coder.<workspace>:/path.

(defvar my/coder-ssh-host-prefix "coder."
  "Prefix that `coder config-ssh` prepends to workspace names in ~/.ssh/config.")

(defun my/coder--workspaces ()
  "Return a list of Coder workspace names from `coder list`."
  (when (executable-find "coder")
    (let ((output (shell-command-to-string "coder list --output json 2>/dev/null")))
      (condition-case nil
          (mapcar (lambda (ws) (cdr (assq 'name (if (listp ws) ws (list ws)))))
                  (json-parse-string output :object-type 'alist :array-type 'list))
        (error
         (let (names)
           (dolist (line (split-string output "\n" t))
             (when (string-match "\\`\\([a-zA-Z0-9_-]+\\)" line)
               (push (match-string 1 line) names)))
           (nreverse names)))))))

(defun my/coder-connect (workspace)
  "Open the home directory of a Coder WORKSPACE via TRAMP."
  (interactive
   (list (completing-read "Coder workspace: "
                          (or (my/coder--workspaces) nil)
                          nil nil)))
  (find-file (format "/ssh:%s%s:~/" my/coder-ssh-host-prefix workspace)))

(defun my/coder-vterm (workspace)
  "Open a vterm shell inside a Coder WORKSPACE."
  (interactive
   (list (completing-read "Coder workspace: "
                          (or (my/coder--workspaces) nil)
                          nil nil)))
  (let* ((buf-name (format "coder: %s" workspace))
         (buf (get-buffer buf-name)))
    (if (and buf (buffer-live-p buf))
        (display-buffer-in-side-window
         buf `((side . bottom) (slot . 0) (window-height . ,my/vterm-height)
               (preserve-size . (nil . t))
               (window-parameters . ((no-delete-other-windows . t)))))
      (let ((vterm-shell (format "coder ssh %s" (shell-quote-argument workspace))))
        (let ((new-buf (save-window-excursion (vterm buf-name) (current-buffer))))
          (display-buffer-in-side-window
           new-buf `((side . bottom) (slot . 0) (window-height . ,my/vterm-height)
                     (preserve-size . (nil . t))
                     (window-parameters . ((no-delete-other-windows . t))))))))))

(defun my/coder-config-ssh ()
  "Re-run `coder config-ssh` to refresh workspace entries in ~/.ssh/config."
  (interactive)
  (let ((buf (get-buffer-create "*coder config-ssh*")))
    (with-current-buffer buf (erase-buffer))
    (make-process :name "coder-config-ssh"
                  :buffer buf
                  :command '("coder" "config-ssh" "--yes")
                  :sentinel (lambda (_proc event)
                              (when (string-prefix-p "finished" event)
                                (message "coder config-ssh: done"))))))

(provide 'init-devcontainers)
;;; init-devcontainers.el ends here
