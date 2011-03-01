;;;
;;; From Gauche-gl/examples/glbook/example8-2.scm
;;;
(use gl)
(use gl.glut)
(use gauche.uvector)
(use ggc.file.bdf)

(define *font-offset* #f)

(define (bdf-bitmap->gl-bitmap  w bml)
  (cond ((<= w 8)
         (list->u8vector (reverse bml)))
        ((<= w 16)
         (let lp ((bml bml)
                  (r   '()))
           (if (null? bml)
               (list->u8vector r)
               (lp (cdr bml) 
                   (cons (bit-field (car bml) 8 16)
                         (cons (bit-field (car bml) 0 8) 
                               r))))))
        ((<= w 24)
         (let lp ((bml bml)
                  (r   '()))
           (if (null? bml)
               (list->u8vector r)
               (lp (cdr bml) 
                   (cons (bit-field (car bml) 16 24)
                         (cons (bit-field (car bml) 8 16) 
                               (cons (bit-field (car bml) 0 8)
                                     r)))))))
        (else (error "font too wide"))))

(define *font-spacing* 2)
(define *bdf-file* "bdf/a14.bdf")
;;(define *bdf-file* "bdf/12x24.bdf")

(define (make-raster-font)
  (let* ((bdf (with-input-from-file *bdf-file* read-bdf))
         (offset (gl-gen-lists 256)))
    (gl-pixel-store GL_UNPACK_ALIGNMENT 1)
    (set! *font-offset* offset)
    (for-each-char 
     (lambda (char)
       (let* ((c   (bdf-char-encoding char))
              (dw  (bdf-char-dwidth char))
              (bbx (bdf-char-bbx char))
              (bmv (bdf-bitmap->gl-bitmap (list-ref bbx 0)
                                          (bdf-char-bitmap char))))
         (gl-new-list (+ offset c) GL_COMPILE)
         (gl-bitmap (list-ref bbx 0) (list-ref bbx 1)
                    (- (list-ref bbx 2)) 
                    (- (list-ref bbx 3))
                    (+ *font-spacing* (list-ref dw 0)) 
                    (- (list-ref dw 1)) 
                    bmv)
         (gl-end-list)))
     bdf)))

(define (init)
  (gl-shade-model GL_FLAT)
  (make-raster-font))

(define (print-string s)
  (gl-push-attrib GL_LIST_BIT)
  (gl-list-base *font-offset*)
  (gl-call-lists s)
  (gl-pop-attrib))

(define (disp)
  (gl-clear GL_COLOR_BUFFER_BIT)
  (gl-color '#f32(1.0 1.0 1.0))
  (gl-raster-pos 20 140)
  (print-string "THE QUICK BROWN FOX JUMPS")
  (gl-raster-pos 20 80)
  (print-string "OVER A LAZY DOG abracadabra")
  (gl-raster-pos 20 20)
  (print-string "~1234567890!@#$%^&*()")
  (gl-flush)
  )

(define (reshape w h)
  (gl-viewport 0 0 w h)
  (gl-matrix-mode GL_PROJECTION)
  (gl-load-identity)
  (gl-ortho 0.0 w 0.0 h -1.0 1.0)
  (gl-matrix-mode GL_MODELVIEW)
  )

(define (keyboard key x y)
  (cond
   ((= key 27)                          ;ESC
    (exit 0)
    )))

(define (main args)
  (glut-init args)
  (glut-init-display-mode (logior GLUT_SINGLE GLUT_RGB))
  (glut-init-window-size 400 300)
  (glut-init-window-position 100 100)
  (glut-create-window (car args))
  (init)
  (glut-reshape-func reshape)
  (glut-keyboard-func keyboard)
  (glut-display-func disp)
  (glut-main-loop)
  0)
