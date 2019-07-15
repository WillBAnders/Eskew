#lang racket

(require (for-syntax syntax/parse))

(provide #%datum
         (rename-out [#%eskew-module-begin #%module-begin]))

(module reader syntax/module-reader eskew
  #:wrapper1 (λ (t)
               (parameterize ([current-readtable (make-eskew-readtable (current-readtable))])
                 (t)))
  (define (make-eskew-readtable rt)
    (make-readtable rt
                    #\⊏ #\( #f
                    #\⊐ #\) #f
                    #\. #\a #f)))

(begin-for-syntax
  (define-splicing-syntax-class expr
    #:datum-literals (↓ ↑ ← → ↖ ↘ ↗ ↙ \. : + - * / = ≠)
    #:attributes (stx)
    [pattern ↓ #:with stx
             #'(begin
                 (display ">")
                 (push-front! envmt (string->number (read-line (current-input-port) 'any)))
                 (displayln ""))]
    [pattern ↑ #:with stx
             #'(displayln (pull-front! envmt))]
    [pattern ← #:with stx
             #'(push-front! stack (eskew-queue-pull!))]
    [pattern → #:with stx
             #'(push-front! queue (eskew-stack-pull!))]
    [pattern ↖ #:with stx
             #'(push-front! stack (pull-front! envmt))]
    [pattern ↘ #:with stx
             #'(push-front! envmt (eskew-stack-pull!))]
    [pattern ↗ #:with stx
             #'(push-front! queue (pull-front! envmt))]
    [pattern ↙ #:with stx
             #'(push-front! envmt (eskew-queue-pull!))]
    [pattern \. #:with stx
             #'(push-front! envmt (first (unbox envmt)))]
    [pattern : #:with stx
             #'(set-box! envmt (reverse (unbox envmt)))]
    [pattern + #:with stx
             #'(push-front! envmt (+ (pull-front! envmt) (pull-front! envmt)))]
    [pattern - #:with stx
             #'(push-front! envmt (- (pull-front! envmt) (pull-front! envmt)))]
    [pattern * #:with stx
             #'(push-front! envmt (* (pull-front! envmt) (pull-front! envmt)))]
    [pattern / #:with stx
             #'(push-front! envmt (/ (pull-front! envmt) (pull-front! envmt)))]
    [pattern = #:with stx
             #'(push-front! envmt (if (= (pull-front! envmt) (pull-front! envmt)) 1 0))]
    [pattern ≠ #:with stx
             #'(push-front! envmt (if (= (pull-front! envmt) (pull-front! envmt)) 0 1))]
    [pattern n:number #:with stx
             #'(push-front! envmt n)]
    [pattern (e:expr ...) #:with stx
             #'(loop (λ () e.stx ...))]))

(define-syntax (#%eskew-module-begin stx)
  (syntax-parse stx
    [(_ e:expr ...)
     #'(#%plain-module-begin e.stx ...)]))

(define stack (box empty))
(define queue (box empty))
(define envmt (box empty))

(define (push-front! deque elem)
  (set-box! deque (cons elem (unbox deque))))

(define (push-back! deque elem)
  (set-box! deque (append (unbox deque) (list elem))))

(define (pull-front! deque)
  (define elem (first (unbox deque)))
  (set-box! deque (list-tail (unbox deque) 1))
  elem)

(define (pull-back! deque)
  (define elem (last (unbox deque)))
  (set-box! deque (reverse (list-tail (reverse (unbox deque)) 1)))
  elem)

(define (eskew-stack-pull!)
  (if (empty? (unbox stack))
      (pull-front! queue)
      (pull-front! stack)))

(define (eskew-queue-pull!)
  (if (empty? (unbox queue))
      (pull-back! stack)
      (pull-back! queue)))

(define (loop body)
  (if (= (pull-front! envmt) 0)
      (void)
      (begin
        (body)
        (loop body))))
