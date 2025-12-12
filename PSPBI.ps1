
<# 
Main launcher script
Ensures Power BI login once; if it fails, exits. Then shows a category menu and runs the chosen script with -Parameters.
#>

# --- Helper: ensure login ---
function Ensure-PowerBILogin {
    [CmdletBinding()]
    param(
        [switch]$DeviceLogin,
        [string]$TenantId,
        [string]$ClientId,
        [string]$ClientSecret
    )

    # Try token; if not available, connect and re-check
    try {
        Get-PowerBIAccessToken -ErrorAction Stop | Out-Null
        return
    } catch {
        Write-Verbose "No active Power BI session. Connecting..."
        if ($PSBoundParameters.ContainsKey('ClientId') -and $PSBoundParameters.ContainsKey('ClientSecret')) {
            if (-not $TenantId) { throw "TenantId is required for service principal login." }
            Connect-PowerBIServiceAccount -ServicePrincipal -Tenant $TenantId -ClientId $ClientId -ClientSecret $ClientSecret
        } elseif ($DeviceLogin.IsPresent) {
            Connect-PowerBIServiceAccount -DeviceLogin
        } else {
            Connect-PowerBIServiceAccount
        }

        try {
            Get-PowerBIAccessToken -ErrorAction Stop | Out-Null
        } catch {
            throw "Failed to acquire Power BI access token even after login: $($_.Exception.Message)"
        }
    }
}

# --- Ensure login up front ---
try {
    Ensure-PowerBILogin -Verbose
    Write-Host "✅ Power BI session verified."
} catch {
    Write-Error "❌ Login failed: $($_.Exception.Message)"
    exit 1
}

# --- Config & discovery ---
$scriptFolder = Join-Path $PSScriptRoot 'scripts'
$configPath   = Join-Path $PSScriptRoot 'configuration-file.json'
$parameters   = Get-Content -Path $configPath -Raw | ConvertFrom-Json

# Discover .ps1 files (exclude admin/login helpers if you want)
$items = Get-ChildItem -Path $scriptFolder -Recurse -File -Filter '*.ps1' |
    Where-Object {
        # Optional: skip administration helper scripts from the menu
        $_.Name -notmatch 'Ensure-PowerBILogin|Log in using Entra account'
    } |
    ForEach-Object {
        [PSCustomObject]@{
            Category = Split-Path $_.DirectoryName -Leaf
            Name     = $_.BaseName
            Path     = $_.FullName
        }
    }

if (-not $items) {
    Write-Warning "No .ps1 scripts found under '$scriptFolder'."
    exit 0
}

# Group by category and render the menu
$groups  = $items | Group-Object Category
$menu    = @()
$counter = 1

foreach ($g in $groups) {
    $category = $g.Name
    Write-Host "-- $category --"
    foreach ($i in $g.Group | Sort-Object Name) {
        Write-Host ("{0}. {1}" -f $counter, $i.Name)
        $menu += $i.Path
        $counter++
    }
    Write-Host
}

# Prompt for selection
$selection = Read-Host "Enter the number of the script you want to run"
[int]$parsed = 0
if ([int]::TryParse($selection, [ref]$parsed) -and $parsed -ge 1 -and $parsed -le $menu.Count) {
    $selectedScript = $menu[$parsed - 1]
    Write-Host "▶ Running: $selectedScript ..."
    try {
        # Call operator '&' — make sure you do NOT have HTML-escaped code
        & $selectedScript -Parameters $parameters
    } catch {
        Write-Error "Script failed: $($_.Exception.Message)"
        exit 1
    }
} else {
    Write-Warning "Invalid selection."
}