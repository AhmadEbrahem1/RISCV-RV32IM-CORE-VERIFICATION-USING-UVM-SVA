# PowerShell Script to Create Empty .sv Files for RISC-V Load Instructions (Current Directory)
# Skips creation if file already exists

# List of load instructions in RISC-V
$loadInstructions = @(
    "BEQ", "BNE", "BLT", "BGE", "BLTU",
    "BGEU" 
)

# Counter for created files
$filesCreated = 0
$filesSkipped = 0

# Create empty .sv files for each instruction
foreach ($instruction in $loadInstructions) {
    $fileName = "$($instruction)_sequence.sv"
    
    if (Test-Path -Path $fileName) {
        Write-Host "File already exists: $fileName (skipped)"
        $filesSkipped++
    }
    else {
        New-Item -ItemType File -Path $fileName -Force | Out-Null
        Write-Host "Created empty file: $fileName"
        $filesCreated++
    }
}

Write-Host "`nLoad instruction files completed:"
Write-Host "- Files created: $filesCreated"
Write-Host "- Files skipped (already existed): $filesSkipped"
Write-Host "Total load instructions processed: $($loadInstructions.Count)"