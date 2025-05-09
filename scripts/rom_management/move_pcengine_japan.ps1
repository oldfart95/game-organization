# Script to find and backup all Japan ROMs from RetroBar to the incompatible systems folder

# Define paths
$retroBatPath = "D:\RetroBat\roms"
$unsupportedPath = "D:\My Passport Backup\Full Retro Files\misc\Unsupporrted Systems"

# Create a function to extract the Japan part from a filename
function Get-JapanIdentifier {
    param (
        [string]$Filename
    )
    
    # Try to extract the Japan part from the filename using regex
    if ($Filename -match "\(Japan[^\)]*\)|\[Japan[^\]]*\]|Japan") {
        return $matches[0]
    } else {
        return "Japan" # Default if no specific identifier is found
    }
}

# Check if destination exists
if (-not (Test-Path $unsupportedPath)) {
    Write-Host "Unsupported systems folder not found at $unsupportedPath" -ForegroundColor Red
    exit
}

# Count systems in RetroBar
$systemFolders = Get-ChildItem -Path $retroBatPath -Directory
Write-Host "Found $($systemFolders.Count) system folders in RetroBar." -ForegroundColor Cyan

# Ask for confirmation
$confirm = Read-Host "Search for and backup all Japan ROMs to the unsupported systems folder? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit
}

# Track found files
$totalFound = 0
$systemsWithJapanRoms = @()

# Process each system folder
foreach ($systemFolder in $systemFolders) {
    $systemName = $systemFolder.Name
    Write-Host "Checking system: $systemName..." -ForegroundColor Cyan
    
    # Find all files with "Japan" in the name
    $japanFiles = Get-ChildItem -Path $systemFolder.FullName -Recurse -File | 
                  Where-Object { $_.Name -match "Japan|JPN|JAP" }
    
    if ($japanFiles.Count -gt 0) {
        Write-Host "  Found $($japanFiles.Count) Japan ROMs in $systemName" -ForegroundColor Yellow
        $totalFound += $japanFiles.Count
        $systemsWithJapanRoms += $systemName
        
        # Create system-specific Japan folder in unsupported systems
        $japanFolderPath = Join-Path -Path $unsupportedPath -ChildPath "$systemName Japan"
        if (-not (Test-Path $japanFolderPath)) {
            Write-Host "  Creating '$systemName Japan' folder..." -ForegroundColor Yellow
            New-Item -Path $japanFolderPath -ItemType Directory -Force | Out-Null
        }
        
        # Group Japan files by their Japan identifier (e.g., (Japan), (Japan, USA), etc.)
        $japanGroups = $japanFiles | Group-Object { Get-JapanIdentifier -Filename $_.Name }
        
        foreach ($group in $japanGroups) {
            $identifier = $group.Name
            Write-Host "    - $($group.Count) files with identifier: $identifier" -ForegroundColor Yellow
            
            # Copy files to the appropriate folder
            foreach ($file in $group.Group) {
                $destinationFile = Join-Path -Path $japanFolderPath -ChildPath $file.Name
                
                # Check if file already exists
                if (Test-Path $destinationFile) {
                    Write-Host "      Skipping existing file: $($file.Name)" -ForegroundColor Gray
                    continue
                }
                
                # Copy the file
                Copy-Item -Path $file.FullName -Destination $destinationFile -Force
                Write-Host "      Backed up: $($file.Name)" -ForegroundColor Green
            }
        }
    }
}

# Display summary
Write-Host "`nBackup operation completed." -ForegroundColor Cyan
Write-Host "Total Japan ROMs found: $totalFound" -ForegroundColor Green
Write-Host "Systems with Japan ROMs: $($systemsWithJapanRoms.Count)" -ForegroundColor Green

# Ask if user wants to remove the original Japan ROMs
if ($totalFound -gt 0) {
    $removeOriginals = Read-Host "`nDo you want to remove the original Japan ROMs from RetroBar? (Y/N)"
    if ($removeOriginals -eq "Y" -or $removeOriginals -eq "y") {
        $removedCount = 0
        
        foreach ($systemFolder in $systemFolders) {
            $systemName = $systemFolder.Name
            
            # Find all files with "Japan" in the name
            $japanFiles = Get-ChildItem -Path $systemFolder.FullName -Recurse -File | 
                          Where-Object { $_.Name -match "Japan|JPN|JAP" }
            
            if ($japanFiles.Count -gt 0) {
                Write-Host "Removing Japan ROMs from $systemName..." -ForegroundColor Yellow
                
                foreach ($file in $japanFiles) {
                    # Remove the file
                    Remove-Item -Path $file.FullName -Force
                    $removedCount++
                }
            }
        }
        
        Write-Host "Removed $removedCount Japan ROMs from RetroBar." -ForegroundColor Green
    }
}

Write-Host "`nOperation completed successfully." -ForegroundColor Cyan 