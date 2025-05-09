# Script to find Japan+USA ROMs in the unsupported systems folder and move them back to RetroBar

# Define paths
$retroBatPath = "D:\RetroBat\roms"
$unsupportedPath = "D:\My Passport Backup\Full Retro Files\misc\Unsupporrted Systems"

# Check if unsupported path exists
if (-not (Test-Path $unsupportedPath)) {
    Write-Host "Unsupported systems folder not found at $unsupportedPath" -ForegroundColor Red
    exit
}

# Check if RetroBar path exists
if (-not (Test-Path $retroBatPath)) {
    Write-Host "RetroBar folder not found at $retroBatPath" -ForegroundColor Red
    exit
}

# Get all system folders in the unsupported directory
$systemFolders = Get-ChildItem -Path $unsupportedPath -Directory

Write-Host "Found $($systemFolders.Count) system folders in unsupported systems." -ForegroundColor Cyan

# Ask for confirmation
$confirm = Read-Host "Move all Japan+USA ROMs back to RetroBar? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit
}

# Track found files
$totalFound = 0
$totalMoved = 0
$systemsWithROMs = @()

# Process each system folder
foreach ($systemFolder in $systemFolders) {
    $systemName = $systemFolder.Name
    
    # Remove " Japan" suffix if present to get the original system name
    $originalSystemName = $systemName -replace " Japan$", ""
    
    Write-Host "Checking system: $systemName..." -ForegroundColor Cyan
    
    # Find all files with both "Japan" and "USA" in the name
    $japanUSAFiles = Get-ChildItem -Path $systemFolder.FullName -Recurse -File | 
                   Where-Object { $_.Name -match "Japan.*USA|USA.*Japan|\(J, U\)|\(U, J\)" }
    
    if ($japanUSAFiles.Count -gt 0) {
        Write-Host "  Found $($japanUSAFiles.Count) Japan+USA ROMs in $systemName" -ForegroundColor Yellow
        $totalFound += $japanUSAFiles.Count
        $systemsWithROMs += $systemName
        
        # Check if the destination system folder exists in RetroBar
        $destSystemPath = Join-Path -Path $retroBatPath -ChildPath $originalSystemName
        if (-not (Test-Path $destSystemPath)) {
            Write-Host "  Creating '$originalSystemName' folder in RetroBar..." -ForegroundColor Yellow
            New-Item -Path $destSystemPath -ItemType Directory -Force | Out-Null
        }
        
        # Move files back to RetroBar
        foreach ($file in $japanUSAFiles) {
            $destinationFile = Join-Path -Path $destSystemPath -ChildPath $file.Name
            
            # Check if file already exists
            if (Test-Path $destinationFile) {
                Write-Host "      Skipping existing file: $($file.Name)" -ForegroundColor Gray
                continue
            }
            
            # Move the file
            Move-Item -Path $file.FullName -Destination $destinationFile -Force
            $totalMoved++
            Write-Host "      Moved: $($file.Name)" -ForegroundColor Green
        }
    }
}

# Display summary
Write-Host "`nOperation completed." -ForegroundColor Cyan
Write-Host "Total Japan+USA ROMs found: $totalFound" -ForegroundColor Green
Write-Host "Total ROMs moved: $totalMoved" -ForegroundColor Green
Write-Host "Systems processed: $($systemsWithROMs.Count)" -ForegroundColor Green

Write-Host "`nOperation completed successfully." -ForegroundColor Cyan 