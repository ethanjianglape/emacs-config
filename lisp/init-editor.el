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

(defun my/vterm-next-name ()
  "Return the lowest unused terminal buffer name (term 1, term 2, …)."
  (let ((index 1))
    (while (get-buffer (format "term %d" index))
      (cl-incf index))
    (format "term %d" index)))

(defun my/open-vterm-bottom ()
  "Open vterm in a bottom side window that survives C-x 1."
  (let ((buf (save-window-excursion (vterm (my/vterm-next-name)) (current-buffer))))
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
                  (let ((buf (save-window-excursion
                               (vterm (my/vterm-next-name))
                               (current-buffer))))
                    (display-buffer-in-side-window
                     buf `((side          . bottom)
                           (slot          . 0)
                           (window-height . ,my/vterm-height)
                           (preserve-size . (nil . t))
                           (window-parameters . ((no-delete-other-windows . t))))))))))

;;; Popup panel for transient output buffers
;;
;; vterm is intentionally excluded — it lives in its own persistent side window
;; managed by my/open-vterm-bottom and should never be treated as a popup.
(use-package popper
  :ensure t
  :bind (("C-`" . popper-toggle)
         ("M-`" . popper-cycle))
  :custom
  (popper-reference-buffers '(compilation-mode
                              "\\*compilation\\*"
                              "\\*grep\\*"
                              "\\*xref\\*"
                              help-mode))
  (popper-window-height 18)
  :config
  (popper-mode +1))

;;; Format on save via apheleia (calls formatters directly, bypasses LSP)
(use-package apheleia
  :ensure t
  :config
  (apheleia-global-mode +1))

;;; Code folding via tree-sitter
;;
;; Folds at exact syntax boundaries (functions, structs, if blocks, etc.)
;; using the parse tree rather than just matching braces.
;; Fold indicators appear in the fringe to the left of line numbers.
;;
;;   C-c f t   toggle fold at point
;;   C-c f c   close all folds in buffer
;;   C-c f o   open all folds in buffer
;;   C-c f r   open fold at point and all nested folds inside it

(use-package treesit-fold
  :ensure t
  :hook (((c-ts-mode c++-ts-mode cmake-ts-mode
                     js-ts-mode typescript-ts-mode tsx-ts-mode) . treesit-fold-mode)
         (treesit-fold-mode . treesit-fold-indicators-mode))
  :bind (:map treesit-fold-mode-map
              ("C-c f t" . treesit-fold-toggle)
              ("C-c f c" . treesit-fold-close-all)
              ("C-c f o" . treesit-fold-open-all)
              ("C-c f r" . treesit-fold-open-recursively)))

(provide 'init-editor)
;;; init-editor.el ends here
