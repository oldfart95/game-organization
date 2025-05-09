# Script to locate extracted BIOS files and report on disk space usage
# This helps identify where files have been placed and how much space they're using

param(
    [string]$searchPath = "D:\RetroBat\bios",
    [switch]$includeXml = $false,
    [switch]$detailed = $false
)

# Function to format file size in a human-readable format
function Format-FileSize {
    param(
        [long]$Size
    )
    
    if ($Size -ge 1TB) { return "{0:N2} TB" -f ($Size / 1TB) }
    elseif ($Size -ge 1GB) { return "{0:N2} GB" -f ($Size / 1GB) }
    elseif ($Size -ge 1MB) { return "{0:N2} MB" -f ($Size / 1MB) }
    elseif ($Size -ge 1KB) { return "{0:N2} KB" -f ($Size / 1KB) }
    else { return "$Size Bytes" }
}

# Create the output log file
$logFile = "$PSScriptRoot\extracted_files_report.txt"
"Extracted BIOS Files Report" | Out-File $logFile
"Generated on $(Get-Date)" | Out-File $logFile -Append
"----------------------------------------" | Out-File $logFile -Append
"Search Path: $searchPath" | Out-File $logFile -Append
"----------------------------------------" | Out-File $logFile -Append

Write-Host "Starting scan of $searchPath..." -ForegroundColor Cyan

# Check if the search path exists
if (-not (Test-Path $searchPath)) {
    $errorMsg = "Error: Path $searchPath does not exist."
    Write-Host $errorMsg -ForegroundColor Red
    $errorMsg | Out-File $logFile -Append
    exit
}

# Scan for all files recursively
try {
    Write-Host "Scanning for files. This may take a moment..." -ForegroundColor Yellow
    if ($includeXml) {
        $files = Get-ChildItem -Path $searchPath -Recurse -File
    } else {
        $files = Get-ChildItem -Path $searchPath -Recurse -File | Where-Object { $_.Extension -ne ".xml" }
    }
    
    # Group files by directory
    $groupedFiles = $files | Group-Object -Property DirectoryName
    
    # Initialize statistics
    $totalSize = 0
    $totalFiles = $files.Count
    $totalDirectories = $groupedFiles.Count
    
    # Report on each directory
    foreach ($group in $groupedFiles | Sort-Object -Property Name) {
        $dirSize = ($group.Group | Measure-Object -Property Length -Sum).Sum
        $totalSize += $dirSize
        
        # Output to console and log file
        $dirOutput = "Directory: $($group.Name)"
        $dirOutput += "`n  Files: $($group.Count)"
        $dirOutput += "`n  Size: $(Format-FileSize -Size $dirSize)"
        
        Write-Host $dirOutput -ForegroundColor Green
        $dirOutput | Out-File $logFile -Append
        
        # If detailed is requested, list all files in each directory
        if ($detailed) {
            foreach ($file in $group.Group | Sort-Object -Property Name) {
                $fileOutput = "  - $($file.Name) ($(Format-FileSize -Size $file.Length))"
                Write-Host $fileOutput -ForegroundColor Gray
                $fileOutput | Out-File $logFile -Append
            }
            "`n" | Out-File $logFile -Append
        }
    }
    
    # Output summary
    $summaryOutput = "`n----------------------------------------"
    $summaryOutput += "`nSummary:"
    $summaryOutput += "`n  Total Directories: $totalDirectories"
    $summaryOutput += "`n  Total Files: $totalFiles"
    $summaryOutput += "`n  Total Size: $(Format-FileSize -Size $totalSize)"
    $summaryOutput += "`n----------------------------------------"
    
    Write-Host $summaryOutput -ForegroundColor Cyan
    $summaryOutput | Out-File $logFile -Append
    
    # Identify largest directories (top 5)
    $topDirs = $groupedFiles | Sort-Object { ($_.Group | Measure-Object -Property Length -Sum).Sum } -Descending | Select-Object -First 5
    
    $topDirsOutput = "`nLargest Directories:"
    foreach ($dir in $topDirs) {
        $dirSize = ($dir.Group | Measure-Object -Property Length -Sum).Sum
        $topDirsOutput += "`n  $($dir.Name) - $(Format-FileSize -Size $dirSize)"
    }
    
    Write-Host $topDirsOutput -ForegroundColor Yellow
    $topDirsOutput | Out-File $logFile -Append
    
    # Identify largest files (top 10)
    $topFiles = $files | Sort-Object -Property Length -Descending | Select-Object -First 10
    
    $topFilesOutput = "`nLargest Files:"
    foreach ($file in $topFiles) {
        $topFilesOutput += "`n  $($file.FullName) - $(Format-FileSize -Size $file.Length)"
    }
    
    Write-Host $topFilesOutput -ForegroundColor Yellow
    $topFilesOutput | Out-File $logFile -Append
    
    # Identify file types by extension
    $fileTypes = $files | Group-Object -Property Extension | Sort-Object -Property Count -Descending
    
    $fileTypesOutput = "`nFile Types:"
    foreach ($type in $fileTypes) {
        $typeSize = ($type.Group | Measure-Object -Property Length -Sum).Sum
        $fileTypesOutput += "`n  $($type.Name) - $($type.Count) files - $(Format-FileSize -Size $typeSize)"
    }
    
    Write-Host $fileTypesOutput -ForegroundColor Yellow
    $fileTypesOutput | Out-File $logFile -Append
    
}
catch {
    $errorMsg = "Error scanning files: $_"
    Write-Host $errorMsg -ForegroundColor Red
    $errorMsg | Out-File $logFile -Append
}

Write-Host "`nScan complete. Report saved to: $logFile" -ForegroundColor Green

# Offer to open the folder
$openLogFolder = Read-Host "Would you like to open the report file? (Y/N)"
if ($openLogFolder -eq "Y" -or $openLogFolder -eq "y") {
    Invoke-Item (Split-Path -Parent $logFile)
}

# Offer to clean up space
$cleanupSpace = Read-Host "Would you like suggestions for cleaning up disk space? (Y/N)"
if ($cleanupSpace -eq "Y" -or $cleanupSpace -eq "y") {
    $cleanupOutput = "`n----------------------------------------"
    $cleanupOutput += "`nDisk Space Cleanup Suggestions:"
    $cleanupOutput += "`n----------------------------------------"
    
    # Check for large XML directories
    $xmlDirs = $groupedFiles | Where-Object { $_.Group | Where-Object { $_.Extension -eq ".xml" } } | 
               Sort-Object { ($_.Group | Where-Object { $_.Extension -eq ".xml" } | Measure-Object -Property Length -Sum).Sum } -Descending | 
               Select-Object -First 3
    
    if ($xmlDirs.Count -gt 0) {
        $cleanupOutput += "`n`nLarge XML file directories that could be removed:"
        foreach ($dir in $xmlDirs) {
            $xmlFiles = $dir.Group | Where-Object { $_.Extension -eq ".xml" }
            $xmlSize = ($xmlFiles | Measure-Object -Property Length -Sum).Sum
            if ($xmlSize -gt 1MB) {
                $cleanupOutput += "`n  $($dir.Name) - $(Format-FileSize -Size $xmlSize)"
            }
        }
    }
    
    # Check for duplicate folders (same system BIOS in multiple locations)
    $systemDirs = $groupedFiles | ForEach-Object { Split-Path -Leaf $_.Name } | Group-Object
    $duplicateSystems = $systemDirs | Where-Object { $_.Count -gt 1 }
    
    if ($duplicateSystems.Count -gt 0) {
        $cleanupOutput += "`n`nPossible duplicate system folders:"
        foreach ($system in $duplicateSystems) {
            $cleanupOutput += "`n  $($system.Name) found in $($system.Count) locations"
        }
    }
    
    # Suggest running the cleanup script
    $cleanupOutput += "`n`nRecommendations:"
    $cleanupOutput += "`n  1. Consider running the unzip_bios_files.ps1 script with the -skipXml option."
    $cleanupOutput += "`n  2. Review and remove duplicate system folders."
    $cleanupOutput += "`n  3. Check the 'unknown' folder for files that may not be needed."
    
    Write-Host $cleanupOutput -ForegroundColor Yellow
    $cleanupOutput | Out-File $logFile -Append
}

Write-Host "`nUse this command to run a detailed report in the future:" -ForegroundColor Cyan
Write-Host ".\find_extracted_files.ps1 -searchPath `"$searchPath`" -detailed" -ForegroundColor White 