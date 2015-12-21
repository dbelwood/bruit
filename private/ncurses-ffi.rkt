#lang racket/base

(require ffi/unsafe
         ffi/unsafe/define)

(define-ffi-definer define-ncurses (ffi-lib "ncurses"))

(define (check-error v who)
  (unless (zero? v)
    (error who "failed: ~a" v)))

(define _WINDOW-pointer (_cpointer 'WINDOW))

(define-ncurses initscr (_fun -> _WINDOW-pointer))
(define-ncurses waddch (_fun _WINDOW-pointer _chtype -> (r: _int)
                             -> (check r 'waddch)))
(define-ncurses waddstr (_fun _WINDOW-pointer _string -> (r: _int)
                              -> (check r 'waddstr)))
(define-ncurses wrefresh (_fun _WINDOW-pointer -> (r: _int)
                               -> (check r 'wrefresh)))
(define-ncurses endwind (_fun -> (r: _int)
                              -> (check r 'endwind)))
