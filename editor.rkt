#lang racket/base

(require racket/system)

(struct cursor (x
                y) #:prefab)

(struct screen (rows
                columns
                data
                cursor) #:prefab)

(struct tty (input
             output
             key-reader
             screen) #:prefab)

(struct editor (tty))

(define default-key-reader #f)

(define (new-cursor)
  (cursor 0 0))

(define (new-screen rows columns)
  (screen
   rows
   columns
   (make-vector rows (make-vector columns #\ )) 
   (new-cursor)))

(define (new-tty input output)
  (tty input
       output
       default-key-reader
       (new-screen)))

(define (new-editor input output)
  (editor (new-tty input output)))

;; Ingraciously stolen from - http://lists.racket-lang.org/dev/archive/2009-March/000371.html
(define (stty . args)
  (define stty-exec
    (or (find-executable-path "stty")
        (error 'stty "could not find executable")))
  (or (apply system* stty-exec args)
      (error 'stty "couldn't run with ~e" args)))

(define (call-with-stty thunk)
  (define (original-settings)
    (let ([o (open-output-string)])
      (parameterize ([current-output-port o])
        (stty "-g")
        (regexp-replace #rx"\r?\n$" (get-output-string o) ""))))
  (let ([settings (original-settings)])
    (dynamic-wind (lambda () (stty "raw" "-echo" "opost"))
                  thunk
                  (lambda () (stty settings)))))

(define (terminal-dimensions)
  (vector (stty "size")))

;;(define (paint-screen screen output)
;;  (for [row (screen-data screen)]
;;    (for [ch row]
;;      (write

(define (start-session)
  (let* ([editor (new-editor (current-input-port) (current-output-port))]
         [tty (editor-tty editor)]
         [input (tty-input tty)]
         [output (tty-output tty)])
    (call-with-stty
     (lambda ()
       (let loop ()
         (let ([ch (read-char input)])
           (write-char ch output)
           (flush-output output)
           (unless (eq? ch #\q)
             (loop))))))))

(start-session)
