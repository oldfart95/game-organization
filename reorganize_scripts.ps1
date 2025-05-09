# Corrected script to organize files into folders
# Created by Claude Sonnet for file organization

# Function to create a directory if it doesn't exist
function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
        Write-Host "Created directory: $Path" -ForegroundColor Green
    }
}

# First, clean up the incorrectly copied files
Write-Host "Cleaning up incorrectly organized files..." -ForegroundColor Yellow
Remove-Item -Path ".\scripts\bios\move_japan_roms.ps1" -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".\scripts\bios\move_japan_usa_back.ps1" -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".\scripts\bios\move_pcengine_japan.ps1" -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".\scripts\bios\move_to_retrobat.ps1" -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".\scripts\bios\move_to_retrobat_parallel.ps1" -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".\scripts\bios\rename_folders.ps1" -Force -ErrorAction SilentlyContinue

# Create the necessary directories
$scriptRoot = $PSScriptRoot
$directories = @(
    "$scriptRoot\scripts\bios",
    "$scriptRoot\scripts\rom_management",
    "$scriptRoot\scripts\retrobat",
    "$scriptRoot\scripts\utilities"
)

foreach ($dir in $directories) {
    Ensure-Directory -Path $dir
}

# Define the correct file mappings
$fileMappings = @{
    "$scriptRoot\scripts\bios" = @(
        "$scriptRoot\check_unsupported_systems.ps1",
        "$scriptRoot\unsupported_systems.txt", 
        "$scriptRoot\update_bios_mapping.ps1",
        "$scriptRoot\move_bios_files.ps1"
    )
    
    "$scriptRoot\scripts\rom_management" = @(
        "$scriptRoot\move_japan_roms.ps1",
        "$scriptRoot\move_japan_usa_back.ps1",
        "$scriptRoot\move_pcengine_japan.ps1"
    )
    
    "$scriptRoot\scripts\retrobat" = @(
        "$scriptRoot\move_to_retrobat.ps1",
        "$scriptRoot\move_to_retrobat_parallel.ps1"
    )
    
    "$scriptRoot\scripts\utilities" = @(
        "$scriptRoot\rename_folders.ps1",
        "$scriptRoot\organize_scripts.ps1"
    )
}

# Copy files to their respective directories
foreach ($destination in $fileMappings.Keys) {
    foreach ($file in $fileMappings[$destination]) {
        if (Test-Path $file) {
            $fileName = Split-Path $file -Leaf
            $destinationPath = Join-Path $destination $fileName
            
            # Copy the file
            Copy-Item -Path $file -Destination $destinationPath -Force
            Write-Host "Copied: $fileName to $destination" -ForegroundColor Cyan
        }
        else {
            Write-Host "File not found: $file" -ForegroundColor Yellow
        }
    }
}

# Copy the main script into root scripts folder as well
Copy-Item -Path "$scriptRoot\organize_scripts.ps1" -Destination "$scriptRoot\scripts\" -Force -ErrorAction SilentlyContinue
Copy-Item -Path "$scriptRoot\reorganize_scripts.ps1" -Destination "$scriptRoot\scripts\" -Force -ErrorAction SilentlyContinue

# Copy this reorganization script to the scripts folder
$thisScript = $MyInvocation.MyCommand.Path
$thisScriptName = Split-Path $thisScript -Leaf
Copy-Item -Path $thisScript -Destination "$scriptRoot\scripts\" -Force -ErrorAction SilentlyContinue

Write-Host "`nFile reorganization complete!" -ForegroundColor Green
Write-Host "All scripts have been copied to their respective folders." -ForegroundColor Green
Write-Host "The bios_organization folder was already correctly moved." -ForegroundColor Green
Write-Host "Please review the organization to ensure it meets your requirements." -ForegroundColor Yellow 