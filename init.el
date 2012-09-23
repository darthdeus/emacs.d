(add-to-list 'load-path (expand-file-name "~/.emacs.d"))

(require 'init-packages)
(require 'init-jumps)
(require 'init-ruby)
(require 'init-javascript)

(delete-selection-mode 1)

;; disable visual bell
(setq ring-bell-function (lambda () (message "*beep*")))

(defun turn-on-paredit () (paredit-mode 1))
(add-hook 'clojure-mode-hook 'turn-on-paredit)

(setq inferior-lisp-program "/usr/local/bin/clisp")
(require 'rainbow-delimiters)

(remove-hook 'text-mode-hook 'turn-on-flyspell)
(remove-hook 'text-mode-hook 'turn-on-auto-fill)

(global-set-key (kbd "M-X") 'smex-major-mode-commands)

(global-unset-key (kbd "M-@"))
(global-set-key (kbd "M-@") 'er/expand-region)
(global-set-key (kbd "M-#") 'er/contract-region)

;;;; mark-multiple.el
;;;; taken from https://github.com/magnars/mark-multiple.el
(require 'inline-string-rectangle)
(global-set-key (kbd "C-x r t") 'inline-string-rectangle)

(require 'mark-more-like-this)
(global-set-key (kbd "C-<") 'mark-previous-like-this)
(global-set-key (kbd "C->") 'mark-next-like-this)
; like the other two, but takes an argument (negative is previous)
(global-set-key (kbd "C-M-m") 'mark-more-like-this)
(global-set-key (kbd "C-*") 'mark-all-like-this)

(require 'rename-sgml-tag)
(add-hook 'html-mode-hook
          (lambda () (define-key html-mode-map (kbd "C-c C-r") 'rename-sgml-tag)))

(global-set-key (kbd "C-c C-<return>") 'delete-trailing-whitespace)

;; TODO - install this?
;; (require 'js2-rename-var)
;; (define-key js2-mode-map (kbd "C-c C-r") 'js2-rename-var)

(add-to-list 'load-path "~/.emacs.d/vendor/vim-mode")
(require 'vim)
(vim-mode 0)

;;;; PeepOpen
(require 'textmate)
(add-to-list 'load-path "~/.emacs.d/vendor/")
(require 'peepopen)
(textmate-mode)

;; add newline if at the end of file
(setq next-line-add-newlines t)

;; show the menu bar
(menu-bar-mode)

(require 'stylus-mode)

;; For Emacs 23 or Aquamacs, use this to open files in the existing frame:
(setq ns-pop-up-frames nil)


;;;; SCSS
(add-hook 'scss-mode-hook
          '(lambda ()
             (set (make-local-variable 'tab-width) 2)))

(defun push-mark-no-activate ()
  "Pushes `point' to `mark-ring' and does not activate the region
Equivalent to \\[set-mark-command] when \\[transient-mark-mode] is disabled"
  (interactive)
  (push-mark (point) t nil)
  (message "Pushed mark to ring"))

;; TODO - what about mapping this to F1?0
(global-set-key (kbd "C-`") 'push-mark-no-activate)

;;;; TRAMP mode
(require 'tramp)
;; enable sudo
(set-default 'tramp-default-proxies-alist (quote ((".*" nil  "/ssh:deploy@%h:"))))


;;;; YAML
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(add-hook 'yaml-mode-hook
          '(lambda ()
             (define-key yaml-mode-map "\C-m" 'newline-and-indent)))


(require 'init-yasnippet)


;;(color-theme-tomorrow-night)


;; Strip all trailing whitespace when a file is saved
(add-hook 'file-save-hook
          '(lambda ()
             (delete-trailing-whitespace)))


(require 'sws-mode)
(require 'jade-mode)
(add-to-list 'auto-mode-alist '("\\.styl$" . sws-mode))
(add-to-list 'auto-mode-alist '("\\.jade$" . jade-mode))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector (vector "#4d4d4c" "#c82829" "#718c00" "#eab700" "#4271ae" "#8959a8" "#3e999f" "#ffffff"))
 '(css-indent-offset 2)
 '(custom-enabled-themes (quote (sanityinc-tomorrow-night)))
 '(custom-safe-themes (quote ("628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" "4cf3221feff536e2b3385209e9b9dc4c2e0818a69a1cdb4b522756bcdf4e00a4" "4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328" default)))
 '(exec-path (quote ("/usr/bin" "/bin" "/usr/sbin" "/sbin" "/Applications/Emacs.app/Contents/MacOS/bin" "/usr/local/bin")))
 '(icicle-files-ido-like-flag t)
 '(js-indent-level 2)
 '(js2-always-indent-assigned-expr-in-decls-p t)
 '(js2-auto-indent-p t)
 '(js2-basic-offset 2)
 '(js2-cleanup-whitespace t)
 '(js2-indent-on-enter-key t)
 '(rspec-use-rake-flag nil)
 '(rspec-use-rvm nil)
 '(scss-compile-at-save nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
