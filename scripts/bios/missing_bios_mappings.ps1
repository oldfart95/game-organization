 # Missing BIOS Mappings
# This file contains mappings for previously unmapped BIOS files
# Add these to your mapping scripts (analyze_bios_files.ps1, move_bios_files.ps1, and update_bios_mapping.ps1)

# Add these mappings to the hashtable in each script:

# ZX Spectrum additions
"128p-0.rom" = "zxspectrum"
"128p-1.rom" = "zxspectrum"
"256s-0.rom" = "zxspectrum"
"256s-1.rom" = "zxspectrum"
"256s-2.rom" = "zxspectrum"
"256s-3.rom" = "zxspectrum"
"disk_plus3.szx" = "zxspectrum"
"gluck.rom" = "zxspectrum"
"if1-1.rom" = "zxspectrum"
"if1-2.rom" = "zxspectrum"
"se-0.rom" = "zxspectrum"
"se-1.rom" = "zxspectrum"
"speccyboot-1.4.rom" = "zxspectrum"
"tc2048.rom" = "zxspectrum"
"tc2068-0.rom" = "zxspectrum"
"tc2068-1.rom" = "zxspectrum"
"trdos.rom" = "zxspectrum"

# PC-98 additions
"NEC - PC-98_2608_bd.wav" = "pc98"
"NEC - PC-98_2608_hh.wav" = "pc98"
"NEC - PC-98_2608_rim.wav" = "pc98"
"NEC - PC-98_2608_sd.wav" = "pc98"
"NEC - PC-98_2608_tom.wav" = "pc98"
"NEC - PC-98_2608_top.wav" = "pc98"

# Sega Saturn additions
"mpr-18811-mx.ic1" = "saturn"
"mpr-19367-mx.ic1" = "saturn"

# 3DO addition
"sanyotry.bin" = "3do"

# PlayStation 2 addition
"ps2-bios-all-bios.zip" = "ps2"

# Documentation (can be ignored)
"Bioses.md" = "ignore"

# ------------------------------------------
# INSTRUCTIONS:
# 1. Add these mappings to the $biosMapping hashtable in:
#    - analyze_bios_files.ps1
#    - move_bios_files.ps1
#    - update_bios_mapping.ps1 (in the $defaultMappings section)
#
# 2. Run analyze_bios_files.ps1 again to verify the mappings work
#
# 3. Run move_bios_files.ps1 to organize your files
# ------------------------------------------

# Alternative pattern-based approach:
# You can also use these more general patterns to catch similar files:
# "128p-*.rom" = "zxspectrum"
# "256s-*.rom" = "zxspectrum"
# "if1-*.rom" = "zxspectrum"
# "se-*.rom" = "zxspectrum"
# "tc2068-*.rom" = "zxspectrum"
# "NEC - PC-98_*.wav" = "pc98"
# "mpr-*-mx.ic1" = "saturn"