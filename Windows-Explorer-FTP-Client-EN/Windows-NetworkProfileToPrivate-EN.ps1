# Gain Admin Privilege 1
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Gain Admin Privilege 2
if ((Test-Admin) -eq $false) {
    # Get the script's directory
    $scriptPath = $MyInvocation.MyCommand.Path
    $scriptDirectory = Split-Path $scriptPath -Parent

    # Start the elevated process in the script's directory
    Start-Process powershell.exe -Verb RunAs -ArgumentList ("-noprofile -file `"{0}`" -elevated" -f $scriptPath) -WorkingDirectory $scriptDirectory
    exit
}

# Display the selected SSID
echo $SelectedSSID

# Check if there is a valid connection
if ((Get-NetConnectionProfile -InterfaceAlias WLAN -IPv4Connectivity LocalNetwork -NetworkCategory Public -ErrorAction SilentlyContinue) -eq $null) {
    Write-Warning "× There are no matching WLAN connections to modify, or this process has already been completed."
    Start-Sleep -Seconds 1
    exit
}

# Get the batch-exported WLAN SSID
$ssidFile = Join-Path (Get-Location) "temp_wlan_ssid.txt"
$SelectedSSID = Get-Content $ssidFile

# Get the network to modify connection, specified by parameter $SelectedSSID
$network = Get-NetConnectionProfile -InterfaceAlias WLAN -IPv4Connectivity LocalNetwork -NetworkCategory Public |
Where-Object { $_.Name -match $SelectedSSID }

Write-Host "`nWLAN SSID: " + $network.Name

# Check and correct multiple matches to one
if ($network.GetType().BaseType.Name -eq "Array") {
    Write-Warning "`n？：The same wireless network SSID matched multiple wireless network connections; it will choose the first one."
    $network = $network[0]
}

# Change the wireless network connection configuration from public to private
Set-NetConnectionProfile -InputObject $network -NetworkCategory Private

# Change the wireless network connection configuration from private to public
# Set-NetConnectionProfile -InputObject $network -NetworkCategory Public

# Display the change results
Write-Host "`nChange Results:"
Get-NetConnectionProfile -InterfaceAlias WLAN -IPv4Connectivity LocalNetwork | Select-Object Name, InterfaceAlias, NetworkCategory, IPv4Connectivity, DomainAuthenticationKind

Start-Sleep -Seconds 2
exit