# PowerShell Script to Create Empty .sv Files for RISC-V R-type Instructions (Current Directory)
# Skips creation if file already exists

# List of R-type instructions in RISC-V
$rTypeInstructions = @(
    "SLL", "SLT", "SLTU", 
    "XOR", "SRL", "SRA", "OR", "AND",
    "MUL", "MULH", "MULHSU", "MULHU", "DIV",
    "DIVU", "REM", "REMU"
)

# Counter for created files
$filesCreated = 0
$filesSkipped = 0

# Create empty .sv files for each instruction in the current directory
foreach ($instruction in $rTypeInstructions) {
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

Write-Host "`nOperation completed:"
Write-Host "- Files created: $filesCreated"
Write-Host "- Files skipped (already existed): $filesSkipped"
Write-Host "Total R-type instructions processed: $($rTypeInstructions.Count)"