#lang racket/base

(struct cursor (x
                y) #:prefab)

(struct screen (rows
                columns
                cursor) #:prefab)

(struct tty (input
             output
             key-reader
             screen) #:prefab)

(struct editor (tty))

(define default-key-reader #f)

(define (new-cursor)
  (cursor 0 0))

(define (new-screen)
  (screen 24 80 (new-cursor)))

(define (new-tty input output)
  (tty input
       output
       default-key-reader
       (new-screen)))

(define (new-editor input output)
  (editor (new-tty input output)))

(define (start-session)
  (let ([editor (new-editor (current-input-port) (current-output-port))])
    (do
        (let ([char (read (tty-input))])
          (display char (tty-output))))))
