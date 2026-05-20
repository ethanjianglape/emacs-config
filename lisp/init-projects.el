;;; init-projects.el --- Project management -*- lexical-binding: t -*-

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
  (helm-projectile-on))  ; replaces projectile's defaults with helm variants

(use-package treemacs-projectile
  :ensure t
  :after (treemacs projectile))


(provide 'init-projects)
;;; init-projects.el ends here
