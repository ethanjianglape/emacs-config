;;; init-keybinds.el --- Keybindings -*- lexical-binding: t -*-

;;; Project shortcuts
(global-set-key (kbd "M-p") #'helm-projectile-find-file)

;;; Disable accidental-exit / suspend keys
(global-unset-key (kbd "C-z"))       ; suspend-frame
(global-unset-key (kbd "C-x C-z"))   ; suspend-frame (alternate)
(global-unset-key (kbd "C-x C-c"))   ; save-buffers-kill-terminal

(provide 'init-keybinds)
;;; init-keybinds.el ends here
