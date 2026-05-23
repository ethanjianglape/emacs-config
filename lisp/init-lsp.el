;;; init-lsp.el --- LSP via eglot -*- lexical-binding: t -*-

;; eglot is built-in since Emacs 29.
;;
;; Required language servers:
;;   C/C++:       clangd  (pacman -S clang)
;;   JS/TS/React: typescript-language-server  (npm i -g typescript-language-server typescript)
;;   CMake:       cmake-language-server       (yay -S cmake-language-server)

(use-package eglot
  :ensure nil
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-size 0)
  ;; Disable on-type formatting — it reshapes code mid-edit without being asked.
  (eglot-ignored-server-capabilities '(:documentOnTypeFormattingProvider))
  :config
  ;; Inlay hints are distracting — disable them whenever eglot connects.
  ;; Toggle back on per-session with M-x eglot-inlay-hints-mode.
  (add-hook 'eglot-managed-mode-hook (lambda () (eglot-inlay-hints-mode -1)))
  (when (executable-find "clangd")
    (add-hook 'c-mode-hook    #'eglot-ensure)
    (add-hook 'c++-mode-hook  #'eglot-ensure)
    (add-hook 'c-ts-mode-hook   #'eglot-ensure)
    (add-hook 'c++-ts-mode-hook #'eglot-ensure))
  (when (executable-find "typescript-language-server")
    (add-hook 'js-mode-hook             #'eglot-ensure)
    (add-hook 'js-ts-mode-hook          #'eglot-ensure)
    (add-hook 'typescript-ts-mode-hook  #'eglot-ensure)
    (add-hook 'tsx-ts-mode-hook         #'eglot-ensure))
  (when (executable-find "cmake-language-server")
    (add-hook 'cmake-ts-mode-hook #'eglot-ensure)))

;;; Hover docs & signature help in a floating childframe

(use-package eldoc-box
  :ensure t
  :hook (eglot-managed-mode . eldoc-box-hover-at-point-mode)
  :custom
  (eldoc-box-max-pixel-width  600)
  (eldoc-box-max-pixel-height 400)
  (eldoc-box-clear-with-C-g        t)   ; dismiss popup with C-g
  (eldoc-idle-delay                0.3) ; slightly snappier than the 0.5s default
  (eldoc-documentation-strategy   #'eldoc-documentation-compose)) ; show hover + signature together

;;; Add eglot actions to the right-click context menu
(defun my/eglot-context-menu (menu _click)
  "Append eglot actions to the context menu when eglot is active."
  (when (bound-and-true-p eglot--managed-mode)
    (define-key-after menu [eglot-sep] menu-bar-separator)
    (define-key-after menu [eglot-rename]
      '(menu-item "Rename Symbol" eglot-rename))
    (define-key-after menu [eglot-code-actions]
      '(menu-item "Code Actions" eglot-code-actions))
    (define-key-after menu [eglot-find-refs]
      '(menu-item "Find References" xref-find-references))
    (define-key-after menu [eglot-go-def]
      '(menu-item "Go to Definition" xref-find-definitions)))
  menu)

(add-hook 'context-menu-functions #'my/eglot-context-menu)

(provide 'init-lsp)
;;; init-lsp.el ends here
