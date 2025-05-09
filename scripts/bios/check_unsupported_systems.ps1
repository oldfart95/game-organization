# Script to identify potential matches between unsupported systems and RetroBar's structure
# and rename folders if appropriate matches are found

# Define source and destination paths
$unsupportedPath = "D:\My Passport Backup\Full Retro Files\misc\Unsupporrted Systems"
$destPath = "D:\RetroBat\roms"

# First, let's get a list of the RetroBar system folders
Write-Host "Fetching RetroBar supported systems..." -ForegroundColor Cyan
$retroBarSystems = Get-ChildItem -Path $destPath -Directory | ForEach-Object { $_.Name }
Write-Host "Found $($retroBarSystems.Count) systems supported by RetroBar" -ForegroundColor Green

# Now get the unsupported system directories
Write-Host "Checking unsupported systems folder at $unsupportedPath" -ForegroundColor Cyan
$unsupportedSystems = Get-ChildItem -Path $unsupportedPath -Directory -ErrorAction SilentlyContinue

if ($null -eq $unsupportedSystems) {
    Write-Host "No folders found in the unsupported systems directory or directory does not exist." -ForegroundColor Red
    exit
}

Write-Host "Found $($unsupportedSystems.Count) potentially unsupported systems" -ForegroundColor Yellow

# Create a table to track findings
$systemTable = @()

# Process each folder in unsupported systems
foreach ($folder in $unsupportedSystems) {
    $folderName = $folder.Name
    $exactMatch = $retroBarSystems -contains $folderName
    
    # Special case for Neo Geo Pocket Colour
    if ($folderName -eq "Neo Geo Pocket Colour (ngpc)") {
        $recommendedAction = "Rename to ngpc"
        $potentialMatches = @("ngpc")
    } else {
        # Look for potential close matches
        $potentialMatches = @()
        foreach ($retroSystem in $retroBarSystems) {
            # Simple string comparison - could be made more sophisticated
            if ($retroSystem -like "*$folderName*" -or $folderName -like "*$retroSystem*") {
                $potentialMatches += $retroSystem
            }
        }
        
        # Handle potential matches appropriately
        $recommendedAction = if ($exactMatch) { 
            "Use as is" 
        } elseif ($potentialMatches.Count -eq 1) { 
            "Rename to $($potentialMatches[0])" 
        } elseif ($potentialMatches.Count -gt 0 -and $potentialMatches.Count -le 3) { 
            "Review matches: $($potentialMatches -join ', ')" 
        } else { 
            "Unsupported by RetroBar"
        }
        
        # Skip if too many potential matches (to avoid confusion)
        if ($potentialMatches.Count -gt 3) {
            $potentialMatches = @("Too many matches - review manually")
        }
    }
    
    # Add to our tracking table
    $systemTable += [PSCustomObject]@{
        SourceFolder = $folderName
        ExactMatch = $exactMatch
        PotentialMatches = ($potentialMatches -join ", ")
        RecommendedAction = $recommendedAction
    }
}

# Display results
Write-Host "`nResults for unsupported systems:" -ForegroundColor Cyan
$systemTable | Format-Table -AutoSize

# Ask if user wants to rename folders with clear matches
$renameAny = Read-Host "Would you like to rename folders with clear matches? (Y/N)"
if ($renameAny -eq "Y" -or $renameAny -eq "y") {
    foreach ($system in $systemTable) {
        if ($system.RecommendedAction -like "Rename to*") {
            $targetName = ($system.RecommendedAction -replace "Rename to ", "").Trim()
            $sourceFolder = Join-Path -Path $unsupportedPath -ChildPath $system.SourceFolder
            $targetFolder = Join-Path -Path $unsupportedPath -ChildPath $targetName
            
            Write-Host "Renaming '$($system.SourceFolder)' to '$targetName'" -ForegroundColor Yellow
            
            # Check if target already exists
            if (Test-Path $targetFolder) {
                Write-Host "Target folder '$targetName' already exists. Skipping." -ForegroundColor Red
                continue
            }
            
            # Rename the folder
            Rename-Item -Path $sourceFolder -NewName $targetName -ErrorAction SilentlyContinue
            
            if ($?) {
                Write-Host "Successfully renamed to '$targetName'" -ForegroundColor Green
            } else {
                Write-Host "Failed to rename the folder '$($system.SourceFolder)'" -ForegroundColor Red
            }
        }
    }
}

Write-Host "`nTo move these folders to RetroBar, use this script as a starting point." -ForegroundColor Cyan
Write-Host "Remember to manually confirm compatibility before moving!" -ForegroundColor Yellow 