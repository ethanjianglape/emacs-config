;;; init-keybinds.el --- Keybindings -*- lexical-binding: t -*-

;;; Disable accidental-exit / suspend keys
(global-unset-key (kbd "C-z"))       ; suspend-frame
(global-unset-key (kbd "C-x C-z"))   ; suspend-frame (alternate)
(global-unset-key (kbd "C-x C-c"))   ; save-buffers-kill-terminal

(global-set-key (kbd "C-,") #'xref-go-back)
(global-set-key (kbd "C-.") #'xref-go-forward)
(global-set-key (kbd "C-t") #'beginning-of-buffer)
(global-set-key (kbd "M-r") #'eglot-rename)
(global-set-key (kbd "M-k") #'kill-current-buffer)
(global-set-key (kbd "C-c <left>") #'centaur-tabs-backward-tab)
(global-set-key (kbd "C-c <right>") #'centaur-tabs-forward-tab)
(global-set-key (kbd "C-;") #'comment-line)
(global-set-key (kbd "C-x <up>") #'enlarge-window)
(global-set-key (kbd "C-x <down>") #'shrink-window)

(provide 'init-keybinds)
;;; init-keybinds.el ends here
