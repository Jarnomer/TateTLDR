(setq *iso-saved-states* nil)   ; alist of (layername . on/off-state)
(setq *iso-active*       nil)   ; T when isolate is active

(defun toggle-layer-manager (/ doc)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (if (= (getvar "LAYERMANAGERSTATE") 1)
    (vla-SendCommand doc "_.LAYERCLOSE\n")
    (vla-SendCommand doc "_.LAYER\n")
  )
)

(defun toggle-layer-lock (/ ent doc obj laytbl layname lay)
  (setq ent (select-object "Select object to toggle layer lock: "))
  (if ent
    (progn
      (setq doc     (vla-get-ActiveDocument (vlax-get-acad-object))
            obj     (vlax-ename->vla-object ent)
            laytbl  (vla-get-Layers doc)
            layname (vla-get-Layer obj)
            lay     (vla-Item laytbl layname)
      )
      (if (= (vla-get-Lock lay) :vlax-true)
        (progn
          (vla-put-Lock lay :vlax-false)
          (princ (strcat "\nLayer \"" layname "\" unlocked."))
        )
        (progn
          (vla-put-Lock lay :vlax-true)
          (princ (strcat "\nLayer \"" layname "\" locked."))
        )
      )
    )
  )
)

(defun custom-layer-freeze (/ doc layers curlayer ent layname layobj)
  (setq doc      (vla-get-ActiveDocument (vlax-get-acad-object))
        layers   (vla-get-Layers doc)
        curlayer (getvar "CLAYER")
  )

  (while (setq ent (entsel "\nSelect layer to freeze: "))
    (setq layname (cdr (assoc 8 (entget (car ent)))))

    (cond
      ((= (strcase layname) (strcase curlayer))
       (princ (strcat "\nCannot freeze current layer: " layname))
      )
      (T
       (setq layobj (vla-Item layers layname))
       (command "_.UNDO" "_Begin")
       (vla-put-Freeze layobj -1)
       (command "_.UNDO" "_End")
       (princ (strcat "\nFroze layer: " layname))
      )
    )
  )
)

(defun toggle-layer-menu (/ old-dynmode choice)
  (setq old-dynmode (getvar "DYNMODE"))
  (if (< old-dynmode 1)
    (setvar "DYNMODE" 3)
  )

  (initget "mAtch Setcurrent Delete Forcecurrent")
  (setq choice (getkword "\n[mAtch/Set/Delete/Force] <Delete>: "))

  (setvar "DYNMODE" old-dynmode)

  (if (not choice) (setq choice "Delete"))

  (cond
    ((= choice "mAtch")  (command "_.LAYMCH"))  ; match layer of picked object
    ((= choice "Set")    (command "_.LAYMCUR")) ; set current layer to picked object's layer
    ((= choice "Delete") (command "_.LAYDEL"))  ; delete a layer (default)
    ((= choice "Force")  (command "_.LAYCUR"))  ; force all selected objects to current layer
  )
)

(defun iso-layer-base (name / base len)
  (setq base (strcase name)
        len  (strlen base))
  (cond
    ((and (> len 3)
          (= (substr base (- len 2)) "TXT"))
     (setq base (substr base 1 (- len 3))))
    ((and (> len 5)
          (= (substr base (- len 4)) "HATCH"))
     (setq base (substr base 1 (- len 5))))
  )
  (while (and (> (strlen base) 0)
              (= (substr base (strlen base) 1) "-"))
    (setq base (substr base 1 (1- (strlen base))))
  )
  base
)

(defun iso-find-txt-layers (layername / base doc laytbl result lay lname)
  (setq doc    (vla-get-ActiveDocument (vlax-get-acad-object))
        base   (iso-layer-base layername)
        laytbl (vla-get-Layers doc)
        result '())
  (vlax-for lay laytbl
    (setq lname (strcase (vla-get-Name lay)))
    (if (wcmatch lname (strcat base "*TXT*"))
      (setq result (cons (vla-get-Name lay) result))
    )
  )
  result
)

(defun iso-layers-from-ss (ss / i ent lname layers)
  (setq layers '()
        i      0)
  (repeat (sslength ss)
    (setq ent   (ssname ss i)
          lname (cdr (assoc 8 (entget ent)))
          i     (1+ i))
    (if (not (member (strcase lname) (mapcar 'strcase layers)))
      (setq layers (cons lname layers))
    )
  )
  layers
)

(defun iso-restore (/ doc laytbl lay)
  (setq doc    (vla-get-ActiveDocument (vlax-get-acad-object))
        laytbl (vla-get-Layers doc))
  (foreach saved *iso-saved-states*
    (setq lay (vl-catch-all-apply 'vla-Item (list laytbl (car saved))))
    (if (not (vl-catch-all-error-p lay))
      (vl-catch-all-apply 'vla-put-LayerOn (list lay (cdr saved)))
    )
  )
  (setq *iso-active*       nil
        *iso-saved-states* nil)
)

(defun toggle-layer-isolate (/ ss picked visible doc laytbl lay lname)
  (if *iso-active*
    ;; --- UNISOLATE ---
    (progn
      (iso-restore)
      (princ "\nLayers restored.")
    )
    ;; --- ISOLATE ---
    (progn
      (setq ss (get-selection))
      (if (not ss)
        (princ "\nNothing selected.")
        (progn
          (setq picked  (iso-layers-from-ss ss))
          (setq visible (mapcar 'strcase picked))

          ;; Add TXT companion layers
          (foreach ln picked
            (foreach txt (iso-find-txt-layers ln)
              (if (not (member (strcase txt) visible))
                (setq visible (cons (strcase txt) visible))
              )
            )
          )

          ;; Add always-visible layers
          (foreach ln *ISO-ALWAYS-VISIBLE*
            (if (not (member (strcase ln) visible))
              (setq visible (cons (strcase ln) visible))
            )
          )

          (setq doc    (vla-get-ActiveDocument (vlax-get-acad-object))
                laytbl (vla-get-Layers doc)
                *iso-saved-states* '())

          ;; Save current states, turn off non-visible host layers
          (vlax-for lay laytbl
            (setq lname (vla-get-Name lay))
            (setq *iso-saved-states*
              (cons (cons lname (vla-get-LayerOn lay)) *iso-saved-states*))
            (if (and (not (member (strcase lname) visible))
                     (/= (strcase lname) (strcase (getvar "CLAYER")))
                     (not (wcmatch lname "*|*")))
              (vla-put-LayerOn lay :vlax-false)
            )
          )

          (setq *iso-active* T)
          (princ (strcat "\nIsolated " (itoa (length picked)) " layer(s), "
                         (itoa (length visible)) " visible."))
        )
      )
    )
  )
  (princ)
)

(defun c:TOGGLELAYERISOLATE ()
  (toggle-layer-isolate)
  (princ)
)

(defun c:TOGGLELAYERMANAGER ()
  (toggle-layer-manager)
  (princ)
)

(defun c:TOGGLELAYERCMDMENU ()
  (toggle-layer-menu)
  (princ)
)

(defun c:TOGGLELAYERLOCK ()
  (toggle-layer-lock)
  (princ)
)

(defun c:SINGLELAYERFREEZE ()
  (custom-layer-freeze)
  (princ)
)

(princ)
