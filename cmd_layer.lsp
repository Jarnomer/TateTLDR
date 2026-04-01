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

(defun c:TOGGLELAYERMANAGER ()
  (toggle-layer-manager)
  (princ)
)

(defun c:TOGGLELAYERLOCK ()
  (toggle-layer-lock)
  (princ)
)

(defun c:CUSTOMLAYERFREEZE ()
  (custom-layer-freeze)
  (princ)
)

(defun c:TOGGLELAYERCMDMENU ()
  (toggle-layer-menu)
  (princ)
)

(princ)
