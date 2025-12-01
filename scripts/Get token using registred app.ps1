##param(
##    [object]$parameters
##)

$parameters = Get-Content -Path ".\configuration-file.json" -Raw | ConvertFrom-Json

# Connect to Azure
Connect-AzAccount

# Set secrets in Azure Key Vault

$tenant_id =  Get-AzKeyVaultSecret -VaultName $parameters."key-vault"."kv-name" -Name $parameters."key-vault"."tenant-id"
$client_id = Get-AzKeyVaultSecret -VaultName $parameters."key-vault"."kv-name" -Name $parameters."key-vault"."client-id"
$secret_key = Get-AzKeyVaultSecret -VaultName $parameters."key-vault"."kv-name" -Name $parameters."key-vault"."key"

# Construct the API-call

$tenantIdPlain = (New-Object System.Net.NetworkCredential("", $tenant_id.SecretValue)).Password
$url_token = "https://login.microsoftonline.com/$tenantIdPlain/oauth2/token"
$body_token = @{
    grant_type    = "client_credentials"
    client_id     = (New-Object System.Net.NetworkCredential("", $client_id.SecretValue)).Password
    client_secret = (New-Object System.Net.NetworkCredential("", $secret_key.SecretValue)).Password
    scope         = "openid offline_access"
    resource      = "https://analysis.windows.net/powerbi/api"
}
$headers_token = @{'Content-Type'="application/x-www-form-urlencoded"}

# Get and print token
$response_token = Invoke-RestMethod -Method 'Post' -Uri $url_token -Body $body_token -Headers $headers_token
Write-Host $response_token
Read-Host -Prompt "Press any key to close."