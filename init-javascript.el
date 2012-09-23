;;;; JavaScript
;; (autoload 'js2-mode "js2-mode" nil t)
;; (add-to-list 'auto-mode-alist '("\\.js$" . js3-mode))
;; (require 'js3-mode)


(add-to-list 'auto-mode-alist '("\\.handlebars$" . html-mode))
(add-to-list 'auto-mode-alist '("\\.hbs$" . html-mode))

;;;; CoffeeScript

(setq coffee-command "/usr/local/bin/coffee")


(defun coffee-custom ()
  "coffee-mode-hook"
  (set (make-local-variable 'tab-width) 2))
(add-hook 'coffee-mode-hook
          '(lambda () (coffee-custom)))

(provide 'init-javascript)
