# Script to organize files into folders
# Created by Claude Sonnet for file organization

# Function to create a directory if it doesn't exist
function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
        Write-Host "Created directory: $Path" -ForegroundColor Green
    }
}

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

# Define file mappings
$fileMappings = @{
    "$scriptRoot\scripts\bios" = @(
        "$scriptRoot\move_bios_files.ps1",
        "$scriptRoot\check_unsupported_systems.ps1",
        "$scriptRoot\unsupported_systems.txt",
        "$scriptRoot\update_bios_mapping.ps1"
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
        "$scriptRoot\organize_bios.ps1"
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

# Move the bios_organization folder contents to scripts\bios\organization
$biosOrgSource = "$scriptRoot\bios_organization"
$biosOrgDest = "$scriptRoot\scripts\bios\organization"

if (Test-Path $biosOrgSource) {
    Ensure-Directory -Path $biosOrgDest
    
    # Get all items in the bios_organization folder
    $items = Get-ChildItem -Path $biosOrgSource -Recurse
    
    foreach ($item in $items) {
        $relativePath = $item.FullName.Substring($biosOrgSource.Length)
        $destPath = Join-Path $biosOrgDest $relativePath
        
        if ($item.PSIsContainer) {
            # Create the directory
            Ensure-Directory -Path $destPath
        }
        else {
            # Copy the file
            Copy-Item -Path $item.FullName -Destination $destPath -Force
            Write-Host "Copied: $($item.Name) to $destPath" -ForegroundColor Cyan
        }
    }
}
else {
    Write-Host "bios_organization folder not found" -ForegroundColor Yellow
}

# Copy documentation files
Copy-Item -Path "$scriptRoot\Bioses.md" -Destination "$scriptRoot\scripts\bios\" -Force
Copy-Item -Path "$scriptRoot\README_bios_organization.md" -Destination "$scriptRoot\scripts\bios\" -Force

Write-Host "`nFile organization complete!" -ForegroundColor Green
Write-Host "All scripts have been copied to their respective folders." -ForegroundColor Green
Write-Host "Original files remain in the root directory." -ForegroundColor Yellow
Write-Host "If everything looks good, you can delete the original files." -ForegroundColor Yellow 