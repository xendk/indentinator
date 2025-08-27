Indentinator
============

[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/xendk/indentinator.el/test.yml?branch=main&style=for-the-badge)](https://github.com/xendk/indentinator.el/actions?query=branch%3Amain)
[![Codecov](https://img.shields.io/codecov/c/github/xendk/indentinator.el?style=for-the-badge)](https://app.codecov.io/gh/xendk/indentinator.el)

Indentinator is (yet another) mode that attempts to automatically
indent your code as you edit.

It runs when Emacs is idle, and re-indents code after changed lines,
until re-indenting doesn't change indentation for 2 consecutive lines.

If interrupted by editing, it will make a note of where it got to and
continue indenting when Emacs is next idle, starting at the location
of the most recent change. Basically, it should be re-indenting where
you're working and if you leave it be, eventually get everything
re-indented if you make big changes.

# Requirements

Emacs 25.

# Usage

## Vanilla Emacs

``` emacs-lisp
(add-to-list 'load-path "/path/to/indentinator")
(require 'indentinator)
(add-hook 'emacs-lisp-mode-hook #'indentinator-mode)
```

## [use-package] and [straight]

``` emacs-lisp
(use-package indentinator
  :hook ((emacs-lisp-mode php-mode js-mode css-mode ruby-mode) . indentinator-mode)
  :straight (:host github :repo "xendk/indentinator.el"))
```

[use-package]: https://github.com/jwiegley/use-package
[straight]: https://github.com/raxod502/straight.el

# Configuration

The idle timeouts and the face used for the indicator when re-indentation is
running can be customized via the customize system.

# Comparison with other packages.

* [auto-indent-mode]
  Primarily indents code when yanked, but contains numerous bits and
  pieces, which explains the ~2500 lines of code.
  
* [aggressive-indent-mode]
  Automatically re-indents code after changes to the buffer. A more
  modest <500 lines of code.

Indentinator came to be after trying to fix a very minor bug in
`auto-indent-mode` and realizing how little of it I really used. I
tried `aggressive-indent-mode`, but it didn't work for me because it
stopped after one unchanged line, but in languages like PHP removing
the brace from an `if` statement wont change the indentation of the
next line, but the following.

[auto-indent-mode]: https://github.com/mattfidler/auto-indent-mode.el
[aggressive-indent-mode]: https://github.com/Malabarba/aggressive-indent-mode
