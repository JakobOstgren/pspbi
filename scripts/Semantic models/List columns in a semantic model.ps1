# Be användaren mata in sökvägen till filen
$filePath = ""
#Read-Host "Ange sökvägen till filen som innehåller kolumnerna"

# Kontrollera att filen finns
if (-Not (Test-Path -Path $filePath)) {
    Write-Host "Filen hittades inte. Kontrollera sökvägen och försök igen." -ForegroundColor Red
    exit
}

# Läs in filens innehåll
$fileContent = Get-Content -Path $filePath

# Extrahera rader som innehåller "column <kolumnnamn>"
$columns = @()
foreach ($line in $fileContent) {
    $trimmedLine = $line.Trim()
    if ($trimmedLine -match '^column\s+([^\s]+)') {
        $columns += $matches[1]
    }
}

# Kontrollera om några kolumner hittades
if ($columns.Count -eq 0) {
    Write-Host "Inga kolumner hittades. Kontrollera att filen innehåller rader som börjar med 'column <namn>'." -ForegroundColor Yellow
} else {
    Write-Host "Kolumner i filen:" -ForegroundColor Cyan
    $columns
}