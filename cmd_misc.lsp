(defun create-comment-pline (/ current-layer last-before obj len-m)
  (setq current-layer (getvar "CLAYER"))
  (setq last-before (entlast))
  (activate-comment-layer)
  (command "_.PLINE")
  (wait-for-command)

  (if (not (equal (entlast) last-before))
    (progn
      (setq obj   (vlax-ename->vla-object (entlast)))
      (setq len-m (/ (vla-get-Length obj) (float *UNITS-PER-METER*)))
      (princ (strcat "\nLength: " (rtos len-m 2 2) " m"))
    )
  )
  (setvar "CLAYER" current-layer)
)

(defun create-comment-rectangle (/ current-layer last-before obj area-m2)
  (setq current-layer (getvar "CLAYER"))
  (setq last-before (entlast))
  (activate-comment-layer)
  (command "_.RECTANGLE")
  (wait-for-command)

  (if (not (equal (entlast) last-before))
    (progn
      (setq obj     (vlax-ename->vla-object (entlast)))
      (setq area-m2 (/ (vla-get-Area obj)(* (float *UNITS-PER-METER*) (float *UNITS-PER-METER*))))
      (princ (strcat "\nArea: " (rtos area-m2 2 2) " m2"))
    )
  )
  (setvar "CLAYER" current-layer)
)

(defun create-comment-circle (/ current-layer last-before obj dia-m)
  (setq current-layer (getvar "CLAYER"))
  (setq last-before (entlast))
  (activate-comment-layer)
  (command "_.CIRCLE")
  (wait-for-command)

  (if (not (equal (entlast) last-before))
    (progn
      (setq obj   (vlax-ename->vla-object (entlast)))
      (setq dia-m (/ (* (vla-get-Radius obj) 2.0) (float *UNITS-PER-METER*)))
      (princ (strcat "\nDiameter: " (rtos dia-m 2 2) " m"))
    )
  )
  (setvar "CLAYER" current-layer)
)

(defun create-comment-text (/ current-layer text-height insert-point text)
  (setq current-layer (getvar "CLAYER"))
  (activate-comment-layer)

  (setq text-height (get-comment-text-height))

  (if (setq insert-point (getpoint "\nSpecify comment insert point: "))
    (progn
      (setq text
        (entmakex
          (list
            '(0 . "MTEXT")
            '(100 . "AcDbEntity")
            '(100 . "AcDbMText")
            '(1 . "")
            (cons 10 (trans insert-point 1 0))  ; insertion point
            (cons 11 (getvar 'UCSXDIR))         ; horizontal direction
            (cons 40 text-height)               ; text height
            (cons 210 (trans '(0 0 1) 1 0 T))   ; UCS normal
          )
        )
      )
      (command "_.MTEDIT" text)
    )
  )

  (setvar "CLAYER" current-layer)
)

(defun quick-purge ()
  (command "_.-OVERKILL" "_ALL" "" "")
  (command "_.-PURGE" "_A" "" "_N")   ; all named objects
  (command "_.-PURGE" "_R" "" "_N")   ; regapps
  (command "_.-PURGE" "_Z" "" "_N")   ; zero-length geometry
  (command "_.AUDIT" "_Y")
)

(defun erase-last-entity (/ ent)
  (setq ent (entlast))
  (if ent
    (progn
      (entdel ent)
      (princ "\nLast object deleted.")
    )
    (princ "\nNo objects found.")
  )
  (princ)
)

(defun c:CREATECOMMENTPLINE ()
  (create-comment-pline)
  (princ)
)

(defun c:CREATECOMMENTRECTANG ()
  (create-comment-rectangle)
  (princ)
)

(defun c:CREATECOMMENTCIRCLE ()
  (create-comment-circle)
  (princ)
)

(defun c:CREATECOMMENTMTEXT ()
  (create-comment-text)
  (princ)
)

(defun c:QUICKPURGE ()
  (quick-purge)
  (princ)
)

(defun c:ERASELASTENTITY ()
  (erase-last-entity)
  (princ)
)

(defun c:ROTATEWITHORTHO ()
  (run-with-ortho "._ROTATE")
  (princ)
)

(defun c:MIRRORWITHORTHO ()
  (run-with-ortho "._MIRROR")
  (princ)
)

(princ)