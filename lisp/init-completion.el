;;; init-completion.el --- Minibuffer & in-buffer completion -*- lexical-binding: t -*-

;;; Minibuffer

(defun my-helm-display-frame-center (buffer &optional resume)
  "Display `helm-buffer' in a separate frame which centered in parent frame."
  (if (not (display-graphic-p))
      ;; Fallback to default when frames are not usable.
      (helm-default-display-buffer buffer)
    (setq helm--buffer-in-new-frame-p t)
    (let* ((parent (selected-frame))
           (frame-pos (frame-position parent))
           (parent-left (car frame-pos))
           (parent-top (cdr frame-pos))
           (width (/ (frame-width parent) 2))
           (height (/ (frame-height parent) 3))
           tab-bar-mode
           (default-frame-alist
            (if resume
                (buffer-local-value 'helm--last-frame-parameters
                                    (get-buffer buffer))
              `((parent . ,parent)
                (width . ,width)
                (height . ,height)
                (undecorated . ,helm-use-undecorated-frame-option)
                (left-fringe . 0)
                (right-fringe . 0)
                (tool-bar-lines . 0)
                (line-spacing . 0)
                (desktop-dont-save . t)
                (no-special-glyphs . t)
                (inhibit-double-buffering . t)
                (left . ,(+ parent-left (/ (* (frame-char-width parent) (frame-width parent)) 4)))
                (top . ,(+ parent-top (/ (* (frame-char-height parent) (frame-height parent)) 6)))
                (title . "Helm")
                (vertical-scroll-bars . nil)
                (menu-bar-lines . 0)
                (fullscreen . nil)
                (visible . ,(null helm-display-buffer-reuse-frame))
                (internal-border-width . 12)
                )))
           display-buffer-alist)
      (set-face-background 'internal-border (face-foreground 'default))
      (helm-display-buffer-popup-frame buffer default-frame-alist))))

(use-package helm
  :ensure t
  :demand t
  :bind (("M-x"     . helm-M-x)
         ("C-x C-f" . helm-find-files)
         ("M-y"     . helm-show-kill-ring)
         ("C-s"     . helm-occur)
         ("M-s g"   . helm-grep-do-git-grep))
  :custom
  (helm-move-to-line-cycle-in-source t) ; wrap around at top/bottom
  (helm-M-x-fuzzy-match t)
  (helm-buffers-fuzzy-matching t)
  (helm-recentf-fuzzy-match t)
  (helm-ff-file-name-history-use-recentf t)
  (helm-display-function #'my-helm-display-frame-center)
  (helm-display-buffer-reuse-frame t)
  (helm-use-undecorated-frame-option t)
  :config
  (helm-mode 1)
  (add-hook 'helm-major-mode-hook
            (lambda () (setq-local mode-line-format nil))))

;;; In-buffer

;; As-you-type completion popup
(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  (corfu-quit-no-match 'separator)
  :init (global-corfu-mode)
  :hook
  ;; Org is prose — dabbrev sentence suggestions are more annoying than
  ;; helpful there, so disable the popup entirely.
  (org-mode . (lambda () (corfu-mode -1))))

;; Extra completion-at-point sources (files, words, etc.)
(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

(provide 'init-completion)
;;; init-completion.el ends here
