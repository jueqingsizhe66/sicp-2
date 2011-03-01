
;; racket -l r5rs/run

;; 연습문제 3.12

(define (append! x y)
  (set-cdr! (last-pair x) y)
  x)

(define (last-pair x)
  (if (null? (cdr x))
      x
      (last-pair (cdr x))))

(define x (list 'a 'b))
(define y (list 'c 'd))
(define z (append x y))
z
(cdr x)

(define w (append! x y))
w
(cdr x)


;; 연습문제 3.13

(define (make-cycle x)
  (set-cdr! (last-pair x) x)
  x)

(define z (make-cycle (list 'a 'b 'c)))

;; what happen?
(last-pair z) 				


;; 연습문제 3.14

(define (mystery x)
  (define (loop x y)
    (if (null? x) y
	(let ((temp (cdr x)))
	  (set-cdr! x y)
	  (loop temp x))))
  (loop x '()))

(define v (list 'a 'b 'c 'd))
(define w (mystery v))


(define x (list 'a 'b))
(define z1 (cons x x))
(define z2 (cons (list 'a 'b) (list 'a 'b)))

(define (set-to-wow! x)
  (set-car! (car x) 'wow)
  x)

z1
(set-to-wow! z1)
z2
(set-to-wow! z2)

;; 연습문제 3.15

;; 연습문제 3.16

(define (count-pairs x)
  (if (not (pair? x)) 0
      (+ (count-pairs (car x))
	 (count-pairs (cdr x)) 1)))

;; (define (count-pairs x)
;;   (if (not (pair? x)) (begin
;; 			(display x) (display "\n")
;; 			0)
;;       (+ (count-pairs (car x))
;; 	 (count-pairs (cdr x)) 1)))

;; car 과 cdr 이 같은 pair 를 가리키고 있다면?!

;; 세계의 pair 가 있지만..4를 출력.
(let ((a (list 'a)))
  (let ((b (list a a)))
    (count-pairs b)))

;; 7
(let ((a (cons 10 20)))
  (let ((b (cons a a)))
    (let ((c (cons b b)))
      (count-pairs c))))

;; 영원히 도는 프로시져
(let ((a (list 1 2)))
  (let ((b (cons 10 a)))
    (set-cdr! (cdr a) b)
    (count-pairs a)))

;; 연습문제 3.17

(define (find-item item seq)
  (cond ((null? seq) #f)
	((eq? item (car seq)) #t)
	(else (find-item item (cdr seq)))))

;; (let ((a '(1 2 3)))
;;   (let ((b (list 10 20 a 30)))
;;     (find-item a b)))

(define (new-count-pairs x)
  (let ((repo '()))
    (define (count-pairs x)
      (if (or (not (pair? x)) (find-item x repo)) 0
	  (begin
	    (set! repo (cons x repo))
	    (+ (count-pairs (car x))
	       (count-pairs (cdr x)) 1))))
    (count-pairs x)))



(let ((a (list 'a)))
  (let ((b (list a a)))
    (new-count-pairs b)))


(let ((a (cons 10 20)))
  (let ((b (cons a a)))
    (let ((c (cons b b)))
      (new-count-pairs c))))

(let ((a (list 1 2)))
  (let ((b (cons 10 a)))
    (set-cdr! (cdr a) b)
    (new-count-pairs a)))


;; 연습문제 3.18

(define (make-cycle list)
  (set-cdr! (last-pair list) list)
  list)

(let ((a (make-cycle '(1 2 3))))
  (eq? a (cdddr a)))

(define (find-cycle list)
  (let ((copy '()))
    (define (inner-find-cycle x)
      (cond ((null? x) #f)
	    ((find-item x copy) #t)
	    (else (begin
		    (set! copy (cons x copy))
		    (inner-find-cycle (cdr x))))))
    (inner-find-cycle (cdr list))))

(find-cycle '(1 2 3 4))
(find-cycle (make-cycle '(1 2 3 4)))
(find-cycle (cons 'q (make-cycle '(1 2 3 4))))

;; 연습문제 3.19
;; Floyd's idea:
 (define (contains-cycle? lst) 
   (define (safe-cdr l) 
     (if (pair? l) 
         (cdr l) 
         '())) 
   (define (iter a b) 
     (cond ((not (pair? a)) #f) 
           ((not (pair? b)) #f) 
           ((eq? a b) #t) 
           ((eq? a (safe-cdr b)) #t) 
           (else (iter (safe-cdr a) (safe-cdr (safe-cdr b)))))) 
   (iter (safe-cdr lst) (safe-cdr (safe-cdr lst))))

(contains-cycle? (make-cycle '(1 2 3 4)))

;; 연습문제 3.20

(define (cons2 x y)
  (define (set-x! v) (set! x v))
  (define (set-y! v) (set! y v))
  (define (dispatch m)
    (cond ((eq? m 'car) x)
	  ((eq? m 'cdr) y)
	  ((eq? m 'set-car!) set-x!)
	  ((eq? m 'set-cdr!) set-y!)
	  (else (error "Undefined operation --CONS" m))))
  dispatch)

(define (car2 z)
  (z 'car))

(define (cdr2 z)
  (z 'cdr))

(define (set-car2! z new-value)
  ((z 'set-car!) new-value)
  z)

(define (set-cdr2! z new-value)
  ((z 'set-cdr!) new-value)
  z)

(define x (cons2 1 2))
(define z (cons2 x x))
(set-car2! (cdr2 z) 17)

(car2 x)


;; 3.3.2 큐

(define (front-ptr queue) (car queue))
(define (rear-ptr queue) (cdr queue))
(define (set-front-ptr! queue item) (set-car! queue item))
(define (set-rear-ptr! queue item) (set-cdr! queue item))

(define (empty-queue? queue)
  (null? (front-ptr queue)))

(define (make-queue)
  (cons '() '()))

(define (front-queue queue)
  (if (empty-queue? queue)
      (error "FRONT called with an empty queue" queue)
      (car (front-ptr queue))))

(define (insert-queue! queue item)
  (let ((new-pair (cons item '())))
    (cond ((empty-queue? queue) (begin
				  (set-front-ptr! queue new-pair)
				  (set-rear-ptr! queue new-pair)
				  queue))
	  (else
	   (set-cdr! (rear-ptr queue) new-pair)
	   (set-rear-ptr! queue new-pair)
	   queue))))

(define (delete-queue! queue)
  (cond ((empty-queue? queue) (error "DELETE! called with an empty queue" queue))
	(else
	 (set-front-ptr! queue (cdr (front-ptr queue)))
	 queue)))


;; 연습문제 3.21

(define (error message err)
  (display message)
  (display " ") (display err) (display "\n"))

(define q1 (make-queue))

(insert-queue! q1 'a)
(insert-queue! q1 'b)
(delete-queue! q1)
(delete-queue! q1)
(empty-queue? q1)

(define (print-queue queue)
  (front-ptr queue))

(print-queue q1)
	   
	   

;; 연습문제 3.22
;; 



