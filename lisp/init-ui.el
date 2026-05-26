;;; init-ui.el --- Visual appearance -*- lexical-binding: t -*-

;;; Theme
(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-one t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config)
  ;; doom-one comments are intentionally muted (#5B6268); make them italic
  ;; and slightly brighter so they're clearly distinct from dead code.
  (set-face-attribute 'font-lock-comment-face nil :slant 'italic)
  (set-face-attribute 'font-lock-comment-delimiter-face nil :slant 'italic))

;;; File browser sidebar
(use-package treemacs
  :ensure t
  :demand t
  :bind ("C-c t" . treemacs)
  :custom
  (treemacs-width 30)
  (treemacs-width-is-initially-locked nil)
  (treemacs-is-never-other-window t)
  (treemacs-show-hidden-files t)
  (treemacs-follow-after-init t)   ; expand to current file on open
  (treemacs-recenter-after-file-actions t)
  :config
  (treemacs-follow-mode t)         ; keep sidebar in sync with current buffer
  (treemacs-filewatch-mode t)      ; auto-refresh on filesystem changes
  (treemacs-fringe-indicator-mode t)
  (treemacs-hide-gitignored-files-mode t)
  (treemacs-git-mode 'deferred)    ; async git status — keeps UI responsive
  :hook
  (emacs-startup . treemacs)
  (treemacs-mode . (lambda () (setq-local mode-line-format nil))))

(use-package treemacs-nerd-icons
  :ensure t
  :after (treemacs nerd-icons)
  :config (treemacs-load-theme "nerd-icons"))

(use-package treemacs-magit
  :ensure t
  :after (treemacs magit))

;;; Buffer tabs
(use-package centaur-tabs
  :ensure t
  :demand t
  :custom
  (centaur-tabs-style "bar")
  (centaur-tabs-height 28)
  (centaur-tabs-set-icons t)
  (centaur-tabs-icon-type 'nerd-icons)
  (centaur-tabs-set-modified-marker t)   ; dot on unsaved buffers
  (centaur-tabs-modified-marker "●")
  (centaur-tabs-set-close-button nil)    ; no per-tab close button
  :bind (("C-<prior>" . centaur-tabs-backward)   ; C-PageUp
         ("C-<next>"  . centaur-tabs-forward))    ; C-PageDown
  :config
  (centaur-tabs-mode 1)
  (defun my/centaur-tabs-buffer-groups ()
    (cond
     ((derived-mode-p 'vterm-mode)     '("Terminal"))
     ((derived-mode-p 'treemacs-mode)  '())
     ;; Returning '() excludes the buffer from all groups — same trick as
     ;; treemacs above.  This is more reliable than the hide-tab cache
     ;; because centaur-tabs checks groups before it checks hide-tab.
     ((derived-mode-p 'magit-mode)     '())
     (t (centaur-tabs-projectile-buffer-groups))))
  (setq centaur-tabs-buffer-groups-function #'my/centaur-tabs-buffer-groups)
  (defun my/centaur-tabs-hide-tab (x)
    (let ((name (format "%s" x)))
      (or
       ;; Hide all *Name* special/internal buffers (catches messages, etc.)
       (and (string-prefix-p "*" name) (string-suffix-p "*" name))
       ;; Belt-and-suspenders: all magit buffer names start with "magit".
       (string-prefix-p "magit" name))))
  (setq centaur-tabs-hide-tab-function #'my/centaur-tabs-hide-tab)
  ;; Clear the hide-tab result cache so any already-visible magit tabs
  ;; are re-evaluated immediately rather than served stale cached values.
  (when (boundp 'centaur-tabs-hide-hash)
    (clrhash centaur-tabs-hide-hash)))

;;; Which-key (built-in since Emacs 30; installed via elpaca on 29)
(if (>= emacs-major-version 30)
    (use-package which-key :ensure nil :init (which-key-mode))
  (use-package which-key :ensure t   :init (which-key-mode)))

;;; Line numbers
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)

;;; Highlight current line
(global-hl-line-mode 1)

;;; Indentation guides
(use-package indent-bars
  :ensure t
  :hook (prog-mode . indent-bars-mode)
  :custom
  ;; treesit-support causes arith-errors on C++ node types; plain
  ;; whitespace-based bar placement works correctly without it.
  (indent-bars-treesit-support nil)
  ;; Don't draw a bar inside string literals.
  (indent-bars-no-descend-string t))

;;; Modeline
(use-package nerd-icons
  :ensure t)

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 28)
  (doom-modeline-bar-width 4)
  (doom-modeline-minor-modes nil)   ; hide the minor mode clutter
  (doom-modeline-buffer-encoding nil) ; hide UTF-8 etc.
  (doom-modeline-percent-position nil) ; no position percentage
  (doom-modeline-column-zero-based nil)
  (doom-modeline-position-line-format '("L%l C%c"))
  (doom-modeline-position-column-line-format '("L%l C%c")))

;;; Dashboard

(use-package dashboard
  :ensure t
  :custom
  (dashboard-banner-logo-title "")
  (dashboard-startup-banner 'logo)
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  (dashboard-projects-backend 'projectile)
  (dashboard-items '((recents   . 8)
                     (projects  . 5)
                     (bookmarks . 5)))
  (dashboard-display-icons-p t)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  :config
  (dashboard-setup-startup-hook))

;;; Font
(let ((font (if (member "Source Code Pro" (font-family-list))
                "Source Code Pro"
              "Monospace")))
  (set-face-attribute 'default nil :family font :height 130)
  (set-face-attribute 'fixed-pitch nil :family font)
  (set-face-attribute 'variable-pitch nil :family font))

;;; CJK font: KaiTi for Chinese characters
;;
;; `set-fontset-font' registers a fallback font for a Unicode script.
;; Targeting `'han' covers the full CJK Unified Ideographs block so
;; any Chinese character not covered by the primary font falls back to
;; KaiTi.  The guard prevents an error if the font is ever missing.
;;
;; KaiTi renders a bit small relative to Latin glyphs at the same point
;; size, so we bump it to 15pt (the default face is 13pt / height 130).
;; Adjust the :size value here to taste.
(when (member "KaiTi" (font-family-list))
  (set-fontset-font t 'han (font-spec :family "KaiTi" :size 26)))

(provide 'init-ui)
;;; init-ui.el ends here
