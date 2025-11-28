# MasterScript.ps1
# Define the folder where your scripts are stored
$scriptFolder = ".\scripts"

# Get all .ps1 files
$scripts = Get-ChildItem -Path $scriptFolder -Filter *.ps1

# Display menu
Write-Host "Available Scripts:"
for ($i = 0; $i -lt $scripts.Count; $i++) {
    Write-Host "$($i + 1). $($scripts[$i].Name)"
}

# Prompt for selection
$selection = Read-Host "Enter the number of the script you want to run"

# Convert to integer safely
if ([int]::TryParse($selection, [ref]$null)) {
    $selection = [int]$selection
    if ($selection -ge 1 -and $selection -le $scripts.Count) {
        $selectedScript = $scripts[$selection - 1].FullName
        Write-Host "Running $selectedScript..."
        & $selectedScript
    } else {
        Write-Host "Invalid selection: number out of range."
    }
} else {
    Write-Host "Invalid selection: not a number."
}