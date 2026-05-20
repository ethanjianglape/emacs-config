;;; init-git.el --- Git integration -*- lexical-binding: t -*-

;; Emacs ships an older transient; install a fresh one before magit loads.
(use-package transient
  :ensure t)

(use-package magit
  :ensure t
  :after transient
  :bind ("C-x g" . magit-status))

(use-package diff-hl
  :ensure t
  :config
  (global-diff-hl-mode)
  (diff-hl-flydiff-mode)          ; update indicators without needing to save
  :hook
  (magit-pre-refresh  . diff-hl-magit-pre-refresh)
  (magit-post-refresh . diff-hl-magit-post-refresh))

(provide 'init-git)
;;; init-git.el ends here
