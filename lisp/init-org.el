;;; init-org.el --- Org mode for notes and tasks -*- lexical-binding: t -*-

;;; Directory layout
;;
;;   ~/org/
;;     notes.org   — scratch notes, links, reference material
;;     tasks.org   — TODOs tracked by the agenda
;;     journal.org — daily work log (date-tree, auto-structured by org-capture)

;;; Core

(use-package org
  :ensure nil   ; built-in
  :custom
  (org-directory "~/org")
  (org-default-notes-file (expand-file-name "notes.org" org-directory))
  ;; Scan every .org file in ~/org for the agenda
  (org-agenda-files (list (expand-file-name org-directory)))
  ;; Appearance
  (org-hide-leading-stars t)        ; show only the last star on a heading
  (org-startup-indented t)          ; indent body text under its heading
  (org-startup-folded 'content)     ; show headings but collapse body on open
  (org-ellipsis " ▾")              ; indicator for folded content
  ;; TODO workflow
  (org-todo-keywords
   '((sequence "TODO(t)" "IN-PROGRESS(i)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))
  (org-log-done 'time)              ; timestamp when a task is marked DONE
  (org-log-into-drawer t)           ; keep log entries in a :LOGBOOK: drawer
  ;; Usability
  (org-return-follows-link t)       ; RET opens a link under the cursor
  :hook
  (org-mode . visual-line-mode)     ; soft-wrap long lines
  :bind
  (("C-c a" . org-agenda)           ; open the agenda
   ("C-c c" . org-capture)          ; quick-capture a note or task
   ("C-c l" . org-store-link))      ; store a link to the current location
  :config
  ;; Capture templates:
  ;;   n — quick note, lands in the Inbox heading of notes.org
  ;;   t — new TODO task in tasks.org
  ;;   j — journal entry under today's date in journal.org
  (setq org-capture-templates
        '(("n" "Note" entry
           (file+headline "~/org/notes.org" "Inbox")
           "* %?\n%U\n"
           :empty-lines 1)
          ("t" "Task" entry
           (file+headline "~/org/tasks.org" "Tasks")
           "* TODO %?\n%U\n"
           :empty-lines 1)
          ("j" "Journal" entry
           (file+datetree "~/org/journal.org")
           "* %?\n%U\n"
           :empty-lines 1))))

;;; Modern visual style
;;
;; Replaces leading stars, checkbox markers, and TODO keyword boxes with
;; cleaner Unicode equivalents.  Table styling is left off — it can
;; cause alignment issues with some fonts.

(use-package org-modern
  :ensure t
  :hook (org-mode . org-modern-mode)
  :custom
  (org-modern-table nil))

;;; Reveal markup on demand
;;
;; Hides bold/italic markers (*word*, /word/) and link brackets when the
;; cursor is elsewhere; reveals them when you move onto the text so you
;; can edit the raw syntax.

(use-package org-appear
  :ensure t
  :hook (org-mode . org-appear-mode)
  :custom
  (org-appear-autolinks t))   ; also toggle [[link]] bracket visibility

(provide 'init-org)
;;; init-org.el ends here
