#Update the following URLS to your specific installation / Discord webHookURL
$webHookUrl = "https://discord.com/api/webhooks/********"
$url = "https://cwa-corpcloud.screenconnect.com"

$web = New-Object System.Net.WebClient
$Webr = Invoke-WebRequest https://www.connectwise.com/platform/unified-management/control/download/archive -UseBasicParsing
$href = ($Webr.links | Where-Object {$_ -like "*Release.msi*"} | Select-Object -First 1).href
$temp = [System.Environment]::GetEnvironmentVariable('TEMP','Machine')
$file = $href.split('/')[3]
$version = $file.Split('_')[1]
$Installed = (Get-CimInstance -Query "SELECT * FROM Win32_Product Where Vendor Like '%ScreenConnect%'").Version
$parms=@("/qn", "/l*v", "$temp\ScreenConnect-$env:Computername.log";"/i";"$temp\$file")
if ([decimal]$version.Split('.')[0] -gt [decimal]$Installed.Split('.')[0]) {
    $upgradeAvailable = $true
}
elseif ([decimal]$version.Split('.')[1] -gt [decimal]$Installed.Split('.')[1]) {
    $upgradeAvailable = $true
}
elseif ([decimal]$version.Split('.')[2] -gt [decimal]$Installed.Split('.')[2]) {
    $upgradeAvailable = $true
}
elseif ([decimal]$version.Split('.')[3] -gt [decimal]$Installed.Split('.')[3]) {
    $upgradeAvailable = $true
}
if ($upgradeAvailable) {
        $title       = 'ScreenConnect Update Available'
        $description = "Upgrading from $Installed to $Version on $env:Computername"
        $color       = '15105570'
        $time = Get-date -Date (Get-Date).ToUniversalTime()  -Format yyyy-MM-ddTHH:mm:ss.fffZ
        $embedObject = [PSCustomObject]@{
            title = $title
            description = $description
            url = $url
            timestamp = $time
            color = $color
        }
        [System.Collections.ArrayList]$embedArray = @()
        $embedArray.Add($embedObject)

        $payload = [PSCustomObject]@{
            embeds = $embedArray
        }
       # Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json'

    Write-Host "Newer Version Available, attempting to install"
    $web.DownloadFile($href,"$temp\$file")
    $RESULT = (Start-Process -FilePath msiexec.exe   -ArgumentList $parms -Wait -Passthru).ExitCode
    if ($RESULT -eq '0') {
        Remove-Item "$temp\$file" -Confirm:$false -Force
        $title       = 'ScreenConnect Update Complete'
        $description = "$Version is now installed on $env:Computername"
        $color       = '15105570'
        $time = Get-date -Date (Get-Date).ToUniversalTime()  -Format yyyy-MM-ddTHH:mm:ss.fffZ
        $embedObject = [PSCustomObject]@{
            title = $title
            description = $description
            url = $url
            timestamp = $time
            color = $color
        }
        [System.Collections.ArrayList]$embedArray = @()
        $embedArray.Add($embedObject)
        $payload = [PSCustomObject]@{
            embeds = $embedArray
        }
       # Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json'
    }
    else {
        $title       = '**ScreenConnect Update Failed**'
        $description = "__**Upgrade from $Installed to $Version failed**__`n**Please Remediate Immediately**"
        $color       = '15105570'
        $time = Get-date -Date (Get-Date).ToUniversalTime()  -Format yyyy-MM-ddTHH:mm:ss.fffZ
        $embedObject = [PSCustomObject]@{
            title = $title
            description = $description
            url = $url
            timestamp = $time
            color = $color
        }
        [System.Collections.ArrayList]$embedArray = @()
        $embedArray.Add($embedObject)

        $payload = [PSCustomObject]@{
            embeds = $embedArray
        }
       # Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json'
    }
}