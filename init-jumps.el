
(global-set-key (kbd "<M-right>") 'forward-word)
(global-set-key (kbd "<M-left>") 'backward-word)

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

(provide 'init-jumps)
