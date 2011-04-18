;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ch 3 모듈, 물체, 상태
;;; Ch 3.5 스트림
;;; p411

;; 셈미룸 계산법(delayed evaluation" 기법을 쓰면 끝없는 차례열도 스트림으로 나타낼 수 있다.



;;;==========================================
;;; 3.5.1 스트림과 (계산을) 미룬 리스트
;;; p412

;; 차례열을 리스트로 표현하면 쉽고도 깔끔하기는 하지만,
;; 시간과 공간 효율이 모두 떨어지는 대가를 치러야 한다.

;; p414
;; 스트림은 리스트만큼 커다란 대가를 치르지 않으면서도 차례열 패러다임으로 프로그램을 짤 수 있도록 도와주는 멋진 기법이다.
;; 어떤 프로그램에서 스트림을 인자로 받는 경우.
;; - 스트림을 덜 만든 상태 그대로 넘긴 다음
;; - 스트림 자체가 딱 쓸 만큼만 알아서 원소를 만들어 내게끔 하는 것이다.

;; p415
(define the-empty-stream '())

(define (stream-null? s)
  (null? s))

(define (stream-ref s n)
  (if (= n 0)
      (stream-car s)
      (stream-ref (stream-cdr s) (- n 1))))

(define (stream-map proc s)
  (if (stream-null? s)
      the-empty-stream
      (cons-stream (proc (stream-car s))
		   (stream-map proc (stream-cdr s)))))

(define (stream-for-each proc s)
  (if (stream-null? s)
      'done
      (begin (proc (stream-car s))
	     (stream-for-each proc (stream-cdr s)))))

(define (display-stream s)
  (stream-for-each display-line s))

(define (display-line x)
  (newline)
  (display x))

;;-----------------------------------------------
;; p417
;; cons-stream 프로시저는 다음처럼 정의된 특별한 형태다.
;; (cons-stream <a> <b>)
;; ->
;; (cons <a> (delay <b>))
;;=> "다음처럼 정의된 특별한 형태다"라는 말은 define으로 정의하는 것이 아니라
;;   언어 해석기 차원에서 변환하도록 정의된다라는 말인 것 같다.
;;   즉 이것은 매크로로 정의하거나 언어 해석기의 구현을 이와 같이 해야한다.
;; (define (cons-stream a b) 
;;   (cons a (delay b)))

(define-syntax cons-stream
  (syntax-rules ()
    ((cons-stream x y)
     (cons x (delay y)))))

(define (stream-car stream) (car stream))

(define (stream-cdr stream) (force (cdr stream)))


;;; 스트림은 어떻게 돌아가는가

;;------------------------------------------------
;;;---
;; p64 ch 1.2.6
(define (square x) (* x x))

(define (smallest-divisor n)
  (find-divisor n 2))

(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) n)
	((divides? test-divisor n) test-divisor)
	(else (find-divisor n (+ test-divisor 1)))))

(define (divides? a b)
  (= (remainder b a) 0))

(define (prime? n)
  (= n (smallest-divisor n)))
;;;---

;;; 어떤 범위에 있는 모든 정수를 뽑아내는 연산
(define nil '())

(define (enumerate-interval low high)
  (if (> low high)
      nil
      (cons low (enumerate-interval (+ low 1) high))))

(define (filter predicate sequence)
  (cond ((null? sequence) nil)
	((predicate (car sequence))
	 (cons (car sequence)
	       (filter predicate (cdr sequence))))
	(else (filter predicate (cdr sequence)))))

;; 일반 차례열
;; (filter prime?
;; 	(enumerate-interval 10000 1000000))
 

;;--------------------------------------------------
;; 스트림용 이누머레이터
(define (stream-enumerate-interval low high)
  (if (> low high)
      the-empty-stream
      (cons-stream 
       low 
       (stream-enumerate-interval (+ low 1) high))))

(define (stream-filter pred stream)
  (cond ((stream-null? stream) the-empty-stream)
	((pred (stream-car stream))
	 (cons-stream (stream-car stream)
		      (stream-filter pred
				     (stream-cdr stream))))
	(else (stream-filter pred (stream-cdr stream)))))


(cons 10000
      (delay (stream-enumerate-interval 10001 1000000)))

(stream-filter prime?
	       (stream-enumerate-interval 10000 1000000))
;;--------------------------------------------------


;; p420
;; 대개 셈미룸 계산법은 바라는 대로 프로그램이 실행되도록 하는 방식의 한 가지.

;;; delay와 force 프로시저 만들기

;; delay 프로시저는 아래와 같은 특별한 형태로 나타낸다.
;;                          ^^^^^^^^^^^^^^^^^
;;                       -> 'define으로 정의한다'가 아니라 매크로 또는 해석기의 구현을 의미
;; (delay <exp>)
;; ->
;; (lambda () <exp>)

;; (define (force delayed-object)
;;   (delayed-object))


;;; 셈미룬 물체를 처음으로 계산한 다음에 그 값을 어딘가에 적어 두었다가
;;; 나중에 그 물체를 다시 쓸 때 
;;; 같은 것을 계산한다면 적어둔 값을 쓰도록 한다.

(define (memo-proc proc)
  (let ((already-run? false) (result false))
    (lambda ()
      (if (not already-run?)
	  (begin (set! result (proc))
		 (set! already-run? true)
		 result)
	  result))))

;;



;;;--------------------------< ex 3.50 >--------------------------
;;; p422

(define (stream-map proc . argstreams)
  (if (null? (car argstreams))
      the-empty-stream
      (cons-stream
       (apply proc (map stream-car argstreams))
       (apply stream-map
	      (cons proc (map stream-cdr argstreams))))))

;;;--------------------------< ex 3.51 >--------------------------
;;; p422

(define x '())

(define (show x)
  (display-line x)
  x)

(define x
  (stream-map show
	      (stream-enumerate-interval 0 10)))
;; 0

(stream-ref x 5)
;; 1;2;3;4;5,5

(stream-ref x 7)
;; 6;7,7

;;;--------------------------< ex 3.52 >--------------------------
;;; p423

(define sum 0)

(define (accum x)
  (set! sum (+ x sum))
  sum)

(define seq
  (stream-map accum
	      (stream-enumerate-interval 1 20)))

(define y (stream-filter even? seq))
;; 
(define z (stream-filter (lambda (x) 
			   (= (remainder x 5) 0))
			 seq))

;; > sum
;; 1
;; > seq
;; (1 . #<promise>)
;; > > y
;; (6 . #<promise>)
;; > > z
;; (10 . #<promise>)

(stream-ref y 7)

(display-stream z)






;;;==========================================
;;; 3.5.2 무한 스트림(infinite stream)
;;; p424

(define (integers-starting-from n)
  (cons-stream n (integers-starting-from (+ n 1))))

(define integers (integers-starting-from 1))

integers 

(stream-ref integers 0)
(stream-ref integers 1)
(stream-ref integers 2)
(stream-ref integers 3)
(stream-ref integers 4)
(stream-ref integers 5)

(define (divisible? x y) (= (remainder x y) 0))

(define no-sevens
  (stream-filter (lambda (x) (not (divisible? x 7)))
		 integers))

(stream-ref no-sevens 100)


;; 피보나치 수들의 무한 스트림
(define (fibgen a b)
  (cons-stream a (fibgen b (+ a b))))

(define fibs (fibgen 0 1))

fibs



;;; 에라토스테네스의 체
(define (sieve stream)
  (cons-stream
   (stream-car stream)
   (sieve (stream-filter
	   (lambda (x)
	     (not (divisible? x (stream-car stream))))
	   (stream-cdr stream)))))

(define primes (sieve (integers-starting-from 2)))

primes

(stream-ref primes 0)
(stream-ref primes 1)
(stream-ref primes 2)
(stream-ref primes 3)
(stream-ref primes 4)

(stream-ref primes 50)


;;;;;;;;;;;;;;;;;;;;;;;
;;; 스트림을 드러나지 않게 정의하는 방법
;;; p427

(define ones (cons-stream 1 ones))

ones
;; car는 1이고, cdr는 다시 ones를 계산하겠다는 약속

(define (add-streams s1 s2)
  (stream-map + s1 s2))

(define integers (cons-stream 1 (add-streams ones integers)))

integers

(stream-ref integers 0)
(stream-ref integers 1)
(stream-ref integers 2)
(stream-ref integers 3)
(stream-ref integers 4)
(stream-ref integers 5)




;; 피보나치수열
(define fibs
  (cons-stream 0
	       (cons-stream 1
			    (add-streams (stream-cdr fibs)
					 fibs))))

fibs

(stream-ref fibs 0)
(stream-ref fibs 1)
(stream-ref fibs 2)
(stream-ref fibs 3)
(stream-ref fibs 4)
(stream-ref fibs 5)




;; 스트림의 모든 원소에 정해진 상수 값을 곱한다.
(define (scale-stream stream factor)
  (stream-map (lambda (x) (* x factor)) stream))

(define double (cons-stream 1 (scale-stream double 2)))

double


(stream-ref double 0)
(stream-ref double 1)
(stream-ref double 2)
(stream-ref double 3)
(stream-ref double 4)
(stream-ref double 5)



;; 정수의 스트림을 만든 후
;; 소수이면 걸러내는 방식
(define primes
  (cons-stream
   2
   (stream-filter prime?
		  (integers-starting-from 3))))


;; n이 sqrt(n) 과 같거나 그보다 작은 소수로 나누어지는지 따져봐야한다.
(define (prime? n)
  (define (iter ps)
    (cond ((> (square (stream-car ps)) n) #t) ;true)
	  ((divisible? n (stream-car ps)) #f) ;false)
	  (else (iter (stream-cdr ps)))))
  (iter primes))

primes

(stream-ref primes 0)
(stream-ref primes 1)
(stream-ref primes 2)
(stream-ref primes 3)
(stream-ref primes 4)
(stream-ref primes 5)

;;;--------------------------< ex 3.53 >--------------------------
;;; p430

(define s (cons-stream 1 (add-streams s s)))

;; -> 1 2 4 8 16 ...

s

(stream-ref s 0)
(stream-ref s 1)
(stream-ref s 2)
(stream-ref s 3)
(stream-ref s 4)
(stream-ref s 5)

;;;--------------------------< ex 3.54 >--------------------------
;;; p430

(define (mul-streams s1 s2)
  (stream-map * s1 s2))

(define s (cons-stream 2 (mul-streams s s)))

;; -> 4,16,256,65536
(stream-ref s 0)
(stream-ref s 1)
(stream-ref s 2)
(stream-ref s 3)
(stream-ref s 4)
(stream-ref s 5)



(define factorials (cons-stream 1 (mul-streams factorials integers)))

factorials

(stream-ref factorials 0)
(stream-ref factorials 1)
(stream-ref factorials 2)
(stream-ref factorials 3)
(stream-ref factorials 4)
(stream-ref factorials 5)


;;;--------------------------< ex 3.55 >--------------------------
;;; p430

;; 스트림 S를 인자로 받아서
;; S0, S0+S1, S0+S1+S2, ... 을 원소로 갖는 스트림을 내놓는 프로시저

(define (partial-sums stream)
  (define pts
    (cons-stream (stream-car stream)
		 (add-streams (stream-cdr stream)
			     pts)))
  pts)

(define pts (partial-sums integers))


(stream-ref integers 0)
(stream-ref integers 1)
(stream-ref integers 2)
(stream-ref integers 3)
(stream-ref integers 4)
;; 1 2 3 4 5

(stream-ref pts 0)
(stream-ref pts 1)
(stream-ref pts 2)
(stream-ref pts 3)
(stream-ref pts 4)
(stream-ref pts 5)


;;;--------------------------< ex 3.56 >--------------------------
;;; p430

;; 2,3,5 외의 소수 인수를 가지지 않는 양의 정수를 작은 것부터 차례대로 반복하지 않고 늘어놓는 문제

;; 만족하는 스트림 S
;; - S는 1로 시작한다.
;; - (scale-stream S 2)의 원소는 S의 원소다
;; - (scale-stream S 3)과 (scale-stream 5 6)의 원소도 그러하다.
;; - S의 원소는 이게 다다.

(define (merge s1 s2)
  (cond ((stream-null? s1) s2)
	((stream-null? s2) s1)
	(else
	 (let ((s1car (stream-car s1))
	       (s2car (stream-car s2)))
	   (cond ((< s1car s2car)
		  (cons-stream s1car (merge (stream-cdr s1) s2)))
		 ((> s1car s2car)
		  (cons-stream s2car (merge s1 (stream-cdr s2))))
		 (else
		  (cons-stream s1car
			       (merge (stream-cdr s1)
				      (stream-cdr s2)))))))))

;; (define S (cons-stream 1 (merge <??>)))
(define S (cons-stream 1 (merge (scale-stream S 2)
				(merge (scale-stream S 3)
				       (scale-stream S 5)))))

S


(stream-ref S 0)
(stream-ref S 1)
(stream-ref S 2)
(stream-ref S 3)
(stream-ref S 4)
(stream-ref S 5)
(stream-ref S 6)
(stream-ref S 7)
(stream-ref S 8)
(stream-ref S 9)
(stream-ref S 10)
(stream-ref S 11)
(stream-ref S 12)
(stream-ref S 13)
(stream-ref S 14)
(stream-ref S 15)
(stream-ref S 16)





;;;--------------------------< ex 3.57 >--------------------------
;;; p432

;; n번째 피보나치 수를 구하는데 필요한 덧셈의 수
;; - 지수 비례로 늘어난다는 사실을 밝혀라.




;;;--------------------------< ex 3.58 >--------------------------
;;; p432

(define (expand num den radix)
  (cons-stream
   (quotient (* num radix) den)
   (expand (remainder (* num radix) den) den radix)))

(define s1 (expand 1 7 10))

(stream-ref s1 0)
(stream-ref s1 1)
(stream-ref s1 2)
(stream-ref s1 3)
(stream-ref s1 4)
(stream-ref s1 5)
(stream-ref s1 6)
(stream-ref s1 7)
(stream-ref s1 8)
(stream-ref s1 9)
(stream-ref s1 10)

(define s2 (expand 3 8 10))

(stream-ref s2 0)
(stream-ref s2 1)
(stream-ref s2 2)
(stream-ref s2 3)
(stream-ref s2 4)
(stream-ref s2 5)
(stream-ref s2 6)
(stream-ref s2 7)
(stream-ref s2 8)
(stream-ref s2 9)
(stream-ref s2 10)


;;;--------------------------< ex 3.59 >--------------------------
;;; p432

;; a) a0 + a1x + a2x^2 + a3x^3 + ...
;; -> c + a0x + 1/2*a1x^2 + 1/3*a2x^3 + ...

(define (integrate-series s-before)
  (define series
    (stream-map / s-before 
		(stream-cdr integers)))
  series)


(define s-integrated (cons-stream 1 (integrate-series ones)))

(stream-ref s-integrated 0)
(stream-ref s-integrated 1)
(stream-ref s-integrated 2)
(stream-ref s-integrated 3)
(stream-ref s-integrated 4)
(stream-ref s-integrated 5)

;; b) x |-> e^x 를 미분한 결과는 그 자신과 같다.
;; 이를 표현하면 아래와 같다.
(define exp-series
  (cons-stream 1 (integrate-series exp-series)))


(stream-ref exp-series 0)
(stream-ref exp-series 1)
(stream-ref exp-series 2)
(stream-ref exp-series 3)
(stream-ref exp-series 4)
(stream-ref exp-series 5)

;; sin을 미분하면 cos
;; cos 을 미분하면 -sin
;; 을 바탕으로 사인과 코사인 수열 정의

(define cosine-series
  (cons-stream 1 (integrate-series (scale-stream sine-series -1.))))

(define sine-series
  (cons-stream 0 (integrate-series cosine-series)))

(stream-ref cosine-series 0)
(stream-ref cosine-series 1)
(stream-ref cosine-series 2)
(stream-ref cosine-series 3)
(stream-ref cosine-series 4)
(stream-ref cosine-series 5)

(stream-ref sine-series 0)
(stream-ref sine-series 1)
(stream-ref sine-series 2)
(stream-ref sine-series 3)
(stream-ref sine-series 4)
(stream-ref sine-series 5)


;;;--------------------------< ex 3.60 >--------------------------
;;; p434

;; ex3.59에서처럼 계수 스트림으로 나타낸 거듭제곱 수열을 가지고 
;;  add-streams를 써서 두 수열을 더하는 프로시저를 구현할 수 있다.
;; ??

;; 두 수열을 곱하는 프로시저

;; (define (mul-series s1 s2)
;;   (cons-stream (* (stream-car s1)
;; 		  (stream-car s2))
;; 	       (add-streams <??>
;; 			    <??>
;; )))


;; longfin 님 방법.
(define (mul-series s1 s2)
  (cons-stream
   (* (stream-car s1) (stream-car s2))
   (add-streams
    (mul-series (stream-cdr s1) s2)
    (scale-stream (stream-cdr s2) (stream-car s1)))))

(define expected
  (add-streams
   (mul-series sine-series sine-series)
   (mul-series cosine-series cosine-series)))

expected

(stream-ref expected 0)
(stream-ref expected 1)
(stream-ref expected 2)
(stream-ref expected 3)
(stream-ref expected 4)
(stream-ref expected 5)

(define ss (partial-sums expected))

 ss

(stream-ref ss 0)
(stream-ref ss 1)
(stream-ref ss 2)
(stream-ref ss 10)
;(display-stream ss)

;;;--------------------------< ex 3.61 >--------------------------
;;; p434

;; 상수항이 1인 거듭제곱 수열을 S
;; S*X = 1 이 되는 수열 X : 1/S 를 찾자.

;; S = 1 + Sr

;;      S * X = 1
;; (1+Sr) * X = 1
;; X + Sr * X = 1
;;          X = 1 - Sr*X

(define (invert-unit-series s)
  (define s-inv
    (cons-stream 1
		 (scale-stream (mul-streams (stream-cdr s)
					    s-inv)
			       -1)))
  s-inv)

;; 상수항이 1, n차 계수가 n인 거듭제곱 수열 S
(define S integers)

(define X (invert-unit-series S))


(stream-ref X 0)
(stream-ref X 1)
(stream-ref X 2)
(stream-ref X 3)
(stream-ref X 4)
(stream-ref X 5)

(define SS (partial-sums S))

(stream-ref SS 10)

(define SX (partial-sums X))

(stream-ref SX 10)

(* (stream-ref SS 100)
   (stream-ref SX 100)
   1.0)
;; 1에 가까운 값을 기대했으나,,,,

;; 흠,,, 잘못 푼 듯...



;;;--------------------------< ex 3.62 >--------------------------
;;; p435






;;;==========================================
;;; 3.5.3 스트림 패러다임
;;; p435

;;; 셈미룸 계산법과 스트림 기법은 갇힌 상태와 덮어쓰기에서 얻을 수 있는 좋은 점을 제공

;;; 스트림 방식에서는 순간순간 변하는 상태가 아니라, 전체 시간의 흐름에 초점을 두고 생각할 수 있으며,
;;; 따라서 서로 다른 시점의 상태들을 한데 묶거나 서로 비교하기가 편하다.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 스트림 프로세스로 반복을 표현하는 방법
;;; p435

;;; 여러 변수 값을 바꾸는 방법에 기대지 않아도, 끝없이 펼쳐지는 스트림으로 상태를 나타낼 수 있다.


;;;-----------------------------
;;; sqrt-stream
(define (average a b)
  (/ (+ a b) 2))

(define (sqrt-improve guess x)
  (average guess (/ x guess)))

(define (sqrt-stream x)
  (define guesses
    (cons-stream 1.0
		 (stream-map (lambda (guess)
			       (sqrt-improve guess x))
			     guesses)))
  guesses)

(define sq2 (sqrt-stream 2.0))

(stream-ref sq2 0)
(stream-ref sq2 1)
(stream-ref sq2 2)
(stream-ref sq2 3)
(stream-ref sq2 4)
(stream-ref sq2 5)
(stream-ref sq2 6)
;;;-----------------------------


;;;-----------------------------
;;; pi-stream
(define (pi-summands n)
  (cons-stream (/ 1.0 n)
	       (stream-map - (pi-summands (+ n 2)))))

(define pi-stream
  (scale-stream (partial-sums (pi-summands 1)) 4))

;; (display-stream pi-stream)
;; 4.0
;; 2.666666666666667
;; 3.466666666666667
;; 2.8952380952380956
;; 3.3396825396825403
;; 2.9760461760461765
;; 3.2837384837384844
;; 3.017071817071818
;; 3.2523659347188767



;;; 스트림 방식을 쓰면 같은 일을 하더라도 몇 가지 재밌는 재주를 부릴 수 있어서 좋다.
;;; - 차례열 가속기
;;;    : 어떤 값에 가까워지는 차례열을 훨씬 빠르게 다가가도록 바꾸어 줌.

;;; (오일러) 
;;; 부호가 번갈아 바뀌는 수열이 있을 때, 그 부분합을 나타내는 차례열과 잘 맞아떨어지는 가속기가 있다.
;;;                 (S_(n+1) - S_n)^2
;;; S_(n+1) -  --------------------------
;;;             S_(n-1) - 2S_n + S_(n+1)



;; 처음의 차례열 스트림 : s
;; 가속 변환한 차례열 :
(define (euler-transform s)
  (let ((s0 (stream-ref s 0))    ; S_(n-1)
	(s1 (stream-ref s 1))    ; S_n
	(s2 (stream-ref s 2)))   ; S_(n+1)
    (cons-stream (- s2 (/ (square (- s2 s1))
			  (+ s0 (* -2 s1) s2)))
		 (euler-transform (stream-cdr s)))))

;; (display-stream (euler-transform pi-stream))
;; 3.166666666666667
;; 3.1333333333333337
;; 3.1452380952380956
;; 3.13968253968254
;; 3.1427128427128435
;; 3.1408813408813416
;; 3.142071817071818
;; 3.1412548236077655
;; 3.1418396189294033




;;; 가속한 차례열을 다시 가속하는 방법
;;; - 재귀하면서 가속하는 방법
(define (make-tableau transform s)
  (cons-stream s
	       (make-tableau transform
			     (transform s))))

;; 태블로의 행마다 첫 원소를 뽑아 차례열을 만들어 낸다.
(define (accelerated-sequence transform s)
  (stream-map stream-car
	      (make-tableau transform s)))

;; (display-stream (accelerated-sequence euler-transform
;; 				      pi-stream))
;; 4.0
;; 3.166666666666667
;; 3.142105263157895
;; 3.141599357319005
;; 3.1415927140337785
;; 3.1415926539752927
;; 3.1415926535911765
;; 3.141592653589778
;; 3.1415926535897953
;; 3.141592653589795
;; +nan.0
;; +nan.0



;;;--------------------------< ex 3.63 >--------------------------
;;; p440

;; guess 변수 없이 sqrt-stream 작성
;; 반복하는 계산이 많아져서 효율이 크게 떨어진다
;; - 왜?
;;  : 기존에는 stream의 다음 인덱스 원소를 계산할 때 만들어진 guess 으로부터 한 단계만 더 계산하면 된다.
;;  : 여기서는 다음 인덱스 원소를 계산할 때 (sqrt-stream x)로 재귀를 하면서 매번 처음부터 n번째까지를 계산해야 한다.
(define (sqrt-stream x)
  (cons-stream 1.0
	       (stream-map (lambda (guess)
			     (sqrt-improve guess x))
			   (sqrt-stream x))))

(define sq-of-2 (sqrt-stream 2))

(stream-ref sq-of-2 10)


;;;--------------------------< ex 3.64 >--------------------------
;;; p440

;;; 스트림과 수(허용 오차)를 인자로 받는 stream-limit 프로시저 정의
;; - 스트림을 훑어보다가 이어지는 두 원소를 뺀 절대값이 허용 오차보다 작은 경우를 찾아내면
;;   그 두 원소 중 두 번째 원소를 결과로 내놓는다.

(define (stream-limit s tolerance)
  (let ((d1 (stream-car s))
	(d2 (stream-car (stream-cdr s))))
    (if (< (abs (- d1 d2)) tolerance)
	d2
	(stream-limit (stream-cdr s) tolerance))))
	 

(define (new-sqrt x tolerance)
  (stream-limit (sqrt-stream x) tolerance))

(new-sqrt 2 0.01)
(new-sqrt 2 0.001)

;;;--------------------------< ex 3.65 >--------------------------
;;; p441

;; 2의 자연로그에 가까운 값에 다가드는 차례열 세 개
;; ln2 = 1 - 1/2 + 1/3 - 1/4 + ...

;;; 1) 그냥 stream
(define (ln2-summands n)
  (cons-stream (/ 1.0 n)
	       (stream-map - (ln2-summands (+ n 1)))))

(define ln2-stream
  (partial-sums (ln2-summands 1)))

;; (display-stream ln2-stream)

(stream-ref ln2-stream 10)
(stream-ref ln2-stream 100)


;;; 2) 오일러 기법 가속


;;; 3) 태블로 사용




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 쌍으로 이루어진 무한 스트림
;;; p441




;; ex 3.66 ~ 3.72





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 신호를 표현하는 스트림
;;; p447




;; ex 3.73 ~ 3.76


;;;==========================================
;;; 3.5.4 스트림과 셈미룸 계산법(stream and delayed evaluation)
;;; p451


;; ex 3.77 ~ 3.80

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 정의대로 계산하기(normal-order evaluation)
;;; p458




;;;==========================================
;;; 3.5.5 모듈로 바라본 함수와 물체
;;; p459




;; ex 3.81 ~ 3.82

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 함수형 프로그래밍에서 시간의 문제
;;; p461

