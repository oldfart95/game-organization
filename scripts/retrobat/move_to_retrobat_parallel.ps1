# Script to intelligently locate and move ROM folders to RetroBar
# Simple sequential version that will work reliably

# Define source and destination paths
$unsupportedPath = "D:\My Passport Backup\Full Retro Files\misc\Unsupporrted Systems"
$fullRetroPath = "D:\My Passport Backup\Full Retro Files"
$destPath = "D:\RetroBat\roms"

# Special folders to exclude (keep in source location)
$excludeFolders = @(
    "pc engine Japan"    # We just moved these files, don't copy them again
)

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
        
        # Skip excluded folders
        if ($excludeFolders -contains $folderName) {
            Write-Host "Skipping excluded folder: $folderName" -ForegroundColor Yellow
            continue
        }
        
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
        
        # Skip excluded folders
        if ($excludeFolders -contains $folderName) {
            Write-Host "Skipping excluded folder: $folderName" -ForegroundColor Yellow
            continue
        }
        
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

# Deduplicate systems - if same system appears more than once, prioritize the folder with more files
$dedupedSystems = @()
$systemGroups = $systemTable | Group-Object SystemName

foreach ($group in $systemGroups) {
    if ($group.Count -gt 1) {
        # Multiple folders for same system - take one with the most files
        $bestMatch = $group.Group | Sort-Object FileCount -Descending | Select-Object -First 1
        Write-Host "Found duplicate system '$($group.Name)'. Using $($bestMatch.SourceFolder) with $($bestMatch.FileCount) files." -ForegroundColor Yellow
        $dedupedSystems += $bestMatch
    }
    else {
        $dedupedSystems += $group.Group[0]
    }
}

# Replace system table with deduplicated version
$systemTable = $dedupedSystems

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

# Create a list of systems to process
$selectedSystems = $systemTable | Where-Object { $_.IsCompatible -eq $true -and $_.FileCount -gt 0 }

Write-Host "`nPreparing to process $($selectedSystems.Count) systems with files to move:" -ForegroundColor Cyan
$selectedSystems | ForEach-Object { Write-Host " - $($_.SystemName) ($($_.FileCount) files)" -ForegroundColor Yellow }

$confirm = Read-Host "`nStart file operations? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit
}

# Track results
$successCount = 0
$failedCount = 0
$failedSystems = @()

Write-Host "`nStarting file operations..." -ForegroundColor Cyan

# Process systems one by one - simpler but reliable approach
foreach ($system in $selectedSystems) {
    $sourceFolder = $system.SourcePath
    $targetFolder = Join-Path -Path $destPath -ChildPath $system.SystemName
    
    Write-Host "Processing: $($system.SystemName) ($($system.FileCount) files)" -ForegroundColor Yellow
    
    # Create destination if needed
    if (-not (Test-Path $targetFolder)) {
        New-Item -Path $targetFolder -ItemType Directory -Force | Out-Null
    }
    
    # Copy files
    $success = $true
    $errorCount = 0
    
    try {
        Copy-Item -Path "$sourceFolder\*" -Destination $targetFolder -Recurse -Force -ErrorAction Stop
        Write-Host "Completed $($system.SystemName) successfully" -ForegroundColor Green
        $successCount++
    }
    catch {
        $success = $false
        $errorCount++
        Write-Host "Failed to copy $($system.SystemName): $_" -ForegroundColor Red
        $failedCount++
        $failedSystems += $system
    }
}

# Display summary
Write-Host "`nFile operations completed:" -ForegroundColor Cyan
Write-Host " - Successfully processed: $successCount" -ForegroundColor Green
Write-Host " - Failed: $failedCount" -ForegroundColor $(if ($failedCount -gt 0) { "Red" } else { "Green" })

# If there were failures, list them
if ($failedCount -gt 0) {
    Write-Host "`nSystems that failed:" -ForegroundColor Red
    $failedSystems | ForEach-Object { Write-Host " - $($_.SystemName)" -ForegroundColor Red }
}

# Ask if source folders should be deleted
$deleteSource = Read-Host "`nDelete source folders after successful transfers? (Y/N)"
if ($deleteSource -eq "Y" -or $deleteSource -eq "y") {
    $selectedSystems | ForEach-Object {
        $system = $_
        $isFailed = $failedSystems | Where-Object { $_.SystemName -eq $system.SystemName }
        
        if (-not $isFailed) {
            Write-Host "Removing source folder: $($system.SourceFolder)" -ForegroundColor Yellow
            Remove-Item -Path $system.SourcePath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    Write-Host "Source folder cleanup completed." -ForegroundColor Green
}

Write-Host "`nOperation completed. Your ROM folders have been organized for RetroBar." -ForegroundColor Cyan
Write-Host "Remember to test your games to ensure everything works correctly!" -ForegroundColor Yellow 