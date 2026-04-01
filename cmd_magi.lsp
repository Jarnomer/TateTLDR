(setq *side-view-active*    nil)  ; T when side view is confirmed on
(setq *side-view-old-ortho* nil)  ; saved ORTHOMODE before activation
(setq *side-view-reactor*   nil)  ; temporary command reactor

;;; commands NOT in this list signals that MAGICLR sequence is over
(setq *sideview-known-subcmds* '("UNDO" "VIEW" "UCS" "DVIEW" "ZOOM"))

(defun sideview-on-command-ended (reactor args)
  (if (and (not *side-view-active*)
           (= (strcase (car args)) "DVIEW"))
    (progn
      (setq *side-view-active* t)
      (sideview-remove-reactor)
    )
  )
)

(defun sideview-on-command-will-start (reactor args)
  (if (and *side-view-reactor*
           (not *side-view-active*)
           (not (member (strcase (car args)) *sideview-known-subcmds*)))
    (progn
      (sideview-remove-reactor)
      (sideview-restore-ortho)
    )
  )
)

(defun sideview-remove-reactor ()
  (if *side-view-reactor*
    (progn
      (vlr-remove *side-view-reactor*)
      (setq *side-view-reactor* nil)
    )
  )
)

(defun sideview-restore-ortho ()
  (if *side-view-old-ortho*
    (setvar "ORTHOMODE" *side-view-old-ortho*)
  )
  (setq *side-view-active*    nil)
  (setq *side-view-old-ortho* nil)
)

(defun magicad-toggle-sideview (/ doc)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))

  (if (and *side-view-reactor* (not *side-view-active*))
    (progn
      (sideview-remove-reactor)
      (sideview-restore-ortho)
    )
  )

  (if (not *side-view-active*)
    (progn
      (setq *side-view-old-ortho* (getvar "ORTHOMODE"))
      (setvar "ORTHOMODE" 1)

      (setq *side-view-reactor*
        (vlr-command-reactor nil
          '((:vlr-commandEnded     . sideview-on-command-ended)
            (:vlr-commandWillStart . sideview-on-command-will-start))
        )
      )
      (vla-SendCommand doc "MAGICLR\n")
    )
    (progn
      (sideview-remove-reactor)
      (vla-SendCommand doc "MAGIUCLR\n")
      (sideview-restore-ortho)
    )
  )
  (princ)
)

(defun c:MAGITOGGLESIDEVIEW ()
  (magicad-toggle-sideview)
  (princ)
)

(defun magicad-preferences (/ drawing-type)
  (setq drawing-type (check-drawing-type))
  (cond
    ((= drawing-type "FLOORPLAN")    (command "_.MAGIEDWG"))
    ((= drawing-type "SWITCHBOARD")  (command "_.MAGIESWBSCHEMAPROPS"))
    ((= drawing-type "CIRCUIT")      (command "_.MAGICDWGSET"))
    (T (princ "\nUnknown drawing type"))
  )
)

(defun magicad-change-properties (/ drawing-type)
  (setq drawing-type (check-drawing-type))
  (cond
    ((= drawing-type "FLOORPLAN")    (command "_.MAGIECHANGE"))
    ((= drawing-type "SWITCHBOARD")  (command "_.MAGIESWBSCHEMACHANGE"))
    ((= drawing-type "CIRCUIT")      (command "_.MAGICCHANGEPROP"))
    (T (princ "\nUnknown drawing type"))
  )
)

(defun magicad-update (/ drawing-type)
  (setq drawing-type (check-drawing-type))
  (cond
    ((= drawing-type "FLOORPLAN")    (command "_.MAGIEUPDATEDWGDATA"))
    ((= drawing-type "SWITCHBOARD")  (command "_.MAGIESWBSCHEMAUPDATE"))
    ((= drawing-type "CIRCUIT")      (command "_.MAGICUPDATEREEFERENCES"))
    (T (princ "\nUnknown drawing type"))
  )
)

(defun magicad-annotate (/ drawing-type)
  (setq drawing-type (check-drawing-type))
  (cond
    ((= drawing-type "FLOORPLAN")    (command "_.MAGIEDIMTEXTDRAW"))
    ((= drawing-type "SWITCHBOARD")  (command "_.MAGIESWBSCHEMADRAWTEXT"))
    ((= drawing-type "CIRCUIT")      (command "_.MAGICSDIMTEXTDRAW"))
    (T (princ "\nUnknown drawing type"))
  )
)

(defun c:MAGIPREFERENCES ()
  (magicad-preferences)
  (princ)
)

(defun c:MAGIPROPERTIES ()
  (magicad-change-properties)
  (princ)
)

(defun c:MAGIUPDATE ()
  (magicad-update)
  (princ)
)

(defun c:MAGIANNOTATE ()
  (magicad-annotate)
  (princ)
)

(defun magicad-build-floor-ifc (/ ifc)
  (setq ifc (getstring T "Enter IFC Preset Name: "))
  (if (and ifc (/= ifc ""))
    (progn
      (command "_.QSAVE" "_.-MAGIIFC" ifc "")
      (princ "\nFinished building IFC preset: " ifc)
    )
    (princ "\nCancelled")
  )
)

(defun c:MAGIBUILDFLOORIFC ()
  (magicad-build-floor-ifc)
  (princ)
)

(princ)
