;;; ---------------------------------------------------------------------------
;;; COMMENT LAYER
;;; ---------------------------------------------------------------------------
;;; Layer used for non-plotting markup (polylines, rectangles, text notes).
;;; This layer is created automatically if it doesn't exist.

(setq *COMMENT-LAYER*       "E-KOMMENTTI")  ; layer name
(setq *COMMENT-LAYER-COLOR* "2")            ; color index (2 = yellow)

;;; Comment text height per drawing type.
;;; Floor plans use model-space scale, others use paper-space scale.

(setq *COMMENT-TEXT-HEIGHT-FLOORPLAN* 125)  ; mm in model space
(setq *COMMENT-TEXT-HEIGHT-DEFAULT*   2.5)  ; mm for circuit / switchboard / other

;;; ---------------------------------------------------------------------------
;;; LAYER ISOLATE — ALWAYS-VISIBLE LAYERS
;;; ---------------------------------------------------------------------------
;;; These layers are never frozen by the custom layer-isolate command,
;;; regardless of selection. Add any layers you always need to see.

(setq *ISO-ALWAYS-VISIBLE* '("0" "E-XREF-ARKKITEHTI"))

;;; ---------------------------------------------------------------------------
;;; DRAWING TYPE DETECTION — SENTINEL BLOCKS
;;; ---------------------------------------------------------------------------
;;; The suite auto-detects drawing type by checking which blocks exist.
;;; Each list is checked in order: first match wins.
;;;   FLOORPLAN   → MagiCAD Electrical floor plan
;;;   SWITCHBOARD → MagiCAD switchboard schematic
;;;   CIRCUIT     → MagiCAD circuit diagram

(setq *FLOOR-PLAN-BLOCKS*  '("rejlers-raami" "rejlers-raami1"))
(setq *SWITCHBOARD-BLOCKS* '("otsikkotaulu"))
(setq *CIRCUIT-BLOCKS*     '("MAGICSLABEL"))

;;; ---------------------------------------------------------------------------
;;; DRAWING UNITS
;;; ---------------------------------------------------------------------------
;;; Number of drawing units per meter. Used to convert measurements to
;;; meters / square meters for command-line reporting.
;;;   1000 = millimeters (most MEP floor plans)
;;;   100  = centimeters
;;;   1    = meters

(setq *UNITS-PER-METER* 1000)

;;; ---------------------------------------------------------------------------
;;; XREF DISCIPLINE LAYERS
;;; ---------------------------------------------------------------------------
;;; When attaching an external reference, it is placed on a discipline-
;;; specific layer. The layer is created automatically if it doesn't exist.

(setq *XREF-LAYER-MAP* '(("ARCH" . "E-XREF-ARKKITEHTI")
                          ("HVAC" . "E-XREF-LVI")
                          ("ELEC" . "E-XREF-VAHVAVIRTA")
                          ("TELE" . "E-XREF-TELE")))

(princ)