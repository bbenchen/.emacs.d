;;; init-completion.el --- Initialize completion configurations. -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023 Ben Chen
;; Author: Ben Chen <517926804@qq.com>
;; Homepage: https://github.com/bbenchen/.emacs.d
;;
;;  ___     c  c  wWw \\\    ///          c  c  oo_
;; (___)__  (OO)  (O)_((O)  (O))   /)     (OO) /  _)-<
;; (O)(O) ,'.--.) / __)| \  / |  (o)(O) ,'.--.)\__ `.
;; /  _\ / //_|_\/ (   ||\\//||   //\\ / //_|_\   `. |
;; | |_))| \___ (  _)  || \/ ||  |(__)|| \___     _| |
;; | |_))'.    ) \ \_  ||    ||  /,-. |'.    ) ,-'   |
;; (.'-'   `-.'   \__)(_/    \_)-'   ''  `-.' (_..--'
;;
;;; Commentary:
;;
;;  Initialize completion configurations.
;;
;;; Code:

;; Optionally use the `orderless' completion style.
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion))))
  (orderless-component-separator #'orderless-escapable-split-on-space))

;; Support Pinyin
(use-package pinyinlib
  :after orderless
  :autoload pinyinlib-build-regexp-string
  :init
  (defun completion--regex-pinyin (str)
    (orderless-regexp (pinyinlib-build-regexp-string str)))
  (add-to-list 'orderless-matching-styles 'completion--regex-pinyin))

(use-package vertico
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  :hook ((after-init . vertico-mode)
         (rfn-eshadow-update-overlay . vertico-directory-tidy)))

(use-package vertico-posframe
  :hook (vertico-mode . vertico-posframe-mode)
  :init (setq vertico-posframe-poshandler
              #'posframe-poshandler-frame-center
              vertico-posframe-parameters
              '((left-fringe  . 8)
                (right-fringe . 8))))

(use-package nerd-icons-completion
  :hook (vertico-mode . nerd-icons-completion-mode))

(use-package marginalia
  :hook (after-init . marginalia-mode))

(use-package consult
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h"   . consult-history)
         ("C-c k"   . consult-kmacro)
         ("C-c m"   . consult-man)
         ("C-c i"   . consult-info)
         ("C-c r"   . consult-ripgrep)

         ([remap Info-search]        . consult-info)
         ([remap imenu]              . consult-imenu)
         ([remap isearch-forward]    . consult-line)
         ([remap recentf-open-files] . consult-recent-file)


         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b"   . consult-buffer)              ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#"   . consult-register-load)
         ("M-'"   . consult-register-store)        ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e"   . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch

         ;; Minibuffer history
         :map minibuffer-local-map
         ("C-s" . (lambda ()
                    "Insert the currunt symbol."
                    (interactive)
                    (insert (save-excursion
                              (set-buffer (window-buffer (minibuffer-selected-window)))
                              (or (thing-at-point 'symbol t) "")))))
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init
  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (with-eval-after-load 'xref
    (setq xref-show-xrefs-function #'consult-xref
          xref-show-definitions-function #'consult-xref))

  :config
  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-goto-line
   consult-theme :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help))

(use-package embark
  :bind (("s-." . embark-act)
         ("C-s-." . embark-act)
         ("M-." . embark-dwim)
         ("M-s-." . xref-find-definitions)
         ([remap describe-bindings] . embark-bindings))
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none))))
  :config
  (with-eval-after-load 'which-key
    (defun embark-which-key-indicator ()
      "An embark indicator that displays keymaps using which-key.
The which-key help message will show the type and value of the
current target followed by an ellipsis if there are further
targets."
      (lambda (&optional keymap targets prefix)
        (if (null keymap)
            (which-key--hide-popup-ignore-command)
          (which-key--show-keymap
           (if (eq (plist-get (car targets) :type) 'embark-become)
               "Become"
             (format "Act on %s '%s'%s"
                     (plist-get (car targets) :type)
                     (embark--truncate-target (plist-get (car targets) :target))
                     (if (cdr targets) "…" "")))
           (if prefix
               (pcase (lookup-key keymap prefix 'accept-default)
                 ((and (pred keymapp) km) km)
                 (_ (key-binding prefix 'accept-default)))
             keymap)
           nil nil t (lambda (binding)
                       (not (string-suffix-p "-argument" (cdr binding))))))))

    (setq embark-indicators
          '(embark-which-key-indicator
            embark-highlight-indicator
            embark-isearch-highlight-indicator))

    (defun embark-hide-which-key-indicator (fn &rest args)
      "Hide the which-key indicator immediately when using the completing-read prompter."
      (which-key--hide-popup-ignore-command)
      (let ((embark-indicators
             (remq #'embark-which-key-indicator embark-indicators)))
        (apply fn args)))

    (advice-add #'embark-completing-read-prompter
                :around #'embark-hide-which-key-indicator)))

(use-package embark-consult
  :bind (:map minibuffer-mode-map
              ("C-c C-o" . embark-export))
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(provide 'init-completion)
;;; init-completion.el ends here
