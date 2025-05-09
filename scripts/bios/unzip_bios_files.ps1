# Script to unzip BIOS files in a specified location
# This script extracts zip files and places the contents in appropriate system folders

# Define default paths (can be overridden by parameters)
param(
    [string]$biosPath = "D:\RetroBat\bios",
    [string]$workingDirPath = "$PSScriptRoot\bios_organization"
)

# Load the System.IO.Compression.FileSystem assembly for zip handling
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Create known BIOS system mapping
# This table maps known BIOS files to their correct system folders
$biosMapping = @{
    # 3DO
    "panafz*.bin" = "3do"
    "goldstar.bin" = "3do"
    "3do_arcade_saot.bin" = "3do"
    "sanyotry.bin" = "3do"
    
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
    
    # PlayStation 2
    "ps2-bios-all-bios.zip" = "ps2"
    
    # ScummVM
    "scummvm.zip" = "scummvm"
    
    # MAME XML files
    "*.xml" = "mame/xml"
    
    # Default root directory for unknown files
    "default" = "unknown"
}

# Function to determine the destination folder for a file
function Get-DestinationFolder {
    param(
        [string]$fileName
    )
    
    # Check file extension first
    $extension = [System.IO.Path]::GetExtension($fileName).ToLower()
    
    # Special handling for XML files - these are likely MAME game data files, not actual BIOS files
    if ($extension -eq ".xml") {
        return "mame/xml"
    }
    
    foreach ($pattern in $biosMapping.Keys) {
        if ($pattern -eq "default") { continue }
        
        if ($fileName -like $pattern) {
            return $biosMapping[$pattern]
        }
    }
    
    # Return default if no match found
    return $biosMapping["default"]
}

# Function to extract zip files
function Extract-ZipFile {
    param(
        [string]$zipFilePath,
        [string]$extractPath
    )
    
    try {
        Write-Host "Extracting zip file: $zipFilePath to $extractPath" -ForegroundColor Cyan
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFilePath, $extractPath)
        return $true
    }
    catch {
        Write-Host "Error extracting zip file $zipFilePath`: $_" -ForegroundColor Red
        "ERROR: Failed to extract $zipFilePath - $_" | Out-File $logFile -Append
        return $false
    }
}

# Check if paths exist
if (-not (Test-Path $biosPath)) {
    Write-Host "BIOS folder not found at $biosPath" -ForegroundColor Red
    exit
}

# Create working directory if it doesn't exist
if (-not (Test-Path $workingDirPath)) {
    New-Item -Path $workingDirPath -ItemType Directory -Force | Out-Null
    Write-Host "Created working directory: $workingDirPath" -ForegroundColor Yellow
}

# Create a special folder for unmapped files
$unknownPath = Join-Path -Path $biosPath -ChildPath $biosMapping["default"]
if (-not (Test-Path $unknownPath)) {
    New-Item -Path $unknownPath -ItemType Directory -Force | Out-Null
    Write-Host "Created folder for unmapped files: $unknownPath" -ForegroundColor Yellow
}

# Create MAME XML folder
$mameXmlPath = Join-Path -Path $biosPath -ChildPath "mame/xml"
if (-not (Test-Path $mameXmlPath)) {
    New-Item -Path $mameXmlPath -ItemType Directory -Force | Out-Null
    Write-Host "Created folder for MAME XML files: $mameXmlPath" -ForegroundColor Yellow
}

# Create temporary folder for zip extraction
$tempExtractPath = Join-Path -Path $workingDirPath -ChildPath "temp_extract"
if (Test-Path $tempExtractPath) {
    Remove-Item -Path $tempExtractPath -Recurse -Force
}
New-Item -Path $tempExtractPath -ItemType Directory -Force | Out-Null
Write-Host "Created temporary folder for zip extraction: $tempExtractPath" -ForegroundColor Yellow

# Create log file
$logFile = "$workingDirPath\bios_unzip_log.txt"
"BIOS Files Extraction Log" | Out-File $logFile
"Generated on $(Get-Date)" | Out-File $logFile -Append
"----------------------------------------" | Out-File $logFile -Append

# Statistics
$stats = @{
    "TotalZipFiles" = 0
    "ZipFilesExtracted" = 0
    "ExtractedFilesMoved" = 0
    "XmlFilesMoved" = 0
    "ErrorCount" = 0
}

# Add option to skip certain file types
Write-Host "This script will find zip files in $biosPath, extract them, and move the contents to appropriate folders" -ForegroundColor Cyan
Write-Host "Files will be organized according to the system mapping defined in the script." -ForegroundColor Yellow
$skipXml = Read-Host "Do you want to skip XML files? (Y/N) - These appear to be MAME game data files, not actual BIOS files"

# Ask for confirmation before proceeding
$confirmation = Read-Host "Do you want to proceed with extraction? (Y/N)"

if ($confirmation -ne "Y" -and $confirmation -ne "y") {
    Write-Host "Operation cancelled." -ForegroundColor Red
    exit
}

# Find all zip files in the BIOS folder
$zipFiles = Get-ChildItem -Path $biosPath -Recurse -Filter "*.zip"
$stats["TotalZipFiles"] = $zipFiles.Count

Write-Host "Found $($stats["TotalZipFiles"]) zip files in the BIOS directory" -ForegroundColor Cyan

foreach ($zipFile in $zipFiles) {
    Write-Host "Processing zip file: $($zipFile.Name)" -ForegroundColor Yellow
    
    # Create extraction folder for this zip
    $extractFolder = Join-Path -Path $tempExtractPath -ChildPath $zipFile.BaseName
    New-Item -Path $extractFolder -ItemType Directory -Force | Out-Null
    
    if (Extract-ZipFile -zipFilePath $zipFile.FullName -extractPath $extractFolder) {
        $stats["ZipFilesExtracted"]++
        "EXTRACTED: $($zipFile.FullName) to $extractFolder" | Out-File $logFile -Append
        
        # Process each extracted file
        $extractedFiles = Get-ChildItem -Path $extractFolder -Recurse -File
        
        if ($extractedFiles.Count -eq 0) {
            Write-Host "No files found in the zip archive: $($zipFile.Name)" -ForegroundColor Yellow
            "WARNING: No files found in $($zipFile.FullName)" | Out-File $logFile -Append
            continue
        }
        
        foreach ($extractedFile in $extractedFiles) {
            # Check if this is an XML file and we want to skip it
            if ($skipXml -eq "Y" -or $skipXml -eq "y") {
                if ([System.IO.Path]::GetExtension($extractedFile.Name).ToLower() -eq ".xml") {
                    Write-Host "Skipping XML file: $($extractedFile.Name)" -ForegroundColor Gray
                    "SKIPPED (XML): $($extractedFile.FullName)" | Out-File $logFile -Append
                    continue
                }
            }
            
            $extractedDestFolder = Get-DestinationFolder -fileName $extractedFile.Name
            $extractedDestPath = Join-Path -Path $biosPath -ChildPath $extractedDestFolder
            
            # Create destination folder if it doesn't exist
            if (-not (Test-Path $extractedDestPath)) {
                New-Item -Path $extractedDestPath -ItemType Directory -Force | Out-Null
                Write-Host "Created folder: $extractedDestPath" -ForegroundColor Yellow
            }
            
            $extractedDestFile = Join-Path -Path $extractedDestPath -ChildPath $extractedFile.Name
            
            try {
                # Check if the extracted file already exists at destination
                if (Test-Path $extractedDestFile) {
                    # Get file hash to compare if they're identical
                    $sourceHash = Get-FileHash -Path $extractedFile.FullName -Algorithm MD5
                    $destHash = Get-FileHash -Path $extractedDestFile -Algorithm MD5
                    
                    if ($sourceHash.Hash -eq $destHash.Hash) {
                        Write-Host "Skipping identical extracted file: $($extractedFile.Name)" -ForegroundColor Gray
                        "SKIPPED (Identical): $($extractedFile.FullName) -> $extractedDestFile" | Out-File $logFile -Append
                        continue
                    }
                    else {
                        # Rename extracted file to avoid overwriting
                        $newFileName = "$($extractedFile.BaseName)_$(Get-Date -Format 'yyyyMMddHHmmss')$($extractedFile.Extension)"
                        $extractedDestFile = Join-Path -Path $extractedDestPath -ChildPath $newFileName
                        Write-Host "File exists but different content. Renaming to: $newFileName" -ForegroundColor Yellow
                        "RENAMED: $($extractedFile.Name) -> $newFileName" | Out-File $logFile -Append
                    }
                }
                
                # Copy the extracted file to destination
                Copy-Item -Path $extractedFile.FullName -Destination $extractedDestFile -Force
                
                # Track XML files separately in statistics
                if ([System.IO.Path]::GetExtension($extractedFile.Name).ToLower() -eq ".xml") {
                    Write-Host "Moved XML file: $($extractedFile.Name) -> $extractedDestFolder" -ForegroundColor DarkYellow
                    "MOVED XML: $($extractedFile.FullName) -> $extractedDestFile" | Out-File $logFile -Append
                    $stats["XmlFilesMoved"]++
                } else {
                    Write-Host "Moved extracted file: $($extractedFile.Name) -> $extractedDestFolder" -ForegroundColor Green
                    "MOVED: $($extractedFile.FullName) -> $extractedDestFile" | Out-File $logFile -Append
                    $stats["ExtractedFilesMoved"]++
                }
            }
            catch {
                Write-Host "Error moving extracted file $($extractedFile.Name): $_" -ForegroundColor Red
                "ERROR: $($extractedFile.FullName) -> $extractedDestFile - $_" | Out-File $logFile -Append
                $stats["ErrorCount"]++
            }
        }
    }
    else {
        Write-Host "Failed to extract zip file: $($zipFile.Name)" -ForegroundColor Red
        "ERROR: Failed to extract $($zipFile.FullName)" | Out-File $logFile -Append
        $stats["ErrorCount"]++
    }
}

# Clean up temporary extraction folder
if (Test-Path $tempExtractPath) {
    Remove-Item -Path $tempExtractPath -Recurse -Force
    Write-Host "Cleaned up temporary extraction folder" -ForegroundColor Yellow
}

# Write summary to log and console
$summary = @"

Extraction Summary
----------------------------------------
Total zip files found: $($stats["TotalZipFiles"])
Zip files extracted successfully: $($stats["ZipFilesExtracted"])
Extracted files moved: $($stats["ExtractedFilesMoved"])
XML files moved: $($stats["XmlFilesMoved"])
Errors encountered: $($stats["ErrorCount"])
"@

$summary | Out-File $logFile -Append
Write-Host $summary -ForegroundColor Cyan

Write-Host "`nOperation completed. Log file saved to: $logFile" -ForegroundColor Green 