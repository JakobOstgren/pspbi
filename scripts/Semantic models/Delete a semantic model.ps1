# Ange vad för typ av objekt som ska tas bort
Write-Host "Vad för typ av objekt vill du ta bort?"
Write-Host "1. Rapport"
Write-Host "2. Semantisk modell"
$input_type_num = Read-Host "Skriv 1 eller 2"

switch ($input_type_num) {
    "1" {Write-Host "Du har valt: Rapport"}
    "2" {Write-Host "Du har valt: Semantisk modell"}
    default {Write-Host "Ogiltigt val. Vänligen kör skriptet igen och välj 1 eller 2." -ForegroundColor Red}
}

switch ($input_type_num) {
    "1" { $object_type = "report" }
    "2" { $object_type = "dataset" }
    default { $object_type = "okänt" }
}

# Ange namnet på arbetsytan där objektet finns
Write-Host "Ange namnet på arbetsytan där objektet finns."
$input_workspace_name = Read-Host "Arbetsytans namn"

$workspace = Get-PowerBIWorkspace -Scope Organization -Name $input_workspace_name
Write-Host $workspace.Name "-" $workspace.Id "-" $workspace.State

# Ange namnet på objektet
Write-Host "Ange namnet för objektet som ska tas bort."
$input_object_name = Read-Host "Objektets namn"

switch ($object_type) {
    "report" {$object = Get-PowerBIReport -Scope Organization -Name $input_object_name -WorkspaceId $workspace.Id }
    "datasets" {$object = Get-PowerBIDataset -Scope Organization -Name $input_object_name -WorkspaceId $workspace.Id}
}

Write-Host $object.Name "-" $object.Id

# Skapa länk
$api_url = "https://api.powerbi.com/v1.0/myorg/groups/" + $workspace.Id + "/" + $object_type + "/" + $object.Id
 
# Presentera vad som ska tas bort
 Write-Host "Du håller på att ta bort objektet " -NoNewLine
 Write-Host $object.Name -NoNewLine -ForegroundColor Cyan
 Write-Host " som finns i arbetsytan " -NoNewLine
 Write-Host $workspace.Name -NoNewLine -ForegroundColor Cyan
 Write-Host ". Är du säker på att du vill ta bort detta objekt? Handlingen går inte att ångra."
 $choice = Read-Host -Prompt "Skriv 1 för att ta bort objektet. Skriv 2 för att avbryta."


 # Ta bort
 if ($choice -eq "1") {
     Write-Host "Det valda objektet tas bort."
     switch ($object_type) {
        "report" { Remove-PowerBIReport -Id $object.Id -WorkspaceId $workspace.Id  }
        "datasets" { Invoke-PowerBIRestMethod -Id $object.Id -WorkspaceId $workspace.Id  }
     }
 }
 elseif ($choice -eq "2") {
     Write-Host "Åtgärden har avbrutits. Inga ändringar har skett"
 }
 else {
     Write-Host "Ogiltigt eller inget val har gjorts. Kör om skriptet för att börja om."
 }