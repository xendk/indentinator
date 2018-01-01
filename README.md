Indentinator
============

Indentinator is (yet another) mode that automatically indent your code
as you edit.

It runs when Emacs is idle, and re-indents code after changed lines,
until re-indenting doesn't change indentation for 2 consecutive lines.

# Usage

## Vanilla Emacs

``` emacs-lisp
(add-to-list 'load-path "/path/to/indentinator")
(require 'indentinator)
(add-hook 'emacs-lisp-mode-hook #'aggressive-indent-mode)
```

## [use-package] and [straight]

``` emacs-lisp
(use-package indentinator
  :hook ((emacs-lisp-mode php-mode js-mode css-mode ruby-mode) . indentinator-mode)
  :straight (:host github :repo "xendk/indentinator"))
```

[use-package]:https://github.com/jwiegley/use-package
[straight]:https://github.com/raxod502/straight.el
