Import-Module MicrosoftPowerBIMgmt

# Logga in om det behövs
if (-not (Get-PowerBIAccessToken)) {
    Login-PowerBI
}

# === Hämta och sortera arbetsytor ===
$workspaces = Get-PowerBIWorkspace -All | Sort-Object Name

function Välj-Arbetsyta($promptText) {
    Write-Host "`n$promptText"
    for ($i = 0; $i -lt $workspaces.Count; $i++) {
        Write-Host "$($i+1): $($workspaces[$i].Name)"
    }
    do {
        $selection = Read-Host "Ange siffran för arbetsytan"
        $workspace = $workspaces[[int]$selection - 1]
        if (-not $workspace) {
            Write-Host "Ogiltigt val, försök igen."
        }
    } until ($workspace)
    return $workspace
}

# === 1. Välj mål-arbetsyta ===
$targetWorkspace = Välj-Arbetsyta "Välj arbetsyta dit rapporterna ska kopieras:"

# === 2. Välj semantisk modell ===
$datasets = @()

# ====== För varje arbetsyta, hämta varje semantisk modell däri ======
foreach ($ws in $workspaces) {
    $wsDatasets = Get-PowerBIDataset -WorkspaceId $ws.Id
    foreach ($ds in $wsDatasets) {
        $datasets += [PSCustomObject]@{
            DatasetName   = $ds.Name
            DatasetId     = $ds.Id
            WorkspaceId   = $ws.Id
            WorkspaceName = $ws.Name
        }
    }
}

# ====== Sortera resultatet ======
$sortedDatasets = $datasets | Sort-Object WorkspaceName, DatasetName
$indexedDatasets = @()

# ====== Lista resultatet ======
for ($i = 0; $i -lt $sortedDatasets.Count; $i++) {
    $indexedDatasets += $sortedDatasets[$i] | Select-Object @{Name="Index";Expression={$i+1}}, DatasetName, DatasetId, WorkspaceId, WorkspaceName
}
Write-Host "`nVälj semantisk modell som de nya rapporterna ska använda:"
foreach ($ds in $indexedDatasets) {
    Write-Host "$($ds.Index): $($ds.DatasetName) (Arbetsyta: $($ds.WorkspaceName))"
}
do {
    $modelSelection = Read-Host "`nAnge siffran för den modell du vill använda och tryck enter"
    $selectedModel = $indexedDatasets | Where-Object { $_.Index -eq [int]$modelSelection }
    if (-not $selectedModel) {
        Write-Host "Ogiltigt val, försök igen."
    }
} until ($selectedModel)

# === 3. Välj källarbetsyta ===
$sourceWorkspace = Välj-Arbetsyta "Tillgängliga arbetsytor (källa för rapporter):"

# === 4. Välj rapporter att kopiera ===
$reports = Get-PowerBIReport -WorkspaceId $sourceWorkspace.Id | Sort-Object Name
if ($reports.Count -eq 0) {
    Write-Host "Inga rapporter hittades i arbetsytan."
    exit
}
Write-Host "`nTillgängliga rapporter:"
for ($i = 0; $i -lt $reports.Count; $i++) {
    Write-Host "$($i+1): $($reports[$i].Name)"
}

$selectedReports = @()
while ($true) {
    $reportSelection = Read-Host "Ange siffran för en rapport att kopiera (tryck Enter för att avsluta)"
    if ([string]::IsNullOrWhiteSpace($reportSelection)) {
        break
    }
    $report = $reports[[int]$reportSelection - 1]
    if ($report) {
        $selectedReports += $report
    } else {
        Write-Host "Ogiltigt val, försök igen."
    }
}

# === 5. Kopiera rapporter ===
foreach ($report in $selectedReports) {
    Write-Host "`nKopierar rapport: $($report.Name)"
    try {
        Copy-PowerBIReport -Name $report.Name `
                           -Id $report.Id `
                           -WorkspaceId $sourceWorkspace.Id `
                           -TargetWorkspaceId $targetWorkspace.Id `
                           -TargetDatasetId $selectedModel.DatasetId
        Write-Host "Rapport kopierad: $($report.Name)"
    } catch {
        Write-Host "Fel vid kopiering av rapport: $($report.Name) - $_"
    }
}