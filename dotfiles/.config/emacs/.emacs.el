(require 'package)
;;(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
(add-to-list 'package-archives
	     '("melpa-stable" .
	       "https://stable.melpa.org/packages/"))

(straight-use-package 'catppuccin-theme)
(load-theme 'catppuccin :no-confirm)
(setq catppuccin-flavor 'frappe) ;; or 'latte, 'macchiato, or 'mocha
(catppuccin-reload)

(package-initialize)
