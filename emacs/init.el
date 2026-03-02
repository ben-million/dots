
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file :no-error-if-file-is-missing)

(require 'use-package)
(package-initialize)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

(add-to-list 'display-buffer-alist
             '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
               (display-buffer-no-window)
               (allow-no-window . t)))

(use-package delsel
  :ensure nil
  :hook (after-init . delete-selection-mode))

(defun prot/keyboard-quit-dwim ()
  "Do-What-I-Mean behaviour for a general `keyboard-quit'.

The generic `keyboard-quit' does not do the expected thing when
the minibuffer is open.  Whereas we want it to close the
minibuffer, even without explicitly focusing it.

The DWIM behaviour of this command is as follows:

- When the region is active, disable it.
- When a minibuffer is open, but not focused, close the minibuffer.
- When the Completions buffer is selected, close it.
- In every other case use the regular `keyboard-quit'."
  (interactive)
  (cond
   ((region-active-p)
    (keyboard-quit))
   ((derived-mode-p 'completion-list-mode)
    (delete-completion-window))
   ((> (minibuffer-depth) 0)
    (abort-recursive-edit))
   (t
    (keyboard-quit))))

(define-key global-map (kbd "C-g") #'prot/keyboard-quit-dwim)

;;; Tweak the looks of Emacs

;; Those three belong in the early-init.el, but I am putting them here
;; for convenience.  If the early-init.el exists in the same directory
;; as the init.el, then Emacs will read+evaluate it before moving to
;; the init.el.

(use-package magit
  :ensure t
  :custom
  (magit-git-executable "/usr/bin/git")
  :init
  (use-package with-editor :ensure t)

  ;; Have magit-status go full screen and quit to previous
  ;; configuration.  Taken from
  ;; http://whattheemacsd.com/setup-magit.el-01.html#comment-748135498
  ;; and http://irreal.org/blog/?p=2253
  (defadvice magit-status (around magit-fullscreen activate)
    (window-configuration-to-register :magit-fullscreen)
    ad-do-it
    (delete-other-windows))
  (defadvice magit-quit-window (after magit-restore-screen activate)
    (jump-to-register :magit-fullscreen))
  :config
  (remove-hook 'magit-status-sections-hook 'magit-insert-tags-header)
  (remove-hook 'magit-status-sections-hook 'magit-insert-status-headers)
  (remove-hook 'magit-status-sections-hook 'magit-insert-unpushed-to-pushremote)
  (remove-hook 'magit-status-sections-hook 'magit-insert-unpulled-from-pushremote)
  (remove-hook 'magit-status-sections-hook 'magit-insert-unpulled-from-upstream)
  (remove-hook 'magit-status-sections-hook 'magit-insert-unpushed-to-upstream-or-recent))

(use-package spacious-padding)

(use-package vertico
  :ensure t
  :hook (after-init . vertico-mode))

(use-package marginalia
  :ensure t
  :hook (after-init . marginalia-mode))

(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrides nil))

(use-package savehist
  :ensure nil ; it is built-in
  :hook (after-init . savehist-mode))

(use-package corfu
  :ensure t
  :hook (after-init . global-corfu-mode)
  :bind (:map corfu-map ("<tab>" . corfu-complete))
  :config
  (setq tab-always-indent 'complete)
  (setq corfu-preview-current nil)
  (setq corfu-min-width 20)

  (setq corfu-popupinfo-delay '(1.25 . 0.5))
  (corfu-popupinfo-mode 1) ; shows documentation after `corfu-popupinfo-delay'

  ;; Sort by input history (no need to modify `corfu-sort-function').
  (with-eval-after-load 'savehist
    (corfu-history-mode 1)
    (add-to-list 'savehist-additional-variables 'corfu-history)))

(use-package dired
  :ensure nil
  :commands (dired)
  :hook
  ((dired-mode . dired-hide-details-mode)
   (dired-mode . hl-line-mode))
  :config
  (setq dired-recursive-copies 'always)
  (setq dired-recursive-deletes 'always)
  (setq delete-by-moving-to-trash t)
  (setq dired-dwim-target t))

(use-package dired-subtree
  :ensure t
  :after dired
  :bind
  ( :map dired-mode-map
    ("<tab>" . dired-subtree-toggle)
    ("TAB" . dired-subtree-toggle)
    ("<backtab>" . dired-subtree-remove)
    ("S-TAB" . dired-subtree-remove))
  :config
  (setq dired-subtree-use-backgrounds nil))


(use-package trashed
  :ensure t
  :commands (trashed)
  :config
  (setq trashed-action-confirmer 'y-or-n-p)
  (setq trashed-use-header-line t)
  (setq trashed-sort-key '("Date deleted" . t))
  (setq trashed-date-format "%Y-%m-%d %H:%M:%S"))

(use-package treesit-auto
  :config
  (global-treesit-auto-mode))

(use-package web-mode
  :ensure t)

(use-package eglot
  :ensure t)

;; Small macOS fixes

(setq mac-command-modifier 'meta)
(setq mac-option-modifier 'meta)

(use-package exec-path-from-shell
  :ensure t)
(exec-path-from-shell-initialize)

(use-package consult
  :ensure t
  :bind
  (("C-s" . consult-line)
   ("C-x b" . consult-buffer)
   ("M-g g" . consult-goto-line)
   ("M-g M-g" . consult-goto-line)
   ("C-x f" . consult-fd)
   ("C-x C-f" . consult-fd)
   ("C-x C-r" . consult-ripgrep)
   ("M-s l" . consult-line)  
   ("M-s m" . consult-mark)
   ("M-s k" . consult-kmacro)
   ("M-y" . consult-yank-pop)) 
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  (setq register-preview-delay 0
	register-preview-function #'consult-register-format)
  (advice-add #'register-preview :override #'consult-register-window))

(setq consult-async-min-input 0)
(setq consult-async-input-debounce 0.001)
(setq consult-async-refresh-delay 0.001)
(setq consult-async-input-throttle 0.001)

(global-set-key (kbd "C-x C-f") 'find-file)

(setq-default line-spacing 6)
(setq-default spacious-padding-subtle-mode-line :true)

(setq treesit-language-source-alist
   '((bash "https://github.com/tree-sitter/tree-sitter-bash")
     (cmake "https://github.com/uyha/tree-sitter-cmake")
     (css "https://github.com/tree-sitter/tree-sitter-css")
     (elisp "https://github.com/Wilfred/tree-sitter-elisp")
     (go "https://github.com/tree-sitter/tree-sitter-go")
     (html "https://github.com/tree-sitter/tree-sitter-html")
     (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
     (json "https://github.com/tree-sitter/tree-sitter-json")
     (make "https://github.com/alemuller/tree-sitter-make")
     (markdown "https://github.com/ikatyang/tree-sitter-markdown")
     (python "https://github.com/tree-sitter/tree-sitter-python")
     (toml "https://github.com/tree-sitter/tree-sitter-toml")
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
     (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

(use-package fontaine)

(setq fontaine-presets
      '((Hack
         :default-family "Hack"
         :default-height 100
         :variable-pitch-family "Hack"
         :line-spacing 1)
	(Titillium
         :default-family "Titillium Web"
         :default-height 100
         :variable-pitch-family "Titillium Web"
         :line-spacing 1)
	(GT
         :default-family "GT Pressura Mono"
         :default-height 100
         :variable-pitch-family "GT Pressura Mono"
         :line-spacing 1)
	(GTStandard
         :default-family "GT Pressura Trial"
         :default-height 100
         :variable-pitch-family "GT Pressura Trial"
         :line-spacing 1)	
	(Univers
         :default-family "Univers LT Pro"
         :default-height 100
         :variable-pitch-family "Univers LT Pro"
         :line-spacing 1)	
	(Modena
         :default-family "EK Modena Mono"
         :default-height 100
         :variable-pitch-family "EK Modena Mono"
         :line-spacing 1)
	(IA
         :default-family "iA Writer Mono V"
         :default-height 100
         :variable-pitch-family "iA Writer Mono V"
         :line-spacing 1)))

(use-package vterm)
(use-package ultra-scroll)

(use-package time-zones)

(vertico-mode)
(vertico-grid-mode)

(use-package doric-themes)
(load-theme 'doric-light)

(spacious-padding-mode)

(setq-default frame-title-format "")
(set-frame-parameter nil 'ns-transparent-titlebar t)
(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))

(ultra-scroll-mode)

(setq mode-line-format
      (append mode-line-format
              '((:eval
                 (propertize " ⌘ "
                             'help-echo "Open M-x"
                             'mouse-face 'mode-line-highlight
                             'local-map (let ((map (make-sparse-keymap)))
                                          (define-key map [mode-line mouse-1]
                                            (lambda () (interactive)
                                              (call-interactively #'execute-extended-command)))
                                          map))))))




;; open -b com.apple.ScreenSaver.Engine
(defun mac-start-screensaver ()
  "Start the macOS screensaver."
  (interactive)
  (shell-command "open -b com.apple.ScreenSaver.Engine"))

(use-package combobulate)
(combobulate-mode)

(setq denote-directory (expand-file-name "~/Documents/notes/"))

(global-unset-key [C-wheel-up])
(global-unset-key [C-wheel-down])

(xterm-mouse-mode)
(require 'page-view)

(use-package dash :ensure t)
(use-package avy :ensure t)
(use-package pcre2el :ensure t)

(use-package hel
  :vc (:url "https://github.com/anuvyklack/hel.git" :rev "main")
  :config (hel-mode))

(hel-keymap-set emacs-lisp-mode-map :state 'normal
  "M" 'helpful-at-point)

(require 'org)

(defvar org-mouse-headline-map (make-sparse-keymap)
  "Keymap for mouse actions on org headlines.")
(org-defkey org-mouse-headline-map [mouse-1] 'org-cycle)

(defvar-local org-mouse-headline--keywords nil
  "Font-lock keywords added by `org-mouse-headline-mode'.")

(define-minor-mode org-mouse-headline-mode
  "Minor mode to enable mouse-1 cycling on org headlines."
  :lighter " OrgMouse"
  (if org-mouse-headline-mode
      (progn
        (setq org-mouse-headline--keywords
              `((,(rx bol (one-or-more "*") (one-or-more space) (group-n 1 (one-or-more any)) eol)
                 (0 '(face nil
                      keymap ,org-mouse-headline-map
                      mouse-face highlight)
                    prepend))))
        (font-lock-add-keywords nil org-mouse-headline--keywords t)
        (font-lock-flush))
    (when org-mouse-headline--keywords
      (font-lock-remove-keywords nil org-mouse-headline--keywords)
      (setq org-mouse-headline--keywords nil)
      (font-lock-flush))))

(add-hook 'org-mode-hook #'org-mouse-headline-mode)

;; ECA buffer tab mode
(defcustom eca-buffer-regexp "<eca-chat:[0-9]+:[0-9]+>"
  "Regexp to match ECA buffer names."
  :type 'regexp
  :group 'eca)

(defvar eca-tab-mode--display-buffer-entry nil
  "The `display-buffer-alist' entry added by `eca-tab-mode'.")

(define-minor-mode eca-tab-mode
  "Minor mode to open ECA buffers in new tabs."
  :global t
  :lighter " EcaTab"
  (if eca-tab-mode
      (progn
        (tab-bar-mode 1)
        (setq eca-tab-mode--display-buffer-entry
              `(,eca-buffer-regexp
                (display-buffer-in-tab)
                (tab-name . "ECA")))
        (add-to-list 'display-buffer-alist eca-tab-mode--display-buffer-entry))
    (setq display-buffer-alist
          (delete eca-tab-mode--display-buffer-entry display-buffer-alist))
    (setq eca-tab-mode--display-buffer-entry nil)))

(defcustom dired-subtree-ignored-regexp-for-expand-all
  (concat "^\\(" (regexp-opt '("node_modules")) "\\|\\..*\\)$")
  "Matching directories will not be expanded in `dired-subtree-expand-all'."
  :type 'regexp
  :group 'dired-subtree)

(defun dired-subtree-expand-all ()
  "Recursively expand all subdirectories.
Skips node_modules and directories starting with `.'"
  (interactive)
  (message "Expanding...")
  (let ((inhibit-redisplay t)
        (inhibit-message t)
        (dired-subtree-after-insert-hook nil))
    (save-excursion
      (goto-char (point-min))
      (while (not (eobp))
        (let ((filename (dired-get-filename nil t)))
          (when (and filename
                     (file-directory-p filename)
                     (not (dired-subtree--is-expanded-p))
                     (not (string-match-p
                           dired-subtree-ignored-regexp-for-expand-all
                           (file-name-nondirectory filename))))
            (save-excursion (dired-subtree-insert))))
        (forward-line 1))))
  (when (fboundp 'dired-insert-set-properties)
    (let ((inhibit-read-only t))
      (dired-insert-set-properties (point-min) (point-max))))
  (message "Done"))

(defun dired-subtree-collapse-all ()
  "Collapse all expanded subtrees."
  (interactive)
  (let ((inhibit-redisplay t)
        (inhibit-message t)
        (dired-subtree-after-remove-hook nil))
    (save-excursion
      (goto-char (point-max))
      (while (not (bobp))
        (when (dired-subtree--is-expanded-p)
          (save-excursion
            (forward-line 1)
            (dired-subtree-remove)))
        (forward-line -1))))
  (message "Collapsed"))

(defun dired-subtree-toggle-all ()
  "Expand all if any collapsed, otherwise collapse all."
  (interactive)
  (if dired-subtree-overlays
      (dired-subtree-collapse-all)
    (dired-subtree-expand-all)))

(with-eval-after-load 'dired-subtree
  (define-key dired-mode-map (kbd "<backtab>") #'dired-subtree-toggle-all))

(setq org-goto-interface 'outline-path-completion)
(setq org-outline-path-complete-in-steps nil)

;;; Uppercase mode - displays all text in uppercase (display only, not actual content)
(defvar uppercase-mode--display-table nil
  "Display table used by `uppercase-mode' to show text in uppercase.")

(defun uppercase-mode--make-display-table ()
  "Create a display table that maps lowercase letters to uppercase."
  (let ((table (make-display-table)))
    (dotimes (i 26)
      (aset table (+ ?a i) (vector (+ ?A i))))
    table))

(defun uppercase-mode--enable ()
  "Enable uppercase display in all buffers."
  (unless uppercase-mode--display-table
    (setq uppercase-mode--display-table (uppercase-mode--make-display-table)))
  (setq-default buffer-display-table uppercase-mode--display-table)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (setq buffer-display-table uppercase-mode--display-table))))

(defun uppercase-mode--disable ()
  "Disable uppercase display in all buffers."
  (setq-default buffer-display-table nil)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (setq buffer-display-table nil))))

(defun uppercase-mode--new-buffer-hook ()
  "Set display table for newly created buffers when `uppercase-mode' is active."
  (when uppercase-mode
    (setq buffer-display-table uppercase-mode--display-table)))

(define-minor-mode uppercase-mode
  "Global minor mode that displays all buffer text in uppercase.
This only affects the display; the actual buffer content remains unchanged."
  :global t
  :lighter " UC"
  (if uppercase-mode
      (progn
        (uppercase-mode--enable)
        (add-hook 'after-change-major-mode-hook #'uppercase-mode--new-buffer-hook))
    (uppercase-mode--disable)
    (remove-hook 'after-change-major-mode-hook #'uppercase-mode--new-buffer-hook)))

(use-package clipetty
  :ensure t)
