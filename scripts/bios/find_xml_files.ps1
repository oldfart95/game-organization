# Script to find MAME XML files extracted from BIOS archives
# This helps locate where all the XML files were placed

param(
    [string]$rootPath = "D:\",
    [switch]$deleteFiles = $false
)

# Set console width to avoid word wrapping
$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(180, 5000)

# Create the output log file
$logFile = "$PSScriptRoot\mame_xml_files_report.txt"
"MAME XML Files Report" | Out-File $logFile
"Generated on $(Get-Date)" | Out-File $logFile -Append
"----------------------------------------" | Out-File $logFile -Append
"Search Path: $rootPath" | Out-File $logFile -Append
"----------------------------------------" | Out-File $logFile -Append

Write-Host "Starting scan for MAME XML files in $rootPath..." -ForegroundColor Cyan
Write-Host "This search may take some time if scanning an entire drive..." -ForegroundColor Yellow

# Create a list of common MAME XML filenames (sampling from the console output)
$mameXmlPatterns = @(
    "*.xml"
)

$xmlFileLocations = @()
$totalFilesFound = 0
$totalSize = 0

# Recursive function to search directories
function Search-Directory {
    param (
        [string]$path
    )
    
    try {
        # Get all XML files in the current directory
        $xmlFiles = Get-ChildItem -Path $path -Filter "*.xml" -File -ErrorAction SilentlyContinue
        
        if ($xmlFiles.Count -gt 0) {
            $dirSize = ($xmlFiles | Measure-Object -Property Length -Sum).Sum
            $totalSize += $dirSize
            $totalFilesFound += $xmlFiles.Count
            
            # Record the location and file count
            $xmlFileLocations += [PSCustomObject]@{
                Directory = $path
                FileCount = $xmlFiles.Count
                TotalSize = $dirSize
            }
            
            # Output to console and log file
            $locationOutput = "Found $($xmlFiles.Count) XML files in: $path"
            Write-Host $locationOutput -ForegroundColor Green
            $locationOutput | Out-File $logFile -Append
            
            # List a sample of the files (max 5)
            $sampleFiles = $xmlFiles | Select-Object -First 5
            foreach ($file in $sampleFiles) {
                $fileOutput = "  - $($file.Name) ($(Format-FileSize -Size $file.Length))"
                Write-Host $fileOutput -ForegroundColor Gray
                $fileOutput | Out-File $logFile -Append
            }
            
            if ($xmlFiles.Count -gt 5) {
                $moreFilesOutput = "  - ... and $($xmlFiles.Count - 5) more files"
                Write-Host $moreFilesOutput -ForegroundColor Gray
                $moreFilesOutput | Out-File $logFile -Append
            }
            
            # Check if files should be deleted
            if ($deleteFiles) {
                $deleteConfirm = Read-Host "Delete all $($xmlFiles.Count) XML files in this directory? (Y/N)"
                if ($deleteConfirm -eq "Y" -or $deleteConfirm -eq "y") {
                    try {
                        $xmlFiles | Remove-Item -Force
                        $deleteOutput = "Deleted $($xmlFiles.Count) XML files from $path"
                        Write-Host $deleteOutput -ForegroundColor Yellow
                        $deleteOutput | Out-File $logFile -Append
                    }
                    catch {
                        $errorOutput = "Error deleting files: $_"
                        Write-Host $errorOutput -ForegroundColor Red
                        $errorOutput | Out-File $logFile -Append
                    }
                }
            }
        }
        
        # Check subdirectories
        $subdirs = Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue
        foreach ($dir in $subdirs) {
            Search-Directory -path $dir.FullName
        }
    }
    catch {
        $errorOutput = "Error accessing $path`: $_"
        Write-Host $errorOutput -ForegroundColor Red
        $errorOutput | Out-File $logFile -Append
    }
}

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

# Start the search
Search-Directory -path $rootPath

# Output summary
$summaryOutput = "`n----------------------------------------"
$summaryOutput += "`nSummary:"
$summaryOutput += "`n  Total Locations: $($xmlFileLocations.Count)"
$summaryOutput += "`n  Total XML Files: $totalFilesFound"
$summaryOutput += "`n  Total Size: $(Format-FileSize -Size $totalSize)"
$summaryOutput += "`n----------------------------------------"

Write-Host $summaryOutput -ForegroundColor Cyan
$summaryOutput | Out-File $logFile -Append

# Sort locations by file count and show top locations
if ($xmlFileLocations.Count -gt 0) {
    $topLocations = $xmlFileLocations | Sort-Object -Property FileCount -Descending | Select-Object -First 5
    
    $topLocationsOutput = "`nTop Locations by File Count:"
    foreach ($location in $topLocations) {
        $topLocationsOutput += "`n  $($location.Directory) - $($location.FileCount) files - $(Format-FileSize -Size $location.TotalSize)"
    }
    
    Write-Host $topLocationsOutput -ForegroundColor Yellow
    $topLocationsOutput | Out-File $logFile -Append
    
    # Offer to delete all XML files from top location
    if ($topLocations.Count -gt 0 -and -not $deleteFiles) {
        $bulkDeleteConfirm = Read-Host "`nWould you like to delete ALL XML files from the location with the most files? (Y/N)"
        if ($bulkDeleteConfirm -eq "Y" -or $bulkDeleteConfirm -eq "y") {
            $topLocation = $topLocations[0].Directory
            try {
                $filesToDelete = Get-ChildItem -Path $topLocation -Filter "*.xml" -File
                $fileCount = $filesToDelete.Count
                $filesToDelete | Remove-Item -Force
                $bulkDeleteOutput = "Deleted $fileCount XML files from $topLocation"
                Write-Host $bulkDeleteOutput -ForegroundColor Yellow
                $bulkDeleteOutput | Out-File $logFile -Append
            }
            catch {
                $errorOutput = "Error in bulk delete: $_"
                Write-Host $errorOutput -ForegroundColor Red
                $errorOutput | Out-File $logFile -Append
            }
        }
    }
}

Write-Host "`nSearch complete. Report saved to: $logFile" -ForegroundColor Green

# Show command example for future use
Write-Host "`nTo scan a specific drive or path in the future, use:" -ForegroundColor Cyan
Write-Host ".\find_xml_files.ps1 -rootPath `"C:\YourPath`"" -ForegroundColor White
Write-Host "`nTo scan with delete option:" -ForegroundColor Cyan
Write-Host ".\find_xml_files.ps1 -rootPath `"C:\YourPath`" -deleteFiles" -ForegroundColor White 