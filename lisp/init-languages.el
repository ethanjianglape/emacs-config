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
  (setq treesit-auto-langs '(c cpp cmake go javascript typescript tsx yaml))
  ;; global-treesit-auto-mode remaps classic modes to ts-modes only when the
  ;; grammar is actually available, falling back gracefully otherwise.
  (global-treesit-auto-mode))

;; TypeScript and TSX have no classic built-in Emacs mode.
;; Use ts-modes when the grammar is present; fall back to js-mode otherwise.
(if (treesit-language-available-p 'typescript)
    (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . js-mode)))
(if (treesit-language-available-p 'tsx)
    (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . js-mode)))

;; CMake — only map to ts-mode when the grammar is available.
;; Falls through to fundamental-mode otherwise, which is safe.
(when (treesit-language-available-p 'cmake)
  (add-to-list 'auto-mode-alist '("CMakeLists\\.txt\\'" . cmake-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.cmake\\'"         . cmake-ts-mode)))

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
(add-hook 'c++-mode-hook #'my/set-c-indent)
;; (add-hook 'c++-ts-mode-hook #'flyspell-prog-mode)
;; (add-hook 'c++-mode-hook #'flyspell-prog-mode)

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

(use-package clang-format
  :ensure t)

(defun clang-format--indent-line (&rest _)
  "Indent current line using clang-format, if not on a blank line.

Returns nil on blank lines. Discards replacements which
affect text beyond the end of the line."
  (when (save-excursion
          (beginning-of-line)
          (not (looking-at-p "[ \t]*$")))
    (prog1 t
      ;; Remove trailing whitespace
      (save-excursion
        (end-of-line)
        (delete-char (- (skip-chars-backward " \t"))))
      ;; Discard replacements which affect text beyond end of line
      (let* ((next-char (clang-format--bufferpos-to-filepos
                         (save-excursion
                           (end-of-line)
                           (skip-chars-forward " \t\r\n")
                           (point))
                         'exact 'utf-8-unix))
             (advice `(lambda (offset length &rest _)
                        (< (+ offset length) ,next-char))))
        (advice-add #'clang-format--replace :before-while advice)
        (unwind-protect
            (let ((inhibit-message t))
              (clang-format-region (line-beginning-position)
                                   (line-end-position)))
          (advice-remove #'clang-format--replace advice)))
      (when (< (current-column) (current-indentation))
        (back-to-indentation)))))

;;;###autoload
(define-minor-mode clang-format-indent-mode
  "Use clang-format to control indentation on contentful lines.

Clang format indent mode is a buffer-local minor mode. When
enabled, indentation for lines that do not solely consist of
whitespace will be determined by running the buffer through the
`clang-format-executable' program. On empty lines, the existing
indentation function will be used."
  :global nil :group 'tools
  (if clang-format-indent-mode
      (advice-add indent-line-function :before-until
                  #'clang-format--indent-line)
    (advice-remove indent-line-function #'clang-format--indent-line)))

(add-hook 'c++-mode-hook #'clang-format-indent-mode)
(add-hook 'c++-ts-mode-hook #'clang-format-indent-mode)

;;; doxygen

(use-package highlight-doxygen
  :ensure t
  :config
  (highlight-doxygen-global-mode +1))

(use-package doxymacs
  :ensure t
  :hook (c++-ts-mode-hook . doxymacs-mode))

;;; YAML (.yaml, .yml, .bst BuildStream elements)

(use-package yaml-mode
  :ensure t)

(if (treesit-language-available-p 'yaml)
    (progn
      (add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-ts-mode))
      (add-to-list 'auto-mode-alist '("\\.yml\\'"  . yaml-ts-mode))
      (add-to-list 'auto-mode-alist '("\\.bst\\'"  . yaml-ts-mode)))
  (add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode))
  (add-to-list 'auto-mode-alist '("\\.yml\\'"  . yaml-mode))
  (add-to-list 'auto-mode-alist '("\\.bst\\'"  . yaml-mode)))

;;; Go

(when (treesit-language-available-p 'go)
  (add-to-list 'auto-mode-alist '("\\.go\\'" . go-ts-mode)))

(add-hook 'go-ts-mode-hook
          (lambda ()
            (setq-local tab-width 4)
            (setq-local go-ts-mode-indent-offset 4)))

(with-eval-after-load 'apheleia
  (setf (alist-get 'go-ts-mode apheleia-mode-alist) 'gofmt))

;;; Bazel
;;
;; Covers BUILD/WORKSPACE files, .bzl Starlark files, and .bazelrc.
;; Formatting requires buildifier: https://github.com/bazelbuild/buildtools

(use-package bazel
  :ensure t
  :mode (("BUILD\\'"           . bazel-mode)
         ("BUILD\\.bazel\\'"   . bazel-mode)
         ("WORKSPACE\\'"       . bazel-mode)
         ("WORKSPACE\\.bazel\\'" . bazel-mode)
         ("\\.bzl\\'"          . bazel-starlark-mode)
         ("\\.bazelrc\\'"      . bazelrc-mode))
  :config
  (with-eval-after-load 'apheleia
    (when (executable-find "buildifier")
      (setf (alist-get 'buildifier apheleia-formatters) '("buildifier" "-"))
      (setf (alist-get 'bazel-mode apheleia-mode-alist) 'buildifier)
      (setf (alist-get 'bazel-starlark-mode apheleia-mode-alist) 'buildifier))))

;;; Markdown

(use-package markdown-mode
  :ensure t
  :mode (("\\.md\\'"       . gfm-mode)
         ("\\.markdown\\'" . markdown-mode))
  :custom
  (markdown-fontify-code-blocks-natively t))

;;; systemd
(use-package systemd
  :ensure t)

;;; Assembly
;;
;; nasm-mode gives better x86 Intel-syntax highlighting than the built-in asm-mode.

(use-package nasm-mode
  :ensure t
  :mode ("\\.asm\\'" "\\.nasm\\'" "\\.s\\'"))

(provide 'init-languages)
;;; init-languages.el ends here
