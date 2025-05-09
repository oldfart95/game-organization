# Script to organize BIOS files from LibretroBIOS to RetroBat
# Creates a working directory for processing

# Define paths
$libretroBiosPath = "D:\LibretroBIOS"
$retroBatBiosPath = "D:\RetroBat\bios"
$workingDirPath = "$PSScriptRoot\bios_organization"

# Create working directory if it doesn't exist
if (-not (Test-Path $workingDirPath)) {
    New-Item -Path $workingDirPath -ItemType Directory -Force | Out-Null
    Write-Host "Created working directory at $workingDirPath" -ForegroundColor Green
}

# Check if source path exists
if (-not (Test-Path $libretroBiosPath)) {
    Write-Host "LibretroBIOS folder not found at $libretroBiosPath" -ForegroundColor Red
    exit
}

# Check if destination path exists
if (-not (Test-Path $retroBatBiosPath)) {
    Write-Host "RetroBat BIOS folder not found at $retroBatBiosPath" -ForegroundColor Red
    exit
}

# First, list all files in the LibretroBIOS folder and save to file
$libretroBiosFiles = Get-ChildItem -Path $libretroBiosPath -Recurse -File
Write-Host "Found $($libretroBiosFiles.Count) files in LibretroBIOS folder." -ForegroundColor Cyan
$libretroBiosFiles | Select-Object FullName, Length, LastWriteTime | Export-Csv -Path "$workingDirPath\libretro_bios_files.csv" -NoTypeInformation

# Then, list all files in the RetroBat BIOS folder and save to file
$retroBatBiosFiles = Get-ChildItem -Path $retroBatBiosPath -Recurse -File
Write-Host "Found $($retroBatBiosFiles.Count) files in RetroBat BIOS folder." -ForegroundColor Cyan
$retroBatBiosFiles | Select-Object FullName, Length, LastWriteTime | Export-Csv -Path "$workingDirPath\retrobat_bios_files.csv" -NoTypeInformation

# List directories in RetroBat BIOS folder to see platform structure
$retroBatBiosFolders = Get-ChildItem -Path $retroBatBiosPath -Directory
Write-Host "`nRetroBat BIOS folder structure:" -ForegroundColor Cyan
$retroBatBiosFolders | ForEach-Object {
    Write-Host "- $($_.Name)" -ForegroundColor Yellow
}

# Print instructions for next step
Write-Host "`nFiles have been cataloged. Run analyze_bios_files.ps1 next to organize the files." -ForegroundColor Cyan 