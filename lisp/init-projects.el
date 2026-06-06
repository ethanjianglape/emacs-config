;;; init-projects.el --- Project management -*- lexical-binding: t -*-

;;; Directory browser

(use-package dirvish
  :ensure t
  :init
  ;; Replace dired everywhere — opening a directory uses dirvish instead.
  (dirvish-override-dired-mode)
  :custom
  ;; Layout: no parent panes, listing takes 60%, preview takes 40%.
  (dirvish-default-layout '(0 0.4 0.6))
  ;; Sidebar-style layout when opened with dirvish-side (no preview pane).
  (dirvish-layout-recipes '(no-parents (0 0 1.0)))
  ;; Attributes shown in the listing column.
  (dirvish-attributes '(nerd-icons collapse file-size vc-state))
  (dirvish-use-header-line t)
  ;; Enable mouse support
  (dired-mouse-drag-files t)
  (mouse-drag-and-drop-region-cross-program t)
  :config
  ;; Use nerd-icons (already installed) for file-type icons.
  (with-eval-after-load 'nerd-icons
    (setq dirvish-icon-provider 'nerd-icons)))

;;; Buffer management

(use-package bufler
  :ensure t
  :bind (("C-x b"   . bufler-switch-buffer)  ; filtered/grouped buffer switcher
         ("C-x C-b" . bufler))               ; full grouped buffer list
  :custom
  ;; Filter out internal/noise buffers — they still exist, just hidden from view.
  (bufler-filter-buffer-name-regexps
   '("\\` "                        ; buffers whose name starts with a space
     "\\*Async-native-compile"
     "\\*scratch\\*"
     "\\*Messages\\*"
     "\\*Warnings\\*"
     "\\*Compile-Log\\*"
     "\\*elpaca"
     "\\*eldoc"
     "\\*lsp"))
  :config
  (bufler-mode 1))

;;; Project navigation

(use-package projectile
  :ensure t
  :demand t
  :bind-keymap ("C-c p" . projectile-command-map)
  :custom
  (projectile-sort-order 'recentf)
  (projectile-auto-discover t)
  (projectile-project-search-path '("~/Projects"))
  :config
  (projectile-mode +1))

(use-package helm-projectile
  :ensure t
  :after (helm projectile)
  :config
  (helm-projectile-on))

(use-package treemacs-projectile
  :ensure t
  :after (treemacs projectile))

(provide 'init-projects)
;;; init-projects.el ends here
