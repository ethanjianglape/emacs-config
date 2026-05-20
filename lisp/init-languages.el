;;; init-languages.el --- Tree-sitter & language modes -*- lexical-binding: t -*-

;;; Tree-sitter compatibility fix
;;
;; Emacs 30.2 built-in queries use predicate string syntax rejected by
;; tree-sitter 0.25+.  Catch query errors per-rule so broken queries are
;; silently skipped while all other font-lock rules still apply.

(advice-add 'treesit--font-lock-fontify-region-1 :around
            (lambda (fn &rest args)
              (condition-case err
                  (apply fn args)
                (treesit-query-error
                 (message "treesit-query-error in %s: %s" major-mode (cadr err))))))

;;; Tree-sitter grammar management

(use-package treesit-auto
  :ensure t
  :config
  (setq treesit-auto-install t)
  (setq treesit-auto-langs '(c cpp cmake javascript typescript tsx)))

;;; Mode remapping

(dolist (mapping '((c-mode   . c-ts-mode)
                   (c++-mode . c++-ts-mode)
                   (js-mode  . js-ts-mode)))
  (add-to-list 'major-mode-remap-alist mapping))

;; TypeScript and TSX have no classic Emacs mode, so add directly.
(add-to-list 'auto-mode-alist '("\\.ts\\'"  . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))

;; CMake
(add-to-list 'auto-mode-alist '("CMakeLists\\.txt\\'" . cmake-ts-mode))
(add-to-list 'auto-mode-alist '("\\.cmake\\'"         . cmake-ts-mode))

;;; C/C++ indentation

(defun my/clang-format-indent-width ()
  "Return IndentWidth from the nearest .clang-format file, or nil."
  (when-let* ((dir (and buffer-file-name
                        (locate-dominating-file buffer-file-name ".clang-format")))
              (file (expand-file-name ".clang-format" dir)))
    (with-temp-buffer
      (insert-file-contents file)
      (when (re-search-forward "^IndentWidth:\\s-*\\([0-9]+\\)" nil t)
        (string-to-number (match-string 1))))))

(defun my/set-c-indent ()
  "Use .clang-format IndentWidth if found, otherwise default to 4."
  (let ((width (or (my/clang-format-indent-width) 4)))
    (setq-local c-basic-offset width)           ; classic c-mode
    (setq-local c-ts-mode-indent-offset width))) ; tree-sitter c/c++ mode

(add-hook 'c-ts-mode-hook   #'my/set-c-indent)
(add-hook 'c++-ts-mode-hook #'my/set-c-indent)

;;; C/C++ comment fontification fallback
;;
;; Emacs 30.2's built-in comment query references node types that don't exist
;; in tree-sitter-cpp 0.25+, causing a treesit-query-error that silently drops
;; the entire comment feature.  Add a simple (comment)-only rule as a fallback.

(defun my/c-ts-fix-comment-face ()
  "Register a simple comment font-lock rule that works with tree-sitter 0.25+."
  (let* ((lang (if (derived-mode-p 'c++-ts-mode) 'cpp 'c))
         (rules (treesit-font-lock-rules
                 :language lang
                 :feature 'comment-simple
                 :override t
                 "(comment) @font-lock-comment-face")))
    ;; Add the feature at level 1 so it is always enabled.
    (when treesit-font-lock-feature-list
      (setcar treesit-font-lock-feature-list
              (cons 'comment-simple (car treesit-font-lock-feature-list))))
    (setq-local treesit-font-lock-settings
                (append treesit-font-lock-settings rules))
    (font-lock-flush)))

(add-hook 'c-ts-mode-hook   #'my/c-ts-fix-comment-face)
(add-hook 'c++-ts-mode-hook #'my/c-ts-fix-comment-face)

;;; Assembly
;;
;; nasm-mode gives better x86 Intel-syntax highlighting than the built-in asm-mode.

(use-package nasm-mode
  :ensure t
  :mode ("\\.asm\\'" "\\.nasm\\'" "\\.s\\'"))

(provide 'init-languages)
;;; init-languages.el ends here
