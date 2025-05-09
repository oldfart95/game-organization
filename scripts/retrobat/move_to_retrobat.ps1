# Script to intelligently locate and move ROM folders from unsupported systems to RetroBar

# Define source and destination paths
$unsupportedPath = "D:\My Passport Backup\Full Retro Files\misc\Unsupporrted Systems"
$fullRetroPath = "D:\My Passport Backup\Full Retro Files"
$destPath = "D:\RetroBat\roms"

# Function to check file count in directory
function Get-FileCount {
    param (
        [string]$Path
    )
    
    if (-not (Test-Path $Path)) {
        return 0
    }
    
    return (Get-ChildItem -Path $Path -Recurse -File).Count
}

# Get RetroBar system folders for comparison
Write-Host "Loading RetroBar system information..." -ForegroundColor Cyan
$retroBarSystems = Get-ChildItem -Path $destPath -Directory | ForEach-Object { $_.Name }
Write-Host "Found $($retroBarSystems.Count) supported systems in RetroBar" -ForegroundColor Green

# Define special case mappings for system folders
$specialMappings = @{
    "Neo Geo Pocket Colour (ngpc)" = "ngpc"
    "Neo Geo (neogeo)" = "neogeo"
    "PC Engine (tg16)" = "pcengine"
    "Commodore Amiga" = "amiga500"  # Assuming Amiga 500 is the most common
    "FinalBurn Neo (fba)" = "fbneo"
}

# Create a table to track available systems and their locations
$systemTable = @()

# Step 1: Check unsupported systems folder
Write-Host "Checking unsupported systems folder..." -ForegroundColor Cyan
$unsupportedSystems = Get-ChildItem -Path $unsupportedPath -Directory -ErrorAction SilentlyContinue

if ($null -ne $unsupportedSystems) {
    foreach ($folder in $unsupportedSystems) {
        $folderName = $folder.Name
        $fileCount = Get-FileCount -Path $folder.FullName
        
        # Determine matching RetroBar system
        $matchingSystem = $null
        
        # Check for exact match
        if ($retroBarSystems -contains $folderName) {
            $matchingSystem = $folderName
        }
        # Check special mappings
        elseif ($specialMappings.ContainsKey($folderName)) {
            $matchingSystem = $specialMappings[$folderName]
        }
        # Try to find partial match
        else {
            foreach ($retroSystem in $retroBarSystems) {
                if ($folderName -like "*$retroSystem*" -or $retroSystem -like "*$folderName*") {
                    $matchingSystem = $retroSystem
                    break
                }
            }
        }
        
        # Add to tracking table
        $systemTable += [PSCustomObject]@{
            SourcePath = $folder.FullName
            SystemName = if ($matchingSystem) { $matchingSystem } else { $folderName }
            SourceFolder = $folderName
            FileCount = $fileCount
            IsCompatible = ($null -ne $matchingSystem)
            SourceLocation = "Unsupported Systems"
        }
    }
}

# Step 2: Also check main Full Retro Files directory
Write-Host "Checking main Full Retro Files directory..." -ForegroundColor Cyan
$mainSystems = Get-ChildItem -Path $fullRetroPath -Directory -ErrorAction SilentlyContinue

if ($null -ne $mainSystems) {
    foreach ($folder in $mainSystems) {
        $folderName = $folder.Name
        
        # Skip if folder is already in RetroBar format
        if ($retroBarSystems -contains $folderName) {
            $fileCount = Get-FileCount -Path $folder.FullName
            
            $systemTable += [PSCustomObject]@{
                SourcePath = $folder.FullName
                SystemName = $folderName
                SourceFolder = $folderName
                FileCount = $fileCount
                IsCompatible = $true
                SourceLocation = "Main Directory"
            }
        }
        # Check for special cases
        elseif ($specialMappings.ContainsKey($folderName)) {
            $matchingSystem = $specialMappings[$folderName]
            $fileCount = Get-FileCount -Path $folder.FullName
            
            $systemTable += [PSCustomObject]@{
                SourcePath = $folder.FullName
                SystemName = $matchingSystem
                SourceFolder = $folderName
                FileCount = $fileCount
                IsCompatible = $true
                SourceLocation = "Main Directory"
            }
        }
    }
}

# Display results and compatible systems
Write-Host "`nSystems found that can be moved to RetroBar:" -ForegroundColor Cyan
$systemTable | Where-Object { $_.IsCompatible -eq $true } | Sort-Object SystemName | Format-Table SystemName, SourceFolder, FileCount, SourceLocation

# Display incompatible systems
Write-Host "`nSystems that could not be matched to RetroBar:" -ForegroundColor Yellow
$systemTable | Where-Object { $_.IsCompatible -eq $false } | Format-Table SourceFolder, FileCount

# Confirm if user wants to proceed with moving
$moveConfirm = Read-Host "Would you like to move the compatible systems to RetroBar? (Y/N)"
if ($moveConfirm -ne "Y" -and $moveConfirm -ne "y") {
    Write-Host "Operation cancelled by user." -ForegroundColor Yellow
    exit
}

# Process each compatible system
foreach ($system in ($systemTable | Where-Object { $_.IsCompatible -eq $true })) {
    $sourceFolder = $system.SourcePath
    $targetFolder = Join-Path -Path $destPath -ChildPath $system.SystemName
    
    Write-Host "`nProcessing system: $($system.SystemName) from $($system.SourceLocation)" -ForegroundColor Cyan
    Write-Host "Source folder: $sourceFolder" -ForegroundColor Yellow
    Write-Host "Target folder: $targetFolder" -ForegroundColor Yellow
    
    # Skip if no files to move
    if ($system.FileCount -eq 0) {
        Write-Host "No files found in source folder. Skipping." -ForegroundColor Yellow
        continue
    }
    
    # Check if destination exists
    if (-not (Test-Path $targetFolder)) {
        # If it doesn't exist, create it
        Write-Host "Creating destination folder..." -ForegroundColor Yellow
        New-Item -Path $targetFolder -ItemType Directory -Force | Out-Null
    }
    
    # Confirm copy operation for this system
    $copyConfirm = Read-Host "Copy $($system.FileCount) files from $($system.SourceFolder) to $($system.SystemName)? (Y/N)"
    if ($copyConfirm -ne "Y" -and $copyConfirm -ne "y") {
        Write-Host "Skipping this system." -ForegroundColor Yellow
        continue
    }
    
    # Copy the files
    Write-Host "Copying files..." -ForegroundColor Yellow
    Copy-Item -Path "$sourceFolder\*" -Destination $targetFolder -Recurse -Force
    
    # Verify copy
    $targetFileCount = Get-FileCount -Path $targetFolder
    Write-Host "Copy completed. $targetFileCount files now in destination folder." -ForegroundColor Green
    
    # Ask about removing source
    $deleteConfirm = Read-Host "Delete source folder after successful copy? (Y/N)"
    if ($deleteConfirm -eq "Y" -or $deleteConfirm -eq "y") {
        Remove-Item -Path $sourceFolder -Recurse -Force
        Write-Host "Source folder deleted." -ForegroundColor Green
    }
}

Write-Host "`nOperation completed. Your ROM folders have been organized for RetroBar." -ForegroundColor Cyan
Write-Host "Remember to test your games to ensure everything works correctly!" -ForegroundColor Yellow 