# Try to get a token; if not logged in, catch and connect
$token = $null
try {
    $token = Get-PowerBIAccessToken -ErrorAction Stop
} catch {
    Write-Verbose "No active Power BI session. Connecting..."
    Connect-PowerBIServiceAccount
    # Try again after connecting
    try {
        $token = Get-PowerBIAccessToken -ErrorAction Stop
    } catch {
        throw "Failed to acquire Power BI access token even after login: $($_.Exception.Message)"
    }
}

Write-Host "Power BI access token acquired. You are logged in."