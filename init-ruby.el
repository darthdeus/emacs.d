
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
