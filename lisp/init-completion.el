;;; init-completion.el --- Minibuffer & in-buffer completion -*- lexical-binding: t -*-

;;; Minibuffer

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
  (helm-display-function #'helm-display-buffer-in-own-frame)
  (helm-display-buffer-reuse-frame t)
  (helm-use-undecorated-frame-option t)
  :config
  (helm-mode 1)
  ;; Clean up the helm frame: padding + no mode-line
  (add-hook 'helm-after-initialize-hook
            (lambda ()
              (when (frame-live-p helm-popup-frame)
                (set-frame-parameter helm-popup-frame 'internal-border-width 12)
                (set-face-background 'internal-border "#abb2bf" helm-popup-frame)
                (set-frame-width helm-popup-frame 160))))
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
  :init (global-corfu-mode))

;; Extra completion-at-point sources (files, words, etc.)
(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

(provide 'init-completion)
;;; init-completion.el ends here
