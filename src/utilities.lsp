;;; Initialize Visual LISP COM support (required for VLA calls)
(vl-load-com)

;;; ---------------------------------------------------------------------------
;;; DRAWING TYPE DETECTION
;;; ---------------------------------------------------------------------------
;;; Checks which sentinel blocks exist to determine the current drawing type.
;;; Returns one of: "FLOORPLAN", "SWITCHBOARD", "CIRCUIT", "UNKNOWN"
;;; Requires *FLOOR-PLAN-BLOCKS*, *SWITCHBOARD-BLOCKS*, *CIRCUIT-BLOCKS*
;;; from globals.lsp.

(defun check-any-block-exists (block-list)
  (vl-some '(lambda (bname) (tblsearch "BLOCK" bname)) block-list)
)

(defun check-drawing-type ()
  (cond
    ((check-any-block-exists *FLOOR-PLAN-BLOCKS*)  "FLOORPLAN")
    ((check-any-block-exists *SWITCHBOARD-BLOCKS*) "SWITCHBOARD")
    ((check-any-block-exists *CIRCUIT-BLOCKS*)     "CIRCUIT")
    (T "UNKNOWN")
  )
)

;;; ---------------------------------------------------------------------------
;;; SELECTION HELPERS
;;; ---------------------------------------------------------------------------

;;; Prompt user to pick a single entity. Repeats until valid or ESC.
;;; Returns: entity name (ename)

(defun select-object (prompt / ent)
  (while (not ent)
    (setq ent (car (entsel (strcat "\n" prompt))))
    (if (not ent)
      (princ "\nNothing selected.")
    )
  )
  ent
)

(defun select-xref (/ ent vla-obj)
  (while
    (or
      (not (setq ent (car (entsel "\nSelect an XREF: "))))
      (not (setq vla-obj (vlax-ename->vla-object ent)))
      (not (vlax-property-available-p vla-obj 'Path))
    )
    (princ "\nSelection is not an XREF.")
  )
  (vlax-get vla-obj 'Name)
)

;;; Returns the implied (pre-selected) selection set, or prompts for one.
;;; Returns: selection set or nil

(defun get-selection (/ ss)
  (setq ss (ssget "_I"))
  (if (not ss)
    (setq ss (ssget))
  )
  ss
)

;;; ---------------------------------------------------------------------------
;;; COMMAND FLOW CONTROL
;;; ---------------------------------------------------------------------------

;;; Waits until the currently active command finishes (CMDACTIVE = 0).
;;; Use after launching a command that requires user interaction.

(defun wait-for-command ()
  (while (> (getvar "CMDACTIVE") 0)
    (command pause)
  )
)

;;; ---------------------------------------------------------------------------
;;; GUARDED COMMAND EXECUTION
;;; ---------------------------------------------------------------------------
;;; Runs AutoCAD commands with temporary system variable overrides.
;;; Saves current values, applies overrides, runs the command, and
;;; restores everything — including on ESC / cancel / error.
;;;
;;; This is the foundation for ortho enforcement, UCS preservation,
;;; layer switching, and any future state-guarded commands.
;;;
;;; overrides: association list of (SYSVAR-NAME . value) pairs
;;;            e.g. '(("ORTHOMODE" . 1) ("DYNMODE" . 0))

;;; Run a command that takes a selection set (ROTATE, MIRROR, MOVE, etc.).
;;; Gets the implied selection or prompts the user, then passes it to
;;; the command. All sysvars in overrides are saved and restored.

(defun run-cmd-with-overrides (overrides cmd / saved old-error ss)
  ;; Capture implied (PICKFIRST) selection before setvar clears it
  (setq ss (ssget "_I"))

  (setq saved (mapcar '(lambda (ov) (cons (car ov) (getvar (car ov)))) overrides))

  (setq old-error *error*)
  (defun *error* (msg)
    (foreach sv saved (setvar (car sv) (cdr sv)))
    (setq *error* old-error)
    (if (not (wcmatch (strcase msg) "*BREAK,*CANCEL*,*EXIT*"))
      (princ (strcat "\nError: " msg))
    )
    (princ)
  )

  (foreach ov overrides (setvar (car ov) (cdr ov)))

  ;; Clear PICKFIRST so the command won't double-consume it
  (if ss (sssetfirst nil nil))

  ;; If no pre-selection, prompt interactively (supports all selection modes)
  (if (not ss) (setq ss (ssget)))

  (if ss
    (progn
      (command cmd ss "")
      (wait-for-command)
    )
    (princ "\nNothing selected.")
  )

  (foreach sv saved (setvar (car sv) (cdr sv)))
  (setq *error* old-error)
  (princ)
)

;;; Run a command that does NOT take a selection set (PLINE, CIRCLE, etc.)
;;; or a MagiCAD command that handles its own interaction.
;;; Just applies overrides, launches the command, waits, and restores.

(defun run-simple-with-overrides (overrides cmd / saved old-error)
  (setq saved (mapcar '(lambda (ov) (cons (car ov) (getvar (car ov)))) overrides))

  (setq old-error *error*)
  (defun *error* (msg)
    (foreach sv saved (setvar (car sv) (cdr sv)))
    (setq *error* old-error)
    (if (not (wcmatch (strcase msg) "*BREAK,*CANCEL*,*EXIT*"))
      (princ (strcat "\nError: " msg))
    )
    (princ)
  )

  (foreach ov overrides (setvar (car ov) (cdr ov)))

  (command cmd)
  (wait-for-command)

  (foreach sv saved (setvar (car sv) (cdr sv)))
  (setq *error* old-error)
  (princ)
)

;;; ---------------------------------------------------------------------------
;;; CONVENIENCE WRAPPERS
;;; ---------------------------------------------------------------------------

;;; Run a selection-based command with ortho forced ON.
(defun run-with-ortho (cmd)
  (run-cmd-with-overrides '(("ORTHOMODE" . 1)) cmd)
)

;;; Run a selection-based command with ortho forced OFF.
(defun run-without-ortho (cmd)
  (run-cmd-with-overrides '(("ORTHOMODE" . 0)) cmd)
)

;;; ---------------------------------------------------------------------------
;;; UCS GUARD
;;; ---------------------------------------------------------------------------
;;; Saves the current UCS, switches to World UCS, runs a command,
;;; then restores the previous UCS. Useful for xref attachment,
;;; block insertion, and any operation that must happen in WCS.

(defun run-with-world-ucs (cmd / old-error)
  (setq old-error *error*)
  (defun *error* (msg)
    (command "._UCS" "_P")
    (setq *error* old-error)
    (if (not (wcmatch (strcase msg) "*BREAK,*CANCEL*,*EXIT*"))
      (princ (strcat "\nError: " msg))
    )
    (princ)
  )

  (command "._UCS" "_W")
  (command cmd)
  (wait-for-command)
  (command "._UCS" "_P")

  (setq *error* old-error)
  (princ)
)

;;; ---------------------------------------------------------------------------
;;; LAYER GUARD
;;; ---------------------------------------------------------------------------
;;; Saves the current layer, switches to a target layer, runs a command,
;;; then restores the previous layer. Creates the target layer if it
;;; doesn't exist.

(defun run-on-layer (target-layer cmd / current-layer old-error)
  (setq current-layer (getvar "CLAYER"))

  (if (not (tblsearch "LAYER" target-layer))
    (command "._-LAYER" "_M" target-layer "")
  )
  (setvar "CLAYER" target-layer)

  (setq old-error *error*)
  (defun *error* (msg)
    (setvar "CLAYER" current-layer)
    (setq *error* old-error)
    (if (not (wcmatch (strcase msg) "*BREAK,*CANCEL*,*EXIT*"))
      (princ (strcat "\nError: " msg))
    )
    (princ)
  )

  (command cmd)
  (wait-for-command)

  (setvar "CLAYER" current-layer)
  (setq *error* old-error)
  (princ)
)

;;; ---------------------------------------------------------------------------
;;; COMMENT LAYER HELPERS
;;; ---------------------------------------------------------------------------
;;; Creates the comment layer if it doesn't exist, then sets it current.
;;; Uses *COMMENT-LAYER* and *COMMENT-LAYER-COLOR* from globals.lsp.

(defun activate-comment-layer ()
  (if (not (tblsearch "LAYER" *COMMENT-LAYER*))
    (command "_.LAYER"
             "_MAKE" *COMMENT-LAYER*
             "_COLOR" *COMMENT-LAYER-COLOR* ""
             "_PLOT" "_NO" ""
             "")
    (setvar "CLAYER" *COMMENT-LAYER*)
  )
)

;;; Runs an AutoCAD command on the comment layer, then restores the
;;; previous current layer.

(defun run-command-as-comment (cmd / current-layer)
  (setq current-layer (getvar "CLAYER"))
  (activate-comment-layer)
  (command cmd)
  (wait-for-command)
  (setvar "CLAYER" current-layer)
  (princ)
)

;;; Calls a LISP function on the comment layer, then restores the
;;; previous current layer.

(defun run-function-as-comment (func / current-layer)
  (setq current-layer (getvar "CLAYER"))
  (activate-comment-layer)
  (eval (list func))
  (setvar "CLAYER" current-layer)
  (princ)
)

;;; Returns the appropriate comment text height for the current drawing type.
;;; Uses *COMMENT-TEXT-HEIGHT-FLOORPLAN* and *COMMENT-TEXT-HEIGHT-DEFAULT*
;;; from globals.lsp.

(defun get-comment-text-height ()
  (if (equal (check-drawing-type) "FLOORPLAN")
    *COMMENT-TEXT-HEIGHT-FLOORPLAN*
    *COMMENT-TEXT-HEIGHT-DEFAULT*
  )
)

;;; ---------------------------------------------------------------------------
;;; SPACE SWITCHING
;;; ---------------------------------------------------------------------------

;;; Switch to Model Space if currently in Paper Space.
(defun change-to-model-space ()
  (if (= (getvar 'CVPORT) 1)
    (vla-put-MSpace
      (vla-get-ActiveDocument (vlax-get-acad-object))
      :vlax-true)
    (princ "\nAlready in Model Space.")
  )
  (princ)
)

;;; Switch to Paper Space if currently in Model Space.
(defun change-to-paper-space ()
  (if (= (getvar 'CVPORT) 2)
    (vla-put-MSpace
      (vla-get-ActiveDocument (vlax-get-acad-object))
      :vlax-false)
    (princ "\nAlready in Paper Space.")
  )
  (princ)
)

;;; ============================================================================
;;; END OF UTILITIES.LSP
;;; ============================================================================

(princ)
