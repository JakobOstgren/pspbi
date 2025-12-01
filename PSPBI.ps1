
# Define the folder where your scripts are stored
$scriptFolder = ".\scripts"

# Load configuration file
$parameters = Get-Content -Path ".\configuration-file.json" -Raw | ConvertFrom-Json

# Define categories and order
$categories = @{
    "Administration" = @(
        "Log in using Entra account.ps1",
        "Get token using Entra account.ps1",
        "Get token using registred app.ps1"
    )
}

# Initialize counter
$counter = 1
$menu = @()

foreach ($category in $categories.Keys) {
    Write-Host "-- $category --"
    foreach ($scriptName in $categories[$category]) {
        $scriptPath = Join-Path $scriptFolder $scriptName
        if (Test-Path $scriptPath) {
            Write-Host "$counter. $scriptName"
            $menu += $scriptPath
            $counter++
        }
    }
    Write-Host ""
}

# Prompt for selection
$selection = Read-Host "Enter the number of the script you want to run"

if ([int]::TryParse($selection, [ref]$null)) {
    $selection = [int]$selection
    if ($selection -ge 1 -and $selection -le $menu.Count) {
        $selectedScript = $menu[$selection - 1]
        Write-Host "Running $selectedScript..."
        
        # ✅ Pass parameters to the selected script
        & $selectedScript -parameters $parameters
    } else {
        Write-Host "Invalid selection: number out of range."
    }
} else {
    Write-Host "Invalid selection: not a number."
}