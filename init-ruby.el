;;;; Ruby
;; (add-hook 'ruby-mode-hook 'flymake-ruby-load)
(require 'rspec-mode)

;; TODO - why is the default rspec-mode-verifible-keymap instead of
;; rspec-mode-keymap ?
;; https://github.com/pezra/rspec-mode/blob/master/rspec-mode.el#L470
(add-hook 'ruby-mode-hook
          (lambda () (local-set-key rspec-key-command-prefix rspec-mode-keymap))
          'rspec-mode
          'flymake-ruby-load)

;; 1.9 syntax checking
;; (add-to-list 'load-path "~/.emacs.d/el-get/Enhanced-Ruby-Mode")
;; (require 'ruby-mode)

(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec$" . ruby-mode))

;; Setting rbenv path
;; (setenv "PATH" (concat (getenv "HOME") "/.rbenv/shims:" (getenv "HOME") "/.rbenv/bin:" (getenv "PATH")))
;; (setq exec-path (cons (concat (getenv "HOME") "/.rbenv/shims") (cons (concat (getenv "HOME") "/.rbenv/bin") exec-path)))

(provide 'init-ruby)
