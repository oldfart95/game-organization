# BIOS Organization Tools

This collection of PowerShell scripts helps you organize BIOS files for RetroBar emulation from a source collection (LibretroBIOS) to the correct target folders in the RetroBar BIOS structure.

## Scripts Overview

1. **organize_bios.ps1** - Initial script that catalogs files from both source and destination directories
2. **analyze_bios_files.ps1** - Analyzes source files and reports where they should go
3. **move_bios_files.ps1** - Copies BIOS files to their correct destinations
4. **update_bios_mapping.ps1** - Interactive tool to manage and expand BIOS file mappings

## Getting Started

### First Time Setup

1. Run `organize_bios.ps1` first to create the working directory and catalog existing files:

```powershell
.\organize_bios.ps1
```

2. Next, run `analyze_bios_files.ps1` to see a breakdown of BIOS files and where they would be placed:

```powershell
.\analyze_bios_files.ps1
```

3. Review the generated reports in the `bios_organization` folder

4. If needed, use `update_bios_mapping.ps1` to add additional BIOS file patterns:

```powershell
.\update_bios_mapping.ps1
```

5. Finally, run `move_bios_files.ps1` to actually copy the files to their destinations:

```powershell
.\move_bios_files.ps1
```

## Understanding the BIOS Mapping

The scripts use a mapping table to determine where each BIOS file should go. The default mapping covers popular systems like:

- 3DO
- Atari systems (5200, 7800, Lynx)
- Dreamcast
- Game Boy Advance
- Neo Geo
- Nintendo DS
- PlayStation (PS1, PS2, PSP)
- Sega CD/Saturn
- PC Engine
- And more

## Adding Custom Mappings

To add custom mappings for BIOS files not recognized by default:

1. Run `update_bios_mapping.ps1`
2. Choose option 1 to add a new mapping
3. Enter the filename pattern (e.g., "scph1001.bin") and system folder (e.g., "psx")

Or directly edit the file `bios_organization\expanded_bios_mapping.ps1`

## System Folders Reference

The scripts use the standard RetroBar BIOS folder structure. Common system folder names include:

- 3do
- atari5200
- atari7800
- dreamcast
- gba
- lynx
- neogeo
- nds
- nes
- pcengine
- ps2
- psp
- psx
- saturn
- segacd
- snes

For a complete list, run `update_bios_mapping.ps1` and select option 2.

## Generated Reports

The scripts generate several reports in the `bios_organization` folder:

- `libretro_bios_files.csv` - Catalog of files in the source directory
- `retrobat_bios_files.csv` - Catalog of files in the target directory
- `bios_organization_report.txt` - Analysis of which files map to which systems
- `bios_movement_log.txt` - Log of file copy operations

## BIOS Files and Emulator Compatibility

Different emulators have specific BIOS requirements. Here's a breakdown of key systems and their BIOS needs:

### Sony PlayStation
- **Required BIOS**: SCPH BIOS files (scph1001.bin, scph5500.bin, scph5501.bin, scph5502.bin)
- **Emulators**: Beetle PSX, PCSX ReARMed, DuckStation
- **Regional Variants**: 
  - SCPH-1000/1001/1002 (v1.0, Original Japanese/US/European)
  - SCPH-5500/5501/5502 (v3.0, Japanese/US/European)
  - SCPH-7000/7001/7002 (v4.0, Japanese/US/European)
- **Notes**: Some emulators like PCSX ReARMed can work without BIOS but with reduced compatibility. The PSXONPSP660.BIN is optimized for performance.
- **PocketStation**: Optional "pocketstation.bin" needed for PocketStation emulation.

### Sega CD / Mega CD
- **Required BIOS**: Regional BIOS files (bios_CD_U.bin, bios_CD_E.bin, bios_CD_J.bin)
- **Emulators**: Genesis Plus GX, PicoDrive
- **Notes**: All three regional variants (US, Europe, Japan) are needed for complete compatibility.

### Nintendo DS
- **Required BIOS**: bios7.bin, bios9.bin, firmware.bin
- **Emulators**: DeSmuME, melonDS
- **Notes**: melonDS requires these files for accurate emulation, while DeSmuME can run many games without them.

### PC Engine CD / TurboGrafx-CD
- **Required BIOS**: syscard3.pce (recommended), or earlier versions
- **Emulators**: Beetle PCE Fast, Beetle PCE
- **Regional Variants**: 
  - syscard1.pce (v1.0)
  - syscard2.pce (v2.0)
  - syscard3.pce (v3.0, most compatible)
  - Games from different regions may require specific BIOS versions.

### Sega Saturn
- **Required BIOS**: saturn_bios.bin or regional variants
- **Emulators**: Beetle Saturn, Kronos
- **Notes**: Different games may perform better with specific regional BIOS files.

### 3DO
- **Required BIOS**: panafz10.bin (recommended) or other variants
- **Emulators**: Opera
- **Notes**: Different models have different BIOS files (Panasonic, Goldstar, Sanyo).

### Arcade Systems (MAME, FBNeo)
- **Required BIOS**: Various ZIP files depending on the arcade board
- **Common Files**: neogeo.zip for Neo Geo games, various other BIOS ZIPs for specific arcade boards
- **Notes**: Arcade emulation often requires the exact BIOS for the specific board/game being emulated.

### Game Boy / Game Boy Color / Game Boy Advance
- **Required BIOS**: 
  - GB: dmg_boot.bin or gb_bios.bin
  - GBC: cgb_boot.bin or gbc_bios.bin
  - GBA: gba_bios.bin
- **Emulators**: mGBA, VBA-M
- **Notes**: GBA emulation in particular benefits from the proper BIOS for accurate emulation.

### MSX Computers
- **Required BIOS**: Multiple ROM files including MSX.ROM, MSX2.ROM, etc.
- **Emulators**: blueMSX, fMSX
- **Notes**: Different MSX models require different BIOS files.

### PC-98
- **Required BIOS**: Various files including bios.rom, font.rom, etc.
- **Emulators**: Neko Project II
- **Notes**: Required for proper text rendering and system functionality.

### NEC PC-FX
- **Required BIOS**: pcfx.rom or pcfxbios.bin
- **Emulators**: Beetle PC-FX
- **Notes**: Essential for PC-FX emulation.

### Microsoft Xbox
- **Required BIOS**: xbox-bios.bin and mcpx version files
- **Emulators**: XEMU
- **Notes**: Required for proper Xbox emulation.

### Sharp X68000
- **Required BIOS**: iplrom.dat, cgrom.dat, and other related files
- **Emulators**: XM6 Pro, PX68K
- **Notes**: Essential for proper system emulation.

## Notes

- Files are copied rather than moved to preserve the original source
- If a file with the same name already exists at the destination, the script will check if they're identical
- Non-identical files with the same name are renamed with a timestamp
- The scripts create an "unknown" folder for BIOS files that don't match any known pattern 