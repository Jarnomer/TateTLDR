<h1 align="center">
  <img src="assets/banner.png" alt="acad-lisp" width="400">
</h1>

<p align="center">
	<b><i>MagiCAD command shortcut suite for electrical design workflow.</i></b><br>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-AutoCAD-blue?style=for-the-badge" alt="platform">
  <img src="https://img.shields.io/badge/Plugin-MagiCAD-orange?style=for-the-badge" alt="plugin">
  <img src="https://img.shields.io/github/languages/top/Jarnomer/tatetldr?style=for-the-badge&logo=autohotkey&label=%20&labelColor=gray&color=lightblue" alt="GitHub top language">
  <img src="https://img.shields.io/github/last-commit/Jarnomer/tatetldr/main?style=for-the-badge&color=red" alt="GitHub last commit">
</p>

<div align="center">

## Table of Contents
[📝 General](#-general)
[🛠️ Installation](#️-installation)
[🎹 Mappings](#-mappings)
[⌨️ Commands](#️-commands)

</div>

## 📝 General

Custom AutoLISP command suite designed for daily drafting with MagiCAD. Current focus is in electrical design work but other disciplines are planned in future. All frequently used operations are mapped to short keyboard shortcuts organized by keyboard rows, eliminating the need for menus, ribbons, or toolbars.

## 🛠️ Installation

Download the repository as a `.zip` archive from GitHub and extract the `acaddoc.lsp`, `acad.pgp` and `src` folder into a dedicated directory.

Open AutoCAD and navigate to `Options` → `Files` tab. Expand **Support File Search Path** and add your folder to the **top** of the list. This ensures `acaddoc.lsp` and `acad.pgp` are loaded before any defaults.

In the same `Files` tab, expand **Trusted Locations** and add the same folder path. This prevents security prompts when loading the LISP files.

Restart AutoCAD. On first launch you may be prompted to allow the LISP files to load — select **Always Load** to avoid future prompts.

> [!NOTE]
> The `acaddoc.lsp` file runs automatically on every drawing open, loading all modules. The `acad.pgp` file registers the keyboard shortcuts on application launch. Both require the folder to be in **Support File Search Path** to take effect.

> [!TIP]
> Edit `globals.lsp` to configure variables used by the suite like **layer names** and **unit scaling**.

## 🎹 Mappings

Shortcuts are organized across three keyboard rows, each featuring five keys. Primary key triggers common action, with repeated or modified keys accessing related commands.

<h3 align="center">💬 Top Row</h3>
 
<p align="center">
  <img src="assets/qwert.svg" alt="qwert commands" width="680">
</p>
 
<h3 align="center">🚀 Home Row</h3>
 
<p align="center">
  <img src="assets/asdfg.svg" alt="asdfg commands" width="680">
</p>
 
<h3 align="center">🛠️ Bottom Row</h3>
 
<p align="center">
  <img src="assets/zxcvb.svg" alt="zxcvb commands" width="680">
</p>

## ⌨️ Commands

### 💬 Top Row

`Q` - **Side View** : Enter or exit MagiCAD side view, enforces ortho on.
`QG` - **Quick Purge** : Run overkill, purge all unused blocks, layers and regapps.

---

`W` - **Layer Isolate** : Toggle layer isolation on selected objects' layers.
`WW` - **Layer Manager** : Open or close the layer manager palette.
`WT` - **Layer Menu** : Dynamic menu for match, set current, delete or force layer.
`WE` - **Layer Freeze** : Freeze the layer of a picked object. Sets undo point on each freeze.
`WWE` - **Layer Lock** : Toggle lock on the layer of a picked object.

---

`E` - **IFC Preset** : Save drawing and build IFC with a named preset.
`EE` - **IFC Export** : Open MagiCAD IFC export dialog.
`ET` - **Storey** : Open MagiCAD IFC storey management.
`ER` - **Voids** : Open MagiCAD provisions for openings.
`EER` - **Report** : Open MagiCAD voids report (XSR) management.

---

`R` - **Annotate** : Draw dimension text for the current drawing type.
`RT` - **Revision Mark** : Place a MagiCAD revision mark.
`RRT` - **Revision Cloud** : Place a MagiCAD revision cloud.
`RC` - **Cable Mark** : Place a MagiCAD cable mark.
`RA` - **Comment Pline** : Draw a polyline on the comment layer, reports length.
`RS` - **Comment Text** : Place multiline text on the comment layer.
`RD` - **Comment Rect** : Draw a rectangle on the comment layer, reports area.
`RF` - **Comment Circle** : Draw a circle on the comment layer, reports diameter.

---

`T` - **Properties** : Open MagiCAD change properties for the current drawing type.
`TT` - **Update** : Update drawing data for the current drawing type.
`TG` - **MCU Clean** : Run MagiCAD cleanup utility.
`TR` - **Preferences** : Open MagiCAD drawing preferences for the current drawing type.
`TTR` - **Project** : Open MagiCAD project settings.

### 🚀 Home Row

`A` - **Mirror** : Mirror selected objects with ortho enforced on. Builtin feature to copy mirrored objects.

**Circuit Diagram**

`AS` - **Conductor** : Draw a MagiCAD circuit line.
`AAS` - **Connect** : Place a MagiCAD conductor connection.
`AD` - **Node** : Place an exiting MagiCAD terminal node.
`AF` - **Contact** : Place an exiting MagiCAD relay contact.
`AG` - **Switch** : Place an exiting MagiCAD panel switch.
`AR` - **Annotate** : Annotate an exiting MagiCAD relay.
`AE` - **Device Area** : Define a MagiCAD device area.
`AAE` - **Outside Area** : Define a MagiCAD outside switchboard area.
`AT` - **Page** : Open MagiCAD circuit page management.
`AAT` - **Layout** : Open MagiCAD circuit layout management.
`AX` - **New Part** : Open the MagiCAD component menu.
`AC` - **Common Part** : Place a MagiCAD common part.

---

`S` - **Rotate** : Rotate selected objects with ortho enforced on. Builtin feature to copy rotated objects.

**Switchboard Schematic**

`SS` - **Edit** : Edit a switchboard schema row.
`SD` - **Copy** : Copy a switchboard schema row.
`SF` - **Move** : Move a switchboard schema row.
`SG` - **Delete** : Delete a switchboard schema row.
`SR` - **Renumber** : Renumber switchboard schema rows.
`SA` - **Insert** : Insert a switchboard schema row.
`SSA` - **Insert (plan)** : Insert a switchboard schema group.
`ST` - **Symbol** : Place a switchboard schema row symbol.
`SST` - **Detail** : Place a switchboard schema detail symbol (single).

---

`D` - **Copy** : Copy selected objects.
`DF` - **Clip Copy (origin)** : Copy selection to clipboard at origin point (0,0,0).
`DDF` - **Clip Copy (select)** : Copy selection to clipboard at picked base point.
`DG` - **Paste (origin)** : Paste from clipboard at origin point (0,0,0).
`DDG` - **Paste (select)** : Paste from clipboard at picked insertion point.

---

`F` - **Move** : Move selected objects.
`FF` - **Z Move** : Move selection by Z displacement value (0,0,`value`).
`FG` - **Move Annotate** : Move MagiCAD annotation text with ortho off.
`FFG` - **Move Attribute** : Move MagiCAD attribute text with ortho off.

---

`G` - **Erase** : Erase selected objects.
`GG` - **Erase Last** : Erase the last created object.
`GB` - **Clear Garbage** : Run MagiCAD garbage layer clear.
`GR` - **Clear Comments** : Erase objects from comment layer in the current view.

### 🛠️ Bottom Row

`Z` - *Reserved*

---

`X` - **Reload** : Reload a picked external reference.
`XX` - **Manage** : Open or close the external references palette.
`XZ` - **Unload** : Unload a picked external reference.
`XC` - **Open** : Open a picked external reference for editing.

---

`C` - **Stretch** : Stretch a MagiCAD cable tray.
`CC` - **Break** : Break a MagiCAD cable tray or conduit.
`CX` - **Cross** : Create a MagiCAD cable tray crossing.
`CT` - **Width** : Edit MagiCAD cable tray width.
`CV` - **Hide** : Hide MagiCAD cables.
`CCV` - **Unhide** : Unhide MagiCAD cables.

**Draw New**

`CA` - **Tray** : Draw a MagiCAD cable tray.
`CS` - **Conduit** : Draw a MagiCAD conduit.
`CD` - **Busbar** : Draw a MagiCAD busbar.
`CF` - **Cable E** : Draw a MagiCAD electrical cable.
`CG` - **Cable T** : Draw a MagiCAD telecom cable.

---

`V` - **Elevation** : Set a MagiCAD device symbol elevation.
`VV` - **Move** : Move a MagiCAD device symbol, especially 3D symbol.

**Symbol Switchboard**

`VB` - **Properties** : Open MagiCAD switchboard properties dialog.
`VVB` - **Update** : Update switchboard schema from plan.
`VC` - **Border** : Place a MagiCAD switchboard border.
`VVC` - **Area** : Define a MagiCAD switchboard area.
`VT` - **Check** : Run MagiCAD switchboard check dialog.
`VVT` - **Manage** : Open MagiCAD switchboard management.

**Symbol New**

`VA` - **Luminaire** : Place a MagiCAD luminaire.
`VS` - **Socket E** : Place a MagiCAD socket.
`VD` - **Switch** : Place a MagiCAD switch device.
`VF` - **Equipment** : Place a MagiCAD equipment device.
`VG` - **Socket T** : Place a MagiCAD telecom socket.

---

`B` - *Reserved*
