(defun apply-system-settings ()

  ;; -- Saving & File Behavior ------------------------------------------------
  (setvar "SAVETIME"        10)   ; autosave interval (minutes)
  (setvar "REMEMBERFOLDERS" 1)    ; file dialogs remember last-used path
  (setvar "XLOADCTL"        2)    ; demand-load xrefs via copy
  (setvar "AUDITCTL"        0)    ; no audit report file

  ;; -- UI: Bars, Panels & Notifications --------------------------------------
  (setvar "MENUBAR"           0)  ; hide menu bar
  (setvar "STARTMODE"         0)  ; disable Start tab
  (setvar "STATUSBAR"         1)  ; show status bar
  (setvar "TRAYICONS"         0)  ; no tray icons
  (setvar "TRAYNOTIFY"        0)  ; no tray notifications
  (setvar "SSMAUTOOPEN"       0)  ; don't auto-open Sheet Set Manager
  (setvar "NAVBARDISPLAY"     0)  ; hide navigation bar
  (setvar "GALLERYVIEW"       0)  ; list view in ribbon dropdowns
  (setvar "ANNOMONITOR"       0)  ; no annotation monitor badges
  (setvar "LAYERNOTIFY"       0)  ; no unreconciled-layer popups
  (setvar "LAYEREVALCTL"      0)  ; no new-layer evaluation

  ;; -- UI: Tooltips, Previews & Effects --------------------------------------
  (setvar "ROLLOVERTIPS"      0)  ; no rollover tooltips
  (setvar "TOOLTIPS"          0)  ; no ribbon/toolbar tooltips
  (setvar "FILETABPREVIEW"    0)  ; layout list instead of thumbnail
  (setvar "FILETABTHUMBHOVER" 0)  ; no preview on file tab hover
  (setvar "SELECTIONEFFECT"   0)  ; dashed-line selection highlight
  (setvar "SELECTIONPREVIEW"  1)  ; hover-preview highlighting
  (setvar "PREVIEWFILTER"     2)  ; exclude xrefs from preview
  (setvar "QPMODE"            0)  ; no Quick Properties palette

  ;; -- UI: Cursor & Visual ---------------------------------------------------
  (setvar "CURSORSIZE"   100)     ; full-screen crosshair
  (setvar "PICKBOX"      6)       ; selection target box size
  (setvar "APBOX"        1)       ; show autosnap aperture box
  (setvar "APERTURE"     13)      ; snap target size
  (setvar "COLORTHEME"   0)       ; dark theme
  (setvar "FIELDDISPLAY" 0)       ; hide grey field background
  (setvar "HIGHLIGHT"    1)       ; selection highlighting on

  ;; -- Proxy Objects ---------------------------------------------------------
  (setvar "PROXYSHOW"   1)        ; display proxy graphics
  (setvar "PROXYNOTICE" 0)        ; suppress proxy warnings

  ;; -- Performance -----------------------------------------------------------
  (setvar "WHIPTHREAD"         3) ; multi-threaded regen/redraw
  (setvar "REGENMODE"          0) ; no automatic regen
  (setvar "LAYOUTREGENCTL"     2) ; cache model + paper space
  (setvar "INDEXCTL"           3) ; spatial + layer xref indexing
  (setvar "HPQUICKPREVIEW"     0) ; no hatch quick preview
  (setvar "GRIPOBJLIMIT"      50) ; suppress grips above 50 objects
  (setvar "INTELLIGENTUPDATE"  0) ; force full graphics refresh
  (setvar "VTENABLE"           0) ; no smooth view transitions
  (setvar "LINESMOOTHING"      0) ; no anti-aliased lines
  (setvar "THUMBSIZE"          1) ; smallest thumbnail cache
  (setvar "SELECTIONOFFSCREEN" 2) ; off-screen selection enabled

  ;; -- Editing Behavior ------------------------------------------------------
  (setvar "EXPERT"        4)      ; suppress UCS/SAVE/BLOCK/LAYER prompts
  (setvar "PEDITACCEPT"   1)      ; auto-convert to polyline in PEDIT
  (setvar "COPYMODE"      1)      ; single-copy mode
  (setvar "DYNMODE"       0)      ; dynamic input off
  (setvar "TEMPOVERRIDES" 1)      ; shift-key overrides (ortho etc.)
  (setvar "CMDECHO"       1)      ; echo command prompts
  (setvar "TEXTALLCAPS"   1)      ; auto-capitalize text
  (setvar "ZOOMFACTOR"    75)     ; scroll-zoom sensitivity

  ;; -- Xref & Layer Appearance -----------------------------------------------
  (setvar "LAYLOCKFADECTL"     60) ; locked-layer fade
  (setvar "XDWGFADECTL"        60) ; xref dimming
  (setvar "OBJECTISOLATIONMODE" 0) ; isolation doesn't persist

  ;; -- Plotting & Output -----------------------------------------------------
  (setvar "PAPERUPDATE"    0)     ; no paper-size mismatch dialog
  (setvar "AUTODWFPUBLISH" 0)     ; no auto DWF publish
  (setvar "LOGFILEMODE"    0)     ; no command log file
)

(defun apply-toolbar-layout ()
  (command "._-toolbar" "all" "hide")             ; First in list is rightmost
  (command "._-toolbar" "ucs_ii"     "top" "")    ; UCS dropdown
  (command "._-toolbar" "find_text"  "top" "")    ; find text (AutoCAD only)
  (command "._-toolbar" "properties" "top" "")    ; object properties
  (command "._-toolbar" "layers"     "top" "")    ; layer manager
)

(defun toggle-clean-screen ()
  (setvar "MENUBAR" 0)
  (command "_.NAVBAR" "OFF")

  (if (= (getvar "RIBBONSTATE") 1)
    (progn
      (command "_.RIBBONCLOSE")
      (command "_.NAVVCUBE" "OFF")
      (command "_.UCSICON"  "OFF")
    )
    (progn
      (command "_.RIBBON")
      (command "_.NAVVCUBE" "ON")
      (command "_.UCSICON"  "ON")
    )
  )
)

(defun c:STARTSESSION ()
  (toggle-clean-screen)
  (apply-system-settings)
  (apply-toolbar-layout)
  (command "._CLOSE" "YES") ; close drawing1.dwg
  (princ)
)

(defun c:CLEANSCREEN ()
  (toggle-clean-screen)
  (princ)
)

(princ)
