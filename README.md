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

<h3 align="center">Top Row</h3>
 
<p align="center">
  <img src="assets/qwert_map.svg" alt="qwert mappings" width="680">
</p>
 
<h3 align="center">Home Row</h3>
 
<p align="center">
  <img src="assets/asdfg_map.svg" alt="asdfg mappings" width="680">
</p>
 
<h3 align="center">Bottom Row</h3>
 
<p align="center">
  <img src="assets/zxcvb_map.svg" alt="zxcvb mappings" width="680">
</p>

## ⌨️ Commands

<h3 align="center">Top Row</h3>
 
<p align="center">
  <img src="assets/qwert_cmd.svg" alt="qwert commands" width="680">
</p>
 
<h3 align="center">Home Row</h3>
 
<p align="center">
  <img src="assets/asdfg_cmd.svg" alt="asdfg commands" width="680">
</p>
 
<h3 align="center">Bottom Row</h3>
 
<p align="center">
  <img src="assets/zxcvb_cmd.svg" alt="zxcvb commands" width="680">
</p>
