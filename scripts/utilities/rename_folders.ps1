# Script to rename folders from D:\My Passport Backup\Full Retro Files
# to match the convention used in D:\RetroBat\roms

# Define source and destination paths
$sourcePath = "D:\My Passport Backup\Full Retro Files"
$destPath = "D:\RetroBat\roms"

# Create a mapping of folder names that DO need to be renamed
$folderMapping = @{
    # These folders need renaming (folders that don't follow the RetroBat convention)
    "Atari 2600" = "atari2600"
    "Commodore 64" = "c64"
    "Game and Watch" = "gameandwatch"
    "Nintendo 64 (n64)" = "n64"
    "Nintendo 64DD (n64)" = "n64dd"
    "Nintendo Entertainment System (nes)" = "nes"
    "Nintendo Famicom (fsd)" = "fds"
    "Nintendo Game Boy (gb)" = "gb"
    "Nintendo Game Boy Advance (gba)" = "gba"
    "Nintendo Game Boy Colour (gbc)" = "gbc"
    "Nintendo Switch" = "switch"
    "Nintendo Virtual Boy (virtualboy)" = "virtualboy"
    "PC Engine SuperGrafx (sgfx)" = "supergrafx"
    "Playstation 1" = "psx"
    "Playstation 2" = "ps2"
    "Sega GameGear (gamegear)" = "gamegear"
    "Sega Genesis" = "megadrive"
    "Sega MasterSystem (mastersystem)" = "mastersystem"
    "Sega MegaDrive (megadrive)" = "megadrive"
    "Sega MegaDrive Japan (megadrive)" = "megadrive"
    "Sega SG-1000 (SG-1000)" = "sg1000"
    "Sega x32 (sega32x)" = "sega32x"
    "Super Famicom System (sfc)" = "snes"
}

# Get all folders in the source directory
$sourceFolders = Get-ChildItem -Path $sourcePath -Directory

# Process each folder
Write-Host "Starting folder verification and renaming..." -ForegroundColor Cyan

foreach ($folder in $sourceFolders) {
    $sourceFolderName = $folder.Name
    
    # Skip the misc folder
    if ($sourceFolderName -eq "misc") {
        Write-Host "Skipping 'misc' folder as requested" -ForegroundColor Yellow
        continue
    }
    
    # First check if the folder already matches RetroBar naming
    $destFolderExists = Test-Path (Join-Path -Path $destPath -ChildPath $sourceFolderName)
    
    if ($destFolderExists -and -not $folderMapping.ContainsKey($sourceFolderName)) {
        Write-Host "Folder '$sourceFolderName' is already correctly named according to RetroBar convention." -ForegroundColor Green
        continue
    }
    
    # Check if the folder is in our mapping and needs to be renamed
    if ($folderMapping.ContainsKey($sourceFolderName)) {
        $destFolderName = $folderMapping[$sourceFolderName]
        $newFolderPath = Join-Path -Path $sourcePath -ChildPath $destFolderName
        
        # If the source and destination folder names are the same, skip
        if ($sourceFolderName -eq $destFolderName) {
            Write-Host "Folder '$sourceFolderName' already has the correct name. Skipping." -ForegroundColor Yellow
            continue
        }
        
        Write-Host "Renaming '$sourceFolderName' to '$destFolderName'"
        
        # Check if destination folder already exists
        if (Test-Path $newFolderPath) {
            Write-Host "Destination folder '$destFolderName' already exists. Files should be manually merged." -ForegroundColor Yellow
        } else {
            # Rename the folder
            Rename-Item -Path $folder.FullName -NewName $destFolderName -ErrorAction SilentlyContinue
            
            if ($?) {
                Write-Host "Successfully renamed to '$destFolderName'" -ForegroundColor Green
            } else {
                Write-Host "Failed to rename the folder '$sourceFolderName'" -ForegroundColor Red
            }
        }
    }
}

Write-Host "Folder renaming completed." -ForegroundColor Cyan
Write-Host "Remember to manually check that all folders match the destination convention!" -ForegroundColor Yellow 