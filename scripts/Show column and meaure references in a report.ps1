# Be användaren mata in sökvägen till JSON-filen

# Ange rotmappen där "definition\pages" finns
$rootFolder = ""

# Hitta alla visual.json-filer i undermappar
$visualFiles = Get-ChildItem -Path $rootFolder -Recurse -Filter "visual.json"

# Lista för att spara alla resultat
$allQueryRefs = @()

foreach ($file in $visualFiles) {
    try {
        # Läs och konvertera JSON
        $jsonContent = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json

        # Hämta name från filen
        $visualName = $jsonContent.name

        # Hämta projections
        $projections = $jsonContent.visual.query.queryState.Values.projections

        foreach ($projection in $projections) {
            $queryRef = $projection.queryRef
            if ($queryRef) {
                $allQueryRefs += [PSCustomObject]@{
                    name     = $visualName
                    queryRef = $queryRef
                }
            }
        }
    }
    catch {
        Write-Host "Fel vid behandling av fil: $($file.FullName)" -ForegroundColor Red
    }
}

# Visa resultatet
$allQueryRefs