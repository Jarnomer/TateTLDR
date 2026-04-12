(defun attach-xref-by-discipline (/ current-layer old-dynmode old-error
                                    choice disc-layer filepath)
  (setq current-layer (getvar "CLAYER"))
  (setq old-dynmode   (getvar "DYNMODE"))

  (setq old-error *error*)
  (defun *error* (msg)
    (command "._UCS" "_P")
    (setvar "CLAYER"  current-layer)
    (setvar "DYNMODE" old-dynmode)
    (setq *error* old-error)
    (if (not (wcmatch (strcase msg) "*BREAK,*CANCEL*,*EXIT*"))
      (princ (strcat "\nError: " msg))
    )
    (princ)
  )

  ;; --- Discipline selection via dynamic input ---
  (if (< old-dynmode 1) (setvar "DYNMODE" 3))

  (initget "Arch Hvac Elec Tele")
  (setq choice (getkword "\n[Arch/Hvac/Elec/Tele] <Arch>: "))

  (setvar "DYNMODE" old-dynmode)

  (if (not choice) (setq choice "Arch"))
  (setq disc-layer (cdr (assoc (strcase choice) *XREF-LAYER-MAP*)))

  (cond
    ;; Bail out if discipline has no matching layer
    ((not disc-layer)
     (princ (strcat "\nNo layer mapped for discipline: " choice))
    )

    ;; Bail out if file dialog cancelled
    ((not (setq filepath (getfiled "Select XREF Drawing" "" "dwg" 0)))
     (princ "\nCancelled.")
    )

    ;; --- Attach xref ---
    (T
     (if (not (tblsearch "LAYER" disc-layer))
       (command "._-LAYER" "_M" disc-layer "")
       (setvar "CLAYER" disc-layer)
     )

     (command "._UCS" "_W")
     (command "._-XREF" "_Attach" filepath)
     (wait-for-command)
     (command "._UCS" "_P")

     (setvar "CLAYER" current-layer)
    )
  )

  (setq *error* old-error)
  (princ)
)

(defun c:XREFATTACH ()
  (attach-xref-by-discipline)
  (princ)
)

(defun delete-selected-layers (/ ss i ent lname layers doc laytbl lay curlayer objs obj)
  (setq ss (get-selection))
  (if (not ss)
    (progn (princ "\nNothing selected.") (princ))
    (progn
      ;; Build unique layer list
      (setq layers '() i 0)
      (repeat (sslength ss)
        (setq lname (cdr (assoc 8 (entget (ssname ss i))))
              i     (1+ i))
        (if (not (member (strcase lname) (mapcar 'strcase layers)))
          (setq layers (cons lname layers))
        )
      )

      ;; Guard against deleting current layer
      (setq curlayer (getvar "CLAYER"))
      (if (member (strcase curlayer) (mapcar 'strcase layers))
        (progn
          (princ (strcat "\nSkipping current layer: " curlayer))
          (setq layers (vl-remove-if
            '(lambda (ln) (= (strcase ln) (strcase curlayer)))
            layers))
        )
      )

      (if (not layers)
        (princ "\nNo layers to delete.")
        (progn
          (setq doc    (vla-get-ActiveDocument (vlax-get-acad-object))
                laytbl (vla-get-Layers doc))

          (foreach ln layers
            ;; Erase all objects on this layer
            (setq objs (ssget "_X" (list (cons 8 ln))))
            (if objs
              (progn
                (setq i 0)
                (repeat (sslength objs)
                  (entdel (ssname objs i))
                  (setq i (1+ i))
                )
              )
            )

            ;; Delete the layer
            (setq lay (vl-catch-all-apply 'vla-Item (list laytbl ln)))
            (if (not (vl-catch-all-error-p lay))
              (progn
                (vl-catch-all-apply 'vla-Delete (list lay))
                (princ (strcat "\nDeleted layer: " ln))
              )
            )
          )
        )
      )
    )
  )
  (princ)
)

(defun c:DELETESELECTEDLAYERS ()
  (delete-selected-layers)
  (princ)
)
