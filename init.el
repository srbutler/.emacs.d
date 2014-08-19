;;; init --- Andrew Schwartzmeyer's Emacs init file

;;; Commentary:
;;; Fully customized Emacs configurations

;;; Code:

(require 'cask "~/.cask/cask.el")
(cask-initialize)

(require 'use-package)

;;; shortcuts
;; miscellaneous
(bind-key "M-/" 'hippie-expand)
(bind-key "C-c a" 'org-agenda)
(bind-key "C-c l" 'align-regexp)
(bind-key "C-c x" 'eval-buffer)
;; isearch
(bind-key "C-s" 'isearch-forward-regexp)
(bind-key "C-r" 'isearch-backward-regexp)
(bind-key "C-M-s" 'isearch-forward)
(bind-key "C-M-r" 'isearch-backward)
;; window management
(bind-key* "M-3" 'delete-other-windows)
(bind-key* "M-4" 'split-window-horizontally)
(bind-key* "M-5" 'split-window-vertically)
(bind-key* "M-2" 'delete-window)
(bind-key* "M-s" 'other-window)
;; projectile command map
(bind-key* "M-[" 'projectile-command-map)

;;; appearance
;; theme (wombat in terminal, solarized otherwise)
(if (display-graphic-p)
    (use-package solarized
      :init
      (progn
	(setq solarized-use-variable-pitch nil
	      solarized-high-contrast-mode-line t)
	(load-theme 'solarized-dark t)))
  (load-theme 'wombat t))
;; line/column numbers in mode-line
(line-number-mode)
(column-number-mode)
;; y/n for yes/no
(defalias 'yes-or-no-p 'y-or-n-p)
;; quit prompt
(setq confirm-kill-emacs 'yes-or-no-p)
;; start week on Monday
(setq calendar-week-start-day 1)
;; cursor settings
(blink-cursor-mode)
;; visually wrap lines
(setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))
;; default truncate lines
(setq-default truncate-lines t)
;; matching parentheses
(show-paren-mode)
;; window undo/redo
(winner-mode)
;; show function in modeline
(which-function-mode)

;;; settings
;; enable all commands
(setq disabled-command-function nil)
;; kill whole line (including newline)
(setq kill-whole-line t)
;; initial text mode
(setq initial-major-mode 'text-mode)
;; enable auto-fill mode for text
(add-hook 'text-mode-hook 'turn-on-auto-fill)
;; disable auto-fill because of stupid GitHub flavored markdown
(remove-hook 'git-commit-mode-hook 'turn-on-auto-fill)
(add-hook 'git-commit-mode-hook
	  'turn-off-auto-fill
	  'turn-on-visual-line-mode
	  'truncate-lines)
;; longer commit summaries
(setq git-commit-summary-max-length 72)
;; disable bell
(setq ring-bell-function 'ignore)
;; subword navigation
(subword-mode)
;; increase garbage collection threshold
(setq gc-cons-threshold 20000000)
;; inhibit startup message
(setq inhibit-startup-message t)
;; remove selected region if typing
(pending-delete-mode t)
;; prefer UTF8
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
;; set terminfo
(setq system-uses-terminfo nil)
;; open empty files quietly
(setq confirm-nonexistent-file-or-buffer nil)
;; fix tramp
(eval-after-load 'tramp
  '(progn (setenv "TMPDIR" "/tmp")))

;;; files
;; backups
(setq backup-by-copying t
      delete-old-versions t
      kept-new-versions 4
      kept-old-versions 2
      version-control t
      vc-make-backup-files t
      backup-directory-alist `(("." . ,(concat
					user-emacs-directory "backups"))))
;; final-newline
(setq require-final-newline 't)
;; set auto revert of buffers if file is changed externally
(global-auto-revert-mode)
;; symlink version-control follow
(setq vc-follow-symlinks t)
;; add more modes
(add-to-list 'auto-mode-alist '("\\.ino\\'" . c-mode))
(add-to-list 'auto-mode-alist '("\\.vcsh\\'" . conf-mode))
(add-to-list 'magic-mode-alist '(";;; " . emacs-lisp-mode))
;; dired
(setq
 ;; enable side-by-side dired buffer targets
 dired-dwim-target t
 ;; better recursion in dired
 dired-recursive-copies 'always
 dired-recursive-deletes 'top)

;;; functions
;; load local file
(defun load-local (file)
  "Load FILE from ~/.emacs.d, okay if missing."
  (load (f-expand file user-emacs-directory) t))
;; select whole line
(defun select-whole-line ()
  "Select whole line which has the cursor."
  (interactive)
  (end-of-line)
  (set-mark (line-beginning-position)))
(bind-key "C-c w" 'select-whole-line)
;; comment/uncomment line/region
(defun comment-or-uncomment-region-or-line ()
  "Comments or uncomments the region or the current line if there's no active region."
  (interactive)
  (let (beg end)
    (if (region-active-p)
	(setq beg (region-beginning) end (region-end))
      (setq beg (line-beginning-position) end (line-end-position)))
    (comment-or-uncomment-region beg end)))
(bind-key "C-c c" 'comment-or-uncomment-region-or-line)

;;; load local settings
(mapc 'load-local '("feeds" "private"))

;;; load OS X configurations
(when (eq system-type 'darwin)
  (load-local "osx"))

;;; packages
;; ace-jump-mode
(use-package ace-jump-mode
  :config (eval-after-load "ace-jump-mode" '(ace-jump-mode-enable-mark-sync))
  :bind (("C-." . ace-jump-mode)
   	 ("C-," . ace-jump-mode-pop-mark)))
;; browse-kill-ring
(use-package browse-kill-ring
  :config (browse-kill-ring-default-keybindings)
  :bind ("C-c k" . browse-kill-ring))
;; company "complete anything"
(use-package company
  :init (add-hook 'after-init-hook 'global-company-mode))
;; ein
(use-package ein
  :config (setq ein:use-auto-complete t))
;; elfeed
(use-package elfeed
  :config (progn (add-hook 'elfeed-new-entry-hook
			   (elfeed-make-tagger :before "2 weeks ago"
					       :remove 'unread)))
  :bind ("C-x w" . elfeed))
;; erc --- configured with help from:
;; http://emacs-fu.blogspot.com/2009/06/erc-emacs-irc-client.html
(use-package erc
  :init (add-hook 'erc-mode-hook (lambda () (subword-mode 0)))
  :config
  (progn
    (use-package erc-services
      :init (erc-services-mode))
    (use-package erc-notify
      :init (erc-notify-mode)
    (erc-spelling-mode) ;; flyspell
    (erc-track-mode)
    (setq erc-track-exclude-types '("JOIN" "NICK" "PART" "QUIT" "MODE"
				    "324" "329" "332" "333" "353" "477")
	  ;; don't show any of this
	  erc-hide-list '("JOIN" "PART" "QUIT" "NICK"))
    ;; channel autojoin
    (erc-autojoin-mode)
    (setq erc-autojoin-timing 'ident))))
;; activate expand-region
(use-package expand-region
  :bind ("C-=" . er/expand-region))
;; flx-ido
(use-package flx-ido
  :init
  (progn
    (flx-ido-mode)
    (setq ido-use-faces nil)))
;; flycheck
(use-package flycheck
  :init
  (progn
    (add-hook 'after-init-hook #'global-flycheck-mode)
    (setq flycheck-completion-system 'ido)))
;;; flyspell
(use-package flyspell
  :config (setq ispell-program-name "aspell" ; use aspell instead of ispell
		ispell-extra-args '("--sug-mode=ultra")))
;; ibuffer
(use-package ibuffer
  :config (add-hook 'ibuffer-mode-hook (lambda () (setq truncate-lines t)))
  :bind ("C-x C-b" . ibuffer))
;; ido setup
(use-package ido
  :init (ido-mode))
(use-package ido-ubiquitous)
;; ido-vertical
(use-package ido-vertical-mode
  :init (ido-vertical-mode))
;; multiple-cursors
(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
	 ("C->" . mc/mark-next-like-this)
	 ("C-<" . mc/mark-previous-like-this)
	 ("C-c C-<" . mc/mark-all-like-this)))
;; multi-term
(use-package multi-term
  :config (setq multi-term-program "bash"))
;;; org-mode

;; org-auto-fill
(add-hook 'org-mode-hook 'turn-on-auto-fill)
;; org-agenda
(setq org-agenda-files '("~/.org")
      ;; org-entities
      org-pretty-entities t
      org-entities-user '(("join" "\\Join" nil "&#9285;" "" "" "⋈")
			  ("reals" "\\mathbb{R}" t "&#8477;" "" "" "ℝ")
			  ("ints" "\\mathbb{Z}" t "&#8484;" "" "" "ℤ")
			  ("complex" "\\mathbb{C}" t "&#2102;" "" "" "ℂ")
			  ("models" "\\models" nil "&#8872;" "" "" "⊧"))
      ;; org-export
      org-export-backends '(html beamer ascii latex md))
;; org-babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (gnuplot . t)
   (C . t)
   (emacs-lisp . t)
   (haskell . t)
   (latex . t)
   (ledger . t)
   (python . t)
   (ruby . t)
   (sh . t)))
;; popwin
(use-package popwin
  :init
  (progn
    (popwin-mode)
    ;; cannot use :bind for keymap
    (global-set-key (kbd "C-z") popwin:keymap)))
;; activate projectile
(use-package projectile
  :config (progn
	    (projectile-global-mode)
	    (setq projectile-remember-window-configs t)))
;;; save kill ring
(use-package savekill)
;;; saveplace
(use-package saveplace
  :init
  (progn
    (setq-default save-place t
		  save-place-file (concat user-emacs-directory "saved-places"))))
;; scratch
(use-package scratch
  :bind ("C-c s" . scratch))
;; slime
(use-package slime-autoloads
  :config (setq
	   inferior-lisp-program (executable-find "sbcl")
	   slime-contribs '(slime-fancy)))
;; activate smartparens
(use-package smartparens
  :init (progn (smartparens-global-mode)
	       (show-smartparens-global-mode)
	       (use-package smartparens-config)))
;; setup smex bindings
(use-package smex
  :init
  (progn
    (setq smex-save-file (expand-file-name ".smex-items" "~/.emacs.d/"))
    (smex-initialize))
  :bind (("M-x" . smex)
	 ("M-X" . smex-major-mode-commands)
	 ("C-c C-c M-x" . execute-extended-command)))
;; scrolling
(use-package smooth-scroll
  :init
  (progn
    (smooth-scroll-mode)
    (setq smooth-scroll/vscroll-step-size 8)))
;; undo-tree
(use-package undo-tree
  :init (global-undo-tree-mode))
;;; uniquify
(use-package uniquify
  :config (setq uniquify-buffer-name-style 'forward))
;; setup virtualenvwrapper
(use-package virtualenvwrapper
  :config (setq venv-location "~/.virtualenvs/"))
;;; whitespace
(use-package whitespace
  :init (add-hook 'before-save-hook 'whitespace-cleanup)
  :config
  (progn
    (setq whitespace-line-column 80 ;; limit line length
	  whitespace-style '(face tabs empty trailing lines-tail))))
;;; yasnippet
(use-package yasnippet
  :init (yas-global-mode))

;;; start server
(server-start)

;;; provide init package
(provide 'init)

;;; init.el ends here
