# Game Management Scripts

A collection of PowerShell scripts for managing game ROMs, BIOS files, and emulation setups.

## Overview

This repository contains utilities for:
- Organizing BIOS files for various emulation systems
- Managing ROM files by region and system
- Integration with RetroBar frontend
- Various utilities for game and emulation management

## Directory Structure

```
Game_Management/
├── scripts/                 # Main scripts directory
│   ├── bios/                # BIOS management scripts
│   ├── rom_management/      # ROM organization scripts
│   ├── retrobat/            # RetroBar integration scripts
│   ├── utilities/           # General utility scripts
│   ├── README.md            # Scripts documentation
│   └── organize_scripts.ps1 # Script organization tool
└── README.md                # This file
```

## Getting Started

1. Browse to the appropriate folder for your task:
   - For BIOS management: `scripts/bios/`
   - For ROM organization: `scripts/rom_management/`
   - For RetroBar integration: `scripts/retrobat/`
   - For general utilities: `scripts/utilities/`

2. Run the desired PowerShell script from PowerShell or Windows Terminal

## Main Scripts

### BIOS Management
- `scripts/bios/move_bios_files.ps1` - Main script for organizing BIOS files
- `scripts/bios/update_bios_mapping.ps1` - Update BIOS file mappings

### ROM Management
- `scripts/rom_management/move_japan_roms.ps1` - Move Japanese ROMs to separate folders
- `scripts/rom_management/move_pcengine_japan.ps1` - PC Engine Japanese ROM organization

### RetroBar
- `scripts/retrobat/move_to_retrobat.ps1` - Move files to RetroBar structure
- `scripts/retrobat/move_to_retrobat_parallel.ps1` - Parallel processing version

### Utilities
- `scripts/utilities/rename_folders.ps1` - Utility to rename folders in bulk

## Detailed Documentation

For more detailed information on scripts and their usage, see:
- `scripts/README.md` - Detailed scripts documentation
- `scripts/bios/README_bios_organization.md` - BIOS organization details

## License

These scripts are provided as-is for personal use. 