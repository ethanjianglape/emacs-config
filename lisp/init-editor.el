;;; init-editor.el --- Editor enhancements -*- lexical-binding: t -*-

;;; Context menu (right-click)
(context-menu-mode 1)

;;; Smart pair completion ( [ { " '
(electric-pair-mode 1)

;;; Delimiter colors by nesting depth
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

;;; Highlight the pair surrounding the cursor
(use-package highlight-parentheses
  :ensure t
  :hook (prog-mode . highlight-parentheses-mode)
  :custom
  (highlight-parentheses-highlight-adjacent t)
  ;; One entry = only the innermost surrounding pair is highlighted
  (highlight-parentheses-attributes '((:weight bold :inherit show-paren-match))))

;;; Terminal
(use-package vterm
  :ensure t
  :custom
  (vterm-max-scrollback 10000)
  (vterm-kill-buffer-on-exit t)
  :hook
  (vterm-mode . (lambda ()
                  (setq-local mode-line-format nil)
                  (set-process-query-on-exit-flag (get-buffer-process (current-buffer)) nil))))

(defvar my/vterm-height 18
  "Height in lines of the persistent bottom vterm window.")

(defun my/open-vterm-bottom ()
  "Open vterm in a bottom side window that survives C-x 1."
  (let ((buf (save-window-excursion (vterm) (current-buffer))))
    (display-buffer-in-side-window
     buf `((side          . bottom)
           (slot          . 0)
           (window-height . ,my/vterm-height)
           (preserve-size . (nil . t))
           (window-parameters . ((no-delete-other-windows . t)))))))

(add-hook 'emacs-startup-hook #'my/open-vterm-bottom)


;; When centaur-tabs "+" creates a new vterm, open it in the side window
(with-eval-after-load 'centaur-tabs-functions
  (advice-add 'centaur-tabs--create-new-tab :around
              (lambda (orig-fn)
                (if (not (derived-mode-p 'vterm-mode))
                    (funcall orig-fn)
                  (let ((buf (save-window-excursion (vterm t) (current-buffer))))
                    (display-buffer-in-side-window
                     buf `((side          . bottom)
                           (slot          . 0)
                           (window-height . ,my/vterm-height)
                           (preserve-size . (nil . t))
                           (window-parameters . ((no-delete-other-windows . t))))))))))

;;; Persistent bottom panel for terminals, compilation buffers, etc.
(use-package popper
  :ensure t
  :bind (("C-`" . popper-toggle)
         ("M-`" . popper-cycle))
  :custom
  (popper-reference-buffers '(vterm-mode
                               "\\*vterm.*\\*"
                               "\\*compilation\\*"
                               compilation-mode))
  (popper-display-function #'display-buffer-in-side-window)
  (popper-display-parameters '((side          . bottom)
                                (slot          . 0)
                                (window-height . my/vterm-height)
                                (preserve-size . (nil . t))))
  (popper-window-height 18)
  :config
  (popper-mode +1))

;;; Format on save via apheleia (calls formatters directly, bypasses LSP)
(use-package apheleia
  :ensure t
  :config
  (apheleia-global-mode +1))

(provide 'init-editor)
;;; init-editor.el ends here
