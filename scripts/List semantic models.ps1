# Logga in med OATH
Connect-PowerBIServiceAccount   # or use aliases: Login-PowerBIServiceAccount, Login-PowerBI

do {

$semantic_model_name = Read-Host -Prompt "Skriv namnet på den semantiska modell som du vill visa och tryck ENTER. Om inget skrivs in kommer alla modeller du har tillgång till att visas."

if ($semantic_model_name -eq "") {
    Write-Host "Parameter är tom, alla modeller visas."
    Get-PowerBIDataset -Workspace Insiktsportalen
}
else {
    Write-Host "Söker efter modeller med namnet" $semantic_model_name
    Get-PowerBIDataset -Scope Organization -Name $semantic_model_name
}

# Håll fönstret öppet
$search_again = Read-Host -Prompt "Vill du söka igen? Skriv j eller n, avsluta med ENTER."

}
while ($search_again -eq 'j')