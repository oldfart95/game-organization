# Game Management Scripts

This repository contains various PowerShell scripts for managing ROMs, BIOS files, and other emulation-related tasks.

## Directory Structure

The scripts are organized into the following categories:

### BIOS Management (`./scripts/bios/`)
- Scripts for organizing, moving, and verifying BIOS files for various emulators
- BIOS file mappings and system support information

### ROM Management (`./scripts/rom_management/`)
- Scripts for organizing ROM files by region (Japan, USA, etc.)
- Tools for moving ROMs between collections

### RetroBat Integration (`./scripts/retrobat/`)
- Scripts for integrating with the RetroBat frontend
- Tools for parallel processing and optimization

### Utilities (`./scripts/utilities/`)
- General utility scripts that don't fit in other categories
- Folder renaming and organization tools

## Key Scripts

### BIOS Management
- `move_bios_files.ps1` - Main script for organizing BIOS files
- `update_bios_mapping.ps1` - Update BIOS file mappings
- `check_unsupported_systems.ps1` - Check for unsupported system BIOSes

### ROM Management
- `move_japan_roms.ps1` - Move Japanese ROMs to separate folders
- `move_pcengine_japan.ps1` - PC Engine Japanese ROM organization
- `move_japan_usa_back.ps1` - Restore ROMs to original locations

### RetroBat
- `move_to_retrobat.ps1` - Move files to RetroBat structure
- `move_to_retrobat_parallel.ps1` - Parallel processing version for performance

### Utilities
- `rename_folders.ps1` - Utility to rename folders in bulk

## Documentation
- `Bioses.md` - Information about BIOS files
- `README_bios_organization.md` - Detailed info about BIOS organization

## Fixing the Organization

If you need to fix the current organization where all files were copied to the BIOS folder, you can run a corrected version of the organization script. This would involve:

1. Removing the incorrect files from the BIOS folder
2. Running an updated script that correctly places files in their appropriate folders

## Usage

Each script can be run independently from PowerShell. Most scripts will provide instructions when run without parameters.

Example:
```powershell
.\scripts\bios\move_bios_files.ps1
```

## Contributing

Feel free to contribute to this project by submitting pull requests or suggestions. 