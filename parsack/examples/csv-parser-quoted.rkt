#lang racket
(require "../parsack.rkt")
(provide (all-defined-out))

;; csv parser using sepBy + support for quoted cells

(define $quotedChar
  (<or> (noneOf "\"")
        (try (>> (string "\"\"") (return #\")))))

(define $quotedCell 
  (parser-one 
   (char #\")
   (~> (many $quotedChar))
   (<?> (char #\") "quote at end of cell"))
  #;(parser-compose
   (char #\")
   (content <- (many $quotedChar))
   (<?> (char #\") "quote at end of cell")
   (return content)))


;; cellContent in csv-parser.rkt
;(define cell (many (noneOf ",\n")))
(define $cell (<or> $quotedCell (many (noneOf ",\n\r"))))

;; a line must end in \n
(define $line (sepBy $cell (char #\,)))

;; result is list of list of chars
(define $csv (endBy $line $eol))

(define (csvFile filename) ($csv (with-input-from-file filename port->string)))
