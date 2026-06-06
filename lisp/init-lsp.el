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
  (defun my/eglot-ensure-local ()
    "Start eglot only for local files; use M-x eglot manually on remote."
    (unless (file-remote-p default-directory)
      (eglot-ensure)))
  (when (executable-find "clangd")
    (add-hook 'c-mode-hook    #'my/eglot-ensure-local)
    (add-hook 'c++-mode-hook  #'my/eglot-ensure-local)
    (add-hook 'c-ts-mode-hook   #'my/eglot-ensure-local)
    (add-hook 'c++-ts-mode-hook #'my/eglot-ensure-local))
  (when (executable-find "typescript-language-server")
    (add-hook 'js-mode-hook             #'my/eglot-ensure-local)
    (add-hook 'js-ts-mode-hook          #'my/eglot-ensure-local)
    (add-hook 'typescript-ts-mode-hook  #'my/eglot-ensure-local)
    (add-hook 'tsx-ts-mode-hook         #'my/eglot-ensure-local))
  (when (executable-find "cmake-language-server")
    (add-hook 'cmake-ts-mode-hook #'my/eglot-ensure-local)))

;;; Hover docs & signature help in a floating childframe

(use-package eldoc-box
  :ensure t
  :hook (eglot-managed-mode . eldoc-box-mouse-mode)
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

;;; Tags-based navigation via citre (universal-ctags)
;;
;; Complements eglot for large codebases (e.g. the Linux kernel) where
;; clangd struggles without a complete compile_commands.json.
;;
;; First-time setup for a project:
;;   M-x citre-create-tags-file    — walk the tree and build a tags file
;;   M-x citre-update-this-tags-file — refresh after large changes
;;
;; citre-config auto-enables citre-mode whenever a tags file is detected,
;; so no manual setup is needed on subsequent visits.
;;
;; For the Linux kernel, generate compile_commands.json first so clangd
;; can also help, then let citre handle cross-file symbol lookup:
;;   python3 scripts/clang-tools/gen_compile_commands.py

(use-package citre
  :ensure t
  :defer t
  :init
  ;; Auto-enable citre-mode in any buffer that can find a tags file.
  (require 'citre-config)
  ;; citre-config's find-file-hook calls locate-dominating-file which on remote
  ;; paths makes many TRAMP round-trips climbing the directory tree. Skip it.
  (advice-add 'citre-auto-enable-citre-mode :before-while
              (lambda () (not (file-remote-p default-directory))))
  :custom
  (citre-default-create-tags-file-location 'project-root)
  (citre-use-project-root-when-creating-tags t)
  ;; Ask which languages to index when creating a tags file.
  (citre-prompt-language-for-ctags-command t)
  :bind (:map citre-mode-map
              ("C-c c j" . citre-jump)           ; go to definition (tags)
              ("C-c c k" . citre-jump-back)      ; jump back
              ("C-c c p" . citre-peek)           ; peek definition in childframe
              ("C-c c u" . citre-update-this-tags-file))
  :config
  ;; When eglot is active, append citre as an xref fallback so
  ;; M-. still works for symbols the language server can't resolve.
  (with-eval-after-load 'eglot
    (add-hook 'eglot-managed-mode-hook
              (lambda ()
                (add-hook 'xref-backend-functions
                          #'citre-xref-backend 90 :local)))))

(provide 'init-lsp)
;;; init-lsp.el ends here
