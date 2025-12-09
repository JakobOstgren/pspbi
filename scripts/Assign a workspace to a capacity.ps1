$azure_client_id = ""
$client_id = ""
$client_secret = ""
$workspace_id = ""
$capacity_id = ""

#Get authorization-token
$url_token = "https://login.microsoftonline.com/" + $azure_client_id + "/oauth2/token"
$body_token = "grant_type=client_credentials&client_id=" + $client_id + "&client_secret=" + $client_secret + "&scope=openid%20offline_access&resource=https://analysis.windows.net/powerbi/api"
$headers_token = @{'Content-Type'="application/x-www-form-urlencoded"}
$response_token = Invoke-RestMethod -Method 'Post' -Uri $url_token -Body $body_token -Headers $headers_token

#Assign workspace to capacity
$url_embed = "https://api.powerbi.com/v1.0/myorg/groups/" + $workspace_id + "/AssignToCapacity"
$body_embed = @{"capacityId" = $capacity_id}
$token = "Bearer " + $response_token.access_token
$headers_embed = @{'Authorization'=$token}
#Write-output $token
#Write-output $headers_embed
#Write-output $body_embed

Invoke-RestMethod -Method 'Post' -Uri $url_embed -Body $body_embed -Headers $headers_embed