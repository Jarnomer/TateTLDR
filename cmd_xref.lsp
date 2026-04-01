(defun toggle-xref-manager (/ doc)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (if (= (getvar "EXTERNALREFERENCESSTATE") 1)
    (vla-SendCommand doc "_.EXTERNALREFERENCESCLOSE\n")
    (vla-SendCommand doc "_.EXTERNALREFERENCES\n")
  )
)

(defun reload-selected-xref (/ xref-name doc blk-obj result)
  (setq xref-name (select-xref))
  (if xref-name
    (progn
      (setq doc     (vla-get-ActiveDocument (vlax-get-acad-object)))
      (setq blk-obj (vla-item (vla-get-Blocks doc) xref-name))
      (setq result  (vl-catch-all-apply 'vla-reload (list blk-obj)))
      (if (vl-catch-all-error-p result)
        (princ (strcat "\nFailed to reload XREF: " xref-name))
        (princ (strcat "\nReloaded XREF: " xref-name))
      )
    )
  )
)

(defun unload-selected-xref (/ xref-name doc blk-obj result)
  (setq xref-name (select-xref))
  (if xref-name
    (progn
      (setq doc     (vla-get-ActiveDocument (vlax-get-acad-object)))
      (setq blk-obj (vla-item (vla-get-Blocks doc) xref-name))
      (setq result  (vl-catch-all-apply 'vla-unload (list blk-obj)))
      (if (vl-catch-all-error-p result)
        (princ (strcat "\nFailed to unload XREF: " xref-name))
        (princ (strcat "\nUnloaded XREF: " xref-name))
      )
    )
  )
)

(defun c:TOGGLEXREFMANAGER ()
  (toggle-xref-manager)
  (princ)
)

(defun c:RELOADXREF ()
  (reload-selected-xref)
  (princ)
)

(defun c:UNLOADXREF ()
  (unload-selected-xref)
  (princ)
)

(princ)