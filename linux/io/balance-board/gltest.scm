#!/usr/bin/gosh -I.
(use gl)
(use gl.glut)
(use balance-board)
(use util.list)

(define *frames* 0)
(define *t0*	 0)
(define *width* 0)
(define *height* 0)
(define *wii* #f)
(define *max-weight* 0)

(define (weights->xy weights)
  (let* ((wc (map (lambda(x)
		    (cons (car x) (max 0.0 (cdr x))))
		  weights))
	 (t (apply + (map cdr wc)))
	 (wn (map (lambda(x)
		    (cons (car x) (/. (cdr x) t)))
		  wc)))
    (if (<= t 0)
	'(0.5 0.5)
	(list
	 (+.
	  (assoc-ref wn 'right_top)
	  (assoc-ref wn 'right_bottom))
	 (+.
	  (assoc-ref wn 'left_top)
	  (assoc-ref wn 'right_top))))))

(define (draw)
  (gl-clear GL_COLOR_BUFFER_BIT)
  (gl-push-matrix)
  (let1 s (max (+ (quotient *width* 100)  1)
	       (+ (quotient *height* 100) 1))
	(let* ((w (balance-weights *wii*))
	       (pos (weights->xy w)))
	  (set! *max-weight* (max *max-weight* (apply + (map cdr w))))
	  (gl-color 1 0 0)
	  (gl-push-matrix)
	  (gl-translate 0
			(*. *height* (/. (apply + (map cdr w)) *max-weight*))
			0)
	  (gl-begin GL_QUADS)
	  (gl-vertex 0 0)
	  (gl-vertex 0 s)
	  (gl-vertex s s)
	  (gl-vertex s 0)
	  (gl-end)
	  (gl-pop-matrix)
	  (gl-color 1 1 1)
	  (gl-translate (*. *width*  (ref pos 0))
			(*. *height* (ref pos 1))
			0)
	  (gl-translate (* -0.5 s)
			(* -0.5 s)
			0)
	  (gl-begin GL_QUADS)
	  (gl-vertex 0 0)
	  (gl-vertex 0 s)
	  (gl-vertex s s)
	  (gl-vertex s 0)
	  (gl-end)
	  (gl-pop-matrix)
	  (glut-swap-buffers)
	  (inc! *frames*)))
  
  (let1 t (glut-get GLUT_ELAPSED_TIME)
	(when (>= (- t *t0*) 5000)
	      (let1 seconds (/ (- t *t0*) 1000.0)
		    (print #`",*frames* in ,seconds seconds = ,(/ *frames* seconds) FPS")
		    (set! *t0*	   t)
		    (set! *frames* 0)))))

;; new window size or exposure
(define (reshape width height)
  (set! *width* width)
  (set! *height* height)
  (gl-viewport 0 0 width height)
  (gl-matrix-mode GL_PROJECTION)
  (gl-load-identity)
  (gl-ortho 0 width 0 height 0 100)
  (gl-matrix-mode GL_MODELVIEW)
  (gl-load-identity))

;; exit upon ESC 
(define (key k x y)
  (when (= k (char->integer #\escape))
	(error "escape pressed")))

(define (visible vis)
  (if (= vis GLUT_VISIBLE)
      (glut-idle-func glut-post-redisplay)
      (glut-idle-func #f)))

(define (main args)
  (set! *wii* (balance-open))
  (unwind-protect
   (begin
     (glut-init args)
     (glut-init-display-mode (logior GLUT_DOUBLE GLUT_RGB))
     (glut-create-window "balance board test")
     (newline)
     (print #`"GL_RENDERER	  = ,(gl-get-string GL_RENDERER)")
     (print #`"GL_VERSION	  = ,(gl-get-string GL_VERSION)")
     (print #`"GL_VENDOR	  = ,(gl-get-string GL_VENDOR)")
     (print #`"GL_EXTENSIONS = ,(gl-get-string GL_EXTENSIONS)")
     (newline)
     #|(gl-enable GL_BLEND)
     (gl-enable GL_LINE_SMOOTH)
     (gl-enable GL_POLYGON_SMOOTH)|#
     (glut-display-func	draw)
     (glut-reshape-func	reshape)
     (glut-keyboard-func	key)
     (glut-visibility-func visible)
     (glut-main-loop)
     0)
   #?=(balance-close *wii*)))
