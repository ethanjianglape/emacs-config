;;; init-git.el --- Git integration -*- lexical-binding: t -*-

;; Emacs ships older versions of these magit dependencies; install fresh ones first.
(use-package transient
  :ensure t)

(use-package with-editor
  :ensure t)

(use-package magit
  :ensure t
  :after (transient with-editor)
  :bind ("M-g" . magit-status))

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
