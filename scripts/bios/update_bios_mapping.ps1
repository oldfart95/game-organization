# Script to update the BIOS mapping with more systems from the RetroBar wiki
# This script allows you to add more entries to the BIOS mapping

# Define paths
$workingDirPath = "$PSScriptRoot\bios_organization"

# Ensure working directory exists
if (-not (Test-Path $workingDirPath)) {
    New-Item -Path $workingDirPath -ItemType Directory -Force | Out-Null
}

# File to store the expanded mapping
$mappingFile = "$workingDirPath\expanded_bios_mapping.ps1"

# Create template if file doesn't exist
if (-not (Test-Path $mappingFile)) {
    @"
# Expanded BIOS Mapping
# This file contains additional BIOS mappings for RetroBar systems
# Generated on $(Get-Date)

# Add your additional mappings below in the format:
# "filename_pattern" = "system_folder"

# Example:
# "scph1001.bin" = "psx"
# "neogeo.zip" = "neogeo"

"@ | Out-File $mappingFile -Encoding utf8
}

# Function to add a new mapping entry
function Add-BiosMapping {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePattern,
        
        [Parameter(Mandatory=$true)]
        [string]$SystemFolder
    )
    
    # Read existing file
    $content = Get-Content $mappingFile -Raw
    
    # Check if entry already exists
    if ($content -match "^\s*`"$([regex]::Escape($FilePattern))`"\s*=") {
        Write-Host "Entry for '$FilePattern' already exists." -ForegroundColor Yellow
        return
    }
    
    # Append new entry
    "`"$FilePattern`" = `"$SystemFolder`"" | Out-File $mappingFile -Append
    Write-Host "Added mapping: '$FilePattern' -> '$SystemFolder'" -ForegroundColor Green
}

# Function to list common RetroBar system folders
function Show-RetroBarSystems {
    $systems = @(
        "3do", "amiga", "amstradcpc", "arcade", "atari800", "atari2600", "atari5200", "atari7800", 
        "atarist", "c64", "channelf", "coco", "colecovision", "cps1", "cps2", "cps3", "dreamcast", 
        "ecwolf", "fba", "fds", "gamegear", "gb", "gba", "gbc", "gamecube", "intellivision", "j2me", 
        "jaguar", "lynx", "macii", "mame", "mastersystem", "megacd", "megadrive", "msx", "n64", "n64dd",
        "naomi", "nds", "neogeo", "neogeocd", "nes", "ngp", "ngpc", "o2em", "pcengine", "pcenginecd", 
        "pc98", "pcfx", "pokemini", "prboom", "psx", "ps2", "psp", "satellaview", "saturn", "scummvm", 
        "sega32x", "segacd", "sg1000", "sgb", "snes", "sufami", "vectrex", "videopac", "virtualboy", 
        "wonderswan", "wonderswancolor", "x1", "x68000", "zxspectrum"
    )
    
    Write-Host "`nCommon RetroBar system folders:" -ForegroundColor Cyan
    Write-Host "--------------------------------" -ForegroundColor Cyan
    $systems | Sort-Object | ForEach-Object {
        Write-Host "- $_" -ForegroundColor Yellow
    }
}

# Main menu
function Show-Menu {
    Clear-Host
    Write-Host "BIOS Mapping Manager" -ForegroundColor Cyan
    Write-Host "===================" -ForegroundColor Cyan
    Write-Host
    Write-Host "1: Add new BIOS mapping entry" -ForegroundColor Green
    Write-Host "2: Show common RetroBar system folders" -ForegroundColor Green
    Write-Host "3: Edit mapping file directly" -ForegroundColor Green
    Write-Host "4: Export mapping for use in other scripts" -ForegroundColor Green
    Write-Host "Q: Quit" -ForegroundColor Green
    Write-Host
}

# Main loop
do {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    
    switch ($selection) {
        '1' {
            $filePattern = Read-Host "Enter BIOS filename pattern (e.g., 'scph*.bin')"
            $systemFolder = Read-Host "Enter system folder name (e.g., 'psx')"
            Add-BiosMapping -FilePattern $filePattern -SystemFolder $systemFolder
            Write-Host "Press any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '2' {
            Show-RetroBarSystems
            Write-Host "Press any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '3' {
            # Open the file in notepad
            Start-Process "notepad.exe" $mappingFile
        }
        '4' {
            # Export mapping for other scripts
            $exportFile = "$workingDirPath\bios_mapping_hashtable.ps1"
            
            # Start with header
            @"
# BIOS Mapping Hashtable
# Generated on $(Get-Date)
# This file can be included in other scripts

`$biosMapping = @{
"@ | Out-File $exportFile -Encoding utf8
            
            # Add default mappings
            $defaultMappings = @{
                # 3DO
                "panafz*.bin" = "3do"
                "goldstar.bin" = "3do"
                "3do_arcade_saot.bin" = "3do"
                
                # Arcade
                "airlbios.zip" = "arcade"
                "awbios.zip" = "arcade"
                "bubsys.zip" = "arcade"
                "cchip.zip" = "arcade"
                "decocass.zip" = "arcade"
                "f355bios.zip" = "arcade"
                "f355dlx.zip" = "arcade"
                "hod2bios.zip" = "arcade"
                "isgsm.zip" = "arcade"
                "midssio.zip" = "arcade"
                "naomi.zip" = "naomi"
                "neogeo.zip" = "neogeo"
                "nmk004.zip" = "arcade"
                "pgm.zip" = "arcade"
                "skns.zip" = "arcade"
                "ym2608.zip" = "arcade"
                
                # Atari 400-800
                "ATARIBAS.ROM" = "atari800"
                "ATARIOSA.ROM" = "atari800"
                "ATARIOSB.ROM" = "atari800"
                "ATARIXL.ROM" = "atari800"
                
                # Atari 5200
                "5200.rom" = "atari5200"
                
                # Atari 7800
                "7800 BIOS (E).rom" = "atari7800"
                "7800 BIOS (U).rom" = "atari7800"
                
                # Atari Lynx
                "lynxboot.img" = "lynx"
                
                # Atari ST
                "tos.img" = "atarist"
                
                # Colecovision
                "colecovision.rom" = "colecovision"
                
                # Commodore Amiga
                "kick*.A500" = "amiga"
                "kick*.A600" = "amiga"
                "kick*.A1200" = "amiga"
                
                # Fairchild Channel F
                "sl31253.bin" = "channelf"
                "sl31254.bin" = "channelf"
                "sl90025.bin" = "channelf"
                
                # Doom
                "prboom.wad" = "prboom"
                
                # J2ME
                "freej2me*.jar" = "j2me"
                
                # MacII
                "MacII.ROM" = "macii"
                
                # Odyssey 2
                "o2rom.bin" = "o2em"
                
                # Intellivision
                "exec.bin" = "intellivision"
                "grom.bin" = "intellivision"
                
                # MSX
                "CARTS.SHA" = "msx"
                "CYRILLIC.FNT" = "msx"
                "DISK.ROM" = "msx"
                "FMPAC.ROM" = "msx"
                "FMPAC16.ROM" = "msx"
                "ITALIC.FNT" = "msx"
                "KANJI.ROM" = "msx"
                "MSX.ROM" = "msx"
                "MSX2.ROM" = "msx"
                "MSX2EXT.ROM" = "msx"
                "MSX2P.ROM" = "msx"
                "MSX2PEXT.ROM" = "msx"
                "MSXDOS2.ROM" = "msx"
                "PAINTER.ROM" = "msx"
                "RS232.ROM" = "msx"
                
                # PC Engine / TurboGrafx
                "gecard.pce" = "pcengine"
                "gexpress.pce" = "pcengine"
                "syscard*.pce" = "pcengine"
                
                # PC-98
                "2608_*.wav" = "pc98"
                "bios.rom" = "pc98"
                "font.bmp" = "pc98"
                "font.rom" = "pc98"
                "itf.rom" = "pc98"
                "sound.rom" = "pc98"
                "np2kai.rom" = "pc98"
                
                # PC-FX
                "fx-scsi.rom" = "pcfx"
                "pcfx.rom" = "pcfx"
                "pcfxbios.bin" = "pcfx"
                "pcfxga.rom" = "pcfx"
                "pcfxv101.bin" = "pcfx"
                
                # Nintendo Famicom Disk System
                "disksys.rom" = "fds"
                
                # Nintendo Game Boy
                "dmg_boot.bin" = "gb"
                "gb_bios.bin" = "gb"
                
                # Nintendo Game Boy Advance
                "gba_bios.bin" = "gba"
                
                # Nintendo Game Boy Color
                "cgb_boot.bin" = "gbc"
                "gbc_bios.bin" = "gbc"
                
                # Nintendo GameCube
                "gc-*.bin" = "gamecube"
                
                # Nintendo 64DD
                "64DD_IPL.bin" = "n64dd"
                
                # Nintendo DS
                "bios7.bin" = "nds"
                "bios9.bin" = "nds"
                "firmware.bin" = "nds"
                
                # Nintendo 3DS (New based on wiki)
                "boot9.bin" = "3ds"
                "boot11.bin" = "3ds" 
                "aes_keys.bin" = "3ds"
                "secret_sector.bin" = "3ds"
                "seeddb.bin" = "3ds"
                
                # Nintendo Entertainment System
                "NstDatabase.xml" = "nes"
                
                # Nintendo Pokemon Mini
                "bios.min" = "pokemini"
                
                # Nintendo Satellaview
                "BS-X*.bin" = "satellaview"
                
                # Nintendo SuFami Turbo
                "STBIOS.bin" = "sufami"
                
                # Nintendo Super Game Boy
                "SGB*.sfc" = "sgb"
                "sgb1.boot.rom" = "sgb"
                "sgb1.program.rom" = "sgb"
                "sgb2.boot.rom" = "sgb"
                "sgb2.program.rom" = "sgb"
                "sgb2_bios.bin" = "sgb"
                "sgb_bios.bin" = "sgb"
                
                # Nintendo SNES chips
                "cx4.data.rom" = "snes"
                "dsp*.data.rom" = "snes"
                "dsp*.program.rom" = "snes"
                "st*.data.rom" = "snes"
                "st*.program.rom" = "snes"
                
                # Videopac+
                "c52.bin" = "videopac"
                "g7400.bin" = "videopac"
                "jopac.bin" = "videopac"
                
                # Sega Dreamcast
                "dc_boot.bin" = "dreamcast"
                "dc_flash.bin" = "dreamcast"
                "naomi_boot.bin" = "naomi"
                
                # Sega Game Gear
                "bios.gg" = "gamegear"
                
                # Sega Master System
                "bios.sms" = "mastersystem"
                "bios_E.sms" = "mastersystem"
                "bios_J.sms" = "mastersystem"
                "bios_U.sms" = "mastersystem"
                
                # Sega CD
                "bios_CD_E.bin" = "segacd"
                "bios_CD_J.bin" = "segacd"
                "bios_CD_U.bin" = "segacd"
                
                # Sega Mega Drive / Genesis
                "areplay.bin" = "megadrive"
                "bios_MD.bin" = "megadrive"
                "ggenie.bin" = "megadrive"
                "rom.db" = "megadrive"
                "sk.bin" = "megadrive"
                "sk2chip.bin" = "megadrive"
                
                # Sega Saturn
                "hisaturn.bin" = "saturn"
                "mpr-*.bin" = "saturn"
                "saturn_bios.bin" = "saturn"
                "sega*.bin" = "saturn"
                "vsaturn.bin" = "saturn"
                
                # Sharp X1
                "iplrom.x1" = "x1"
                "iplrom.x1t" = "x1"
                
                # Sharp X68000
                "cgrom.dat" = "x68000"
                "iplrom.dat" = "x68000"
                "iplrom30.dat" = "x68000"
                "iplromco.dat" = "x68000"
                "iplromxv.dat" = "x68000"
                
                # ZX Spectrum
                "128-*.rom" = "zxspectrum"
                "48.rom" = "zxspectrum"
                "disciple.rom" = "zxspectrum"
                "plus*.rom" = "zxspectrum"
                "tape_*.szx" = "zxspectrum"
                
                # SNK NeoGeo CD
                "000-lo.lo" = "neogeocd"
                "front-sp1.bin" = "neogeocd"
                "neocd*.bin" = "neogeocd"
                "neocd*.rom" = "neogeocd"
                "top-sp1.bin" = "neogeocd"
                "uni-bioscd.rom" = "neogeocd"
                
                # Sony PlayStation
                "scph*.bin" = "psx"
                "ps-22a.bin" = "psx"
                "PSXONPSP660.BIN" = "psx"
                
                # PocketStation (Sony PlayStation add-on)
                "pocketstation.bin" = "psx"
                
                # Sony PlayStation Portable
                "ppge_atlas.zim" = "psp"
                "ppsspp_adrenaline.bin" = "psp"
                
                # Sony PlayStation Vita
                "PSP2UPDAT.PUP" = "psvita"
                "PSVUPDAT.PUP" = "psvita"
                
                # CD-i
                "cdi_bios.rom" = "cdi"
                "cdi_euro.rom" = "cdi"
                "cdi_japan.rom" = "cdi"
                "cdi_usa.rom" = "cdi"
                
                # Microsoft Xbox
                "xbox-bios.bin" = "xbox"
                "mcpx_1.0.bin" = "xbox"
                "mcpx_1.1.bin" = "xbox"
                
                # Microsoft Xbox 360
                "xenon.bin" = "xbox360"
                "xenos.bin" = "xbox360"
                
                # Wolfenstein 3D
                "ecwolf.pk3" = "ecwolf"
                
                # ScummVM
                "scummvm.zip" = "scummvm"

                # ZX Spectrum additions
                "128p-0.rom" = "zxspectrum"
                "128p-1.rom" = "zxspectrum"
                "256s-0.rom" = "zxspectrum"
                "256s-1.rom" = "zxspectrum"
                "256s-2.rom" = "zxspectrum"
                "256s-3.rom" = "zxspectrum"
                "disk_plus3.szx" = "zxspectrum"
                "gluck.rom" = "zxspectrum"
                "if1-1.rom" = "zxspectrum"
                "if1-2.rom" = "zxspectrum"
                "se-0.rom" = "zxspectrum"
                "se-1.rom" = "zxspectrum"
                "speccyboot-1.4.rom" = "zxspectrum"
                "tc2048.rom" = "zxspectrum"
                "tc2068-0.rom" = "zxspectrum"
                "tc2068-1.rom" = "zxspectrum"
                "trdos.rom" = "zxspectrum"

                # PC-98 additions
                "NEC - PC-98_2608_bd.wav" = "pc98"
                "NEC - PC-98_2608_hh.wav" = "pc98"
                "NEC - PC-98_2608_rim.wav" = "pc98"
                "NEC - PC-98_2608_sd.wav" = "pc98"
                "NEC - PC-98_2608_tom.wav" = "pc98"
                "NEC - PC-98_2608_top.wav" = "pc98"

                # Sega Saturn additions
                "mpr-18811-mx.ic1" = "saturn"
                "mpr-19367-mx.ic1" = "saturn"

                # 3DO addition
                "sanyotry.bin" = "3do"

                # PlayStation 2 addition
                "ps2-bios-all-bios.zip" = "ps2"

                # Documentation (can be ignored)
                "Bioses.md" = "ignore"
            }
            
            # Add default mappings to export file
            foreach ($key in $defaultMappings.Keys) {
                "    `"$key`" = `"$($defaultMappings[$key])`"" | Out-File $exportFile -Append
            }
            
            # Read and parse expanded mapping file if it exists
            if (Test-Path $mappingFile) {
                $customMappings = Get-Content $mappingFile | Where-Object { 
                    $_ -match '^\s*"([^"]+)"\s*=\s*"([^"]+)"' 
                }
                
                foreach ($line in $customMappings) {
                    if ($line -match '^\s*"([^"]+)"\s*=\s*"([^"]+)"') {
                        $pattern = $matches[1]
                        $folder = $matches[2]
                        "    `"$pattern`" = `"$folder`"" | Out-File $exportFile -Append
                    }
                }
            }
            
            # Add default entry and closing brace
            "    `"default`" = `"unknown`"" | Out-File $exportFile -Append
            "}" | Out-File $exportFile -Append
            
            Write-Host "Exported mapping to $exportFile" -ForegroundColor Green
            Write-Host "Press any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
} until ($selection -eq 'q' -or $selection -eq 'Q')

Write-Host "To use the updated mappings, run the move_bios_files.ps1 script." -ForegroundColor Cyan 