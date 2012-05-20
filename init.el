;;;; el-get
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")
(unless (require 'el-get nil t)
  (url-retrieve "https://raw.github.com/dimitri/el-get/master/el-get-install.el"
                (lambda (s)
                  (let (el-get-master-branch)
                    (goto-char (point-max))
                    (eval-print-last-sexp)))))
(el-get 'sync)


(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives
            '("elpa" . "http://tromey.com/elpa/") t)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

(defvar my-packages '(starter-kit starter-kit-lisp starter-kit-bindings)
  "A list of packages to ensure are installed at launch")

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

(defun turn-on-paredit () (paredit-mode 1))
(add-hook 'clojure-mode-hook 'turn-on-paredit)

(setq inferior-lisp-program "/usr/local/bin/clisp")
(require 'rainbow-delimiters)

(setq coffee-command "/usr/local/bin/coffee")

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


;;;; PeepOpen
(require 'textmate)
(add-to-list 'load-path "~/.emacs.d/vendor/")
(require 'peepopen)
(textmate-mode)

;; add newline if at the end of file
(setq next-line-add-newlines t)

;; show the menu bar
(menu-bar-mode)

;;;; Ruby
;; (add-hook 'ruby-mode-hook 'flymake-ruby-load)
(require 'rspec-mode)

;; TODO - why is the default rspec-mode-verifible-keymap instead of
;; rspec-mode-keymap ?
;; https://github.com/pezra/rspec-mode/blob/master/rspec-mode.el#L470
(add-hook 'ruby-mode-hook
          (lambda () (local-set-key rspec-key-command-prefix rspec-mode-keymap))
          'rspec-mode)

;; 1.9 syntax checking
;; (add-to-list 'load-path "~/.emacs.d/el-get/Enhanced-Ruby-Mode")
;; (require 'ruby-mode)

;; ;;;; JavaScript
;; (autoload 'js2-mode "js2-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js3-mode))
(require 'js3-mode)

(require 'stylus-mode)

;; For Emacs 23 or Aquamacs, use this to open files in the existing frame:
(setq ns-pop-up-frames nil)

;;;; CoffeeScript
(defun coffee-custom ()
  "coffee-mode-hook"
  (set (make-local-variable 'tab-width) 2))
(add-hook 'coffee-mode-hook
          '(lambda () (coffee-custom)))


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

(defun jump-to-mark ()
  "Jumps to the local mark, respecting the `mark-ring' order.
This is the same as using \\[set-mark-command] with the prefix argument."
  (interactive)
  (set-mark-command 1))

(global-set-key (kbd "M-`") 'jump-to-mark)

(defun exchange-point-and-mark-no-activate ()
  "Identical to \\[exchange-point-and-mark] but will not activate the region."
  (interactive)
  (exchange-point-and-mark)
  (deactivate-mark nil))

(define-key global-map [remap exchange-point-and-mark] 'exchange-point-and-mark-no-activate)

;; this is useless in GUI mode anyway
(global-set-key (kbd "C-z") nil)

(defun ido-goto-symbol (&optional symbol-list)
   "Refresh imenu and jump to a place in the buffer using Ido."
   (interactive)
   (unless (featurep 'imenu)
     (require 'imenu nil t))
   (cond
    ((not symbol-list)
     (let ((ido-mode ido-mode)
           (ido-enable-flex-matching
            (if (boundp 'ido-enable-flex-matching)
                ido-enable-flex-matching t))
           name-and-pos symbol-names position)
       (unless ido-mode
         (ido-mode 1)
         (setq ido-enable-flex-matching t))
       (while (progn
                (imenu--cleanup)
                (setq imenu--index-alist nil)
                (ido-goto-symbol (imenu--make-index-alist))
                (setq selected-symbol
                      (ido-completing-read "Symbol? " symbol-names))
                (string= (car imenu--rescan-item) selected-symbol)))
       (unless (and (boundp 'mark-active) mark-active)
         (push-mark nil t nil))
       (setq position (cdr (assoc selected-symbol name-and-pos)))
       (cond
        ((overlayp position)
         (goto-char (overlay-start position)))
        (t
         (goto-char position)))))
    ((listp symbol-list)
     (dolist (symbol symbol-list)
       (let (name position)
         (cond
          ((and (listp symbol) (imenu--subalist-p symbol))
           (ido-goto-symbol symbol))
          ((listp symbol)
           (setq name (car symbol))
           (setq position (cdr symbol)))
          ((stringp symbol)
           (setq name symbol)
           (setq position
                 (get-text-property 1 'org-imenu-marker symbol))))
         (unless (or (null position) (null name)
                     (string= (car imenu--rescan-item) name))
           (add-to-list 'symbol-names name)
           (add-to-list 'name-and-pos (cons name position))))))))

(global-set-key (kbd "M-i") 'ido-goto-symbol)

(defvar smart-use-extended-syntax nil
  "If t the smart symbol functionality will consider extended
syntax in finding matches, if such matches exist.")

(defvar smart-last-symbol-name ""
  "Contains the current symbol name.

This is only refreshed when `last-command' does not contain
either `smart-symbol-go-forward' or `smart-symbol-go-backward'")

(make-local-variable 'smart-use-extended-syntax)

(defvar smart-symbol-old-pt nil
  "Contains the location of the old point")

(defun smart-symbol-goto (name direction)
  "Jumps to the next NAME in DIRECTION in the current buffer.

DIRECTION must be either `forward' or `backward'; no other option is valid"

  ;; if `last-command' did not contain
  ;; `smart-symbol-go-forward/backward' then we assume
  ;; it's a brand-new command and we re-set the search term
  (unless (memq last-command '(smart-symbol-go-forward
                               smart-symbol-go-backward))
    (setq smart-last-symbol-name name))
  (setq smart-symbol-old-pt (point))
  (message (format "%s scan for symbol \"%s\""
                   (capitalize (symbol-name direction))
                   smart-last-symbol-name))
  (unless (catch 'done
            (while (funcall (cond
                             ((eq direction 'forward) ; forward direction
                              'search-forward)
                             ((eq direction 'backward) ; backward direction
                              'search-backward)
                             (t (error "Invalid direction"))) ; all others
                            smart-last-symbol-name t)
              (unless (memq (syntax-ppss-context
                             (syntax-ppss (point))) '(string comment))
                (throw 'done t))))
    (goto-char smart-symbol-old-pt)))

(defun smart-symbol-go-forward ()
  "Jumps forward to the next symbol at point"
  (interactive)
  (smart-symbol-goto (smart-symbol-at-pt 'end) 'forward))

(defun smart-symbol-go-backward ()
  "Jumps backward to the previous symbol at point"
  (interactive)
  (smart-symbol-goto (smart-symbol-at-pt 'begining) 'backward))

(defun smart-symbol-at-pt (&optional dir)
  "Returns the symbol at point and moves point to DIR (either `begining' or `end') of the symbol.

If `smart-use-extended-syntax' is t then that symbol is returned instead."
  (with-syntax-table (make-syntax-table)
    (if smart-use-extended-syntax
        (modify-syntax-entry ?. "w"))
    (modify-syntax-entry ?_ "w")
    (modify-syntax-entry ?- "w")
    ;; grab the word and return it
    (let ((word (thing-at-point 'word))
          (bounds (bounds-of-thing-at-point 'word)))
      (if word
          (progn
            (cond
             ((eq dir 'begining) (goto-char (car bounds)))
             ((eq dir 'end) (goto-char (cdr bounds)))
             (t (error "Invalid direction")))
            word)
        (error "No symbol found")))))

(global-set-key (kbd "M-n") 'smart-symbol-go-forward)
(global-set-key (kbd "M-p") 'smart-symbol-go-backward)
(defvar smart-use-extended-syntax nil
  "If t the smart symbol functionality will consider extended
syntax in finding matches, if such matches exist.")

(defvar smart-last-symbol-name ""
  "Contains the current symbol name.

This is only refreshed when `last-command' does not contain
either `smart-symbol-go-forward' or `smart-symbol-go-backward'")

(make-local-variable 'smart-use-extended-syntax)

(defvar smart-symbol-old-pt nil
  "Contains the location of the old point")

(defun smart-symbol-goto (name direction)
  "Jumps to the next NAME in DIRECTION in the current buffer.

DIRECTION must be either `forward' or `backward'; no other option
is valid."

  ;; if `last-command' did not contain
  ;; `smart-symbol-go-forward/backward' then we assume it's a
  ;; brand-new command and we re-set the search term.
  (unless (memq last-command '(smart-symbol-go-forward
                               smart-symbol-go-backward))
    (setq smart-last-symbol-name name))
  (setq smart-symbol-old-pt (point))
  (message (format "%s scan for symbol \"%s\""
                   (capitalize (symbol-name direction))
                   smart-last-symbol-name))
  (unless (catch 'done
            (while (funcall (cond
                             ((eq direction 'forward) ; forward
                              'search-forward)
                             ((eq direction 'backward) ; backward
                              'search-backward)
                             (t (error "Invalid direction"))) ; all others
                            smart-last-symbol-name nil t)
              (unless (memq (syntax-ppss-context
                             (syntax-ppss (point))) '(string comment))
                (throw 'done t))))
    (goto-char smart-symbol-old-pt)))

(defun smart-symbol-go-forward ()
  "Jumps forward to the next symbol at point"
  (interactive)
  (smart-symbol-goto (smart-symbol-at-pt 'end) 'forward))

(defun smart-symbol-go-backward ()
  "Jumps backward to the previous symbol at point"
  (interactive)
  (smart-symbol-goto (smart-symbol-at-pt 'beginning) 'backward))

(defun smart-symbol-at-pt (&optional dir)
  "Returns the symbol at point and moves point to DIR (either `beginning' or `end') of the symbol.

If `smart-use-extended-syntax' is t then that symbol is returned
instead."
  (with-syntax-table (make-syntax-table)
    (if smart-use-extended-syntax
        (modify-syntax-entry ?. "w"))
    (modify-syntax-entry ?_ "w")
    (modify-syntax-entry ?- "w")
    ;; grab the word and return it
    (let ((word (thing-at-point 'word))
          (bounds (bounds-of-thing-at-point 'word)))
      (if word
          (progn
            (cond
             ((eq dir 'beginning) (goto-char (car bounds)))
             ((eq dir 'end) (goto-char (cdr bounds)))
             (t (error "Invalid direction")))
            word)
        (error "No symbol found")))))

(global-set-key (kbd "M-n") 'smart-symbol-go-forward)
(global-set-key (kbd "M-p") 'smart-symbol-go-backward)

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


;;;; yasnippet
(require 'yasnippet)
(setq yas/snippet-dirs '("~/.emacs.d/el-get/yasnippet/snippets" "~/.emacs.d/el-get/yasnippet/extras/imported"))
(yas/global-mode 1)


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
 '(exec-path (quote ("/usr/bin" "/bin" "/usr/sbin" "/sbin" "/Applications/Emacs.app/Contents/MacOS/bin" "/usr/local/bin")))
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
