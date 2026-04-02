
# Intune Dashboard V2.4 (Unicode Emoji Icons)
# Includes: macOS count, SerialNumber in all tables, Unicode emojis for OS icons, reverted Defender logic, suppress Graph welcome, All Devices section

$TenantId     = "<YOUR-TENANT-ID>"
$ClientId     = "<YOUR-CLIENT-ID>"
$ClientSecret = "<YOUR-CLIENT-SECRET>"

if (!(Get-Module -Name PSWriteHTML -ListAvailable)) { Install-Module -Name PSWriteHTML -Force -AllowClobber }
Import-Module PSWriteHTML
if (!(Get-Module -Name Microsoft.Graph -ListAvailable)) { Install-Module -Name Microsoft.Graph -Force -AllowClobber }

$Scope   = "https://graph.microsoft.com/.default"
$AuthUrl = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
$Body    = @{ client_id=$ClientId; scope=$Scope; client_secret=$ClientSecret; grant_type="client_credentials" }
$Connection  = Invoke-RestMethod -Method POST -Uri $AuthUrl -Body $Body -ContentType "application/x-www-form-urlencoded"
$AccessToken = $Connection.access_token
$SecureToken = ConvertTo-SecureString -String $AccessToken -AsPlainText -Force
Connect-MgGraph -AccessToken $SecureToken -NoWelcome

$OutputFolder = "C:\temp"; if (!(Test-Path $OutputFolder)) { mkdir -Path $OutputFolder }
$ManagedDevices = Get-MgDeviceManagementManagedDevice -All

$WindowsDevices = $ManagedDevices | Where-Object OperatingSystem -EQ "Windows"
$MacDevices     = $ManagedDevices | Where-Object OperatingSystem -EQ "macOS"
$iOSDevices     = $ManagedDevices | Where-Object OperatingSystem -EQ "iOS"
$AndroidDevices = $ManagedDevices | Where-Object OperatingSystem -EQ "Android"
$LinuxDevices   = $ManagedDevices | Where-Object OperatingSystem -EQ "Linux"

$ProtectedDevices=@(); $UnprotectedDevices=@()
foreach ($Device in $ManagedDevices) {
    if ($Device.WindowsProtectionState.RealTimeProtectionEnabled -eq $false) { $UnprotectedDevices+=$Device } else { $ProtectedDevices+=$Device }
}

$CompliantDevices=$ManagedDevices|Where-Object ComplianceState -EQ "compliant"
$NoncompliantDevices=$ManagedDevices|Where-Object ComplianceState -EQ "noncompliant"
$ThirtyDaysAgo=(Get-Date).AddDays(-30)
$InactiveDevices=$ManagedDevices|Where-Object{$_.LastSyncDateTime -lt $ThirtyDaysAgo}
$MinimumFreeSpace=100
$LowStorageDevices=$ManagedDevices|Where-Object{($_.FreeStorageSpaceInBytes/1GB)-lt $MinimumFreeSpace}
$EncryptedDevices=$ManagedDevices|Where-Object IsEncrypted -EQ $true
$UnecryptedDevices=$ManagedDevices|Where-Object IsEncrypted -EQ $false
$AzureRegisteredDevices=$ManagedDevices|Where-Object AzureAdRegistered -EQ $True
$AzureUnregisteredDevices=$ManagedDevices|Where-Object AzureAdRegistered -EQ $False
$CompanyDevices=$ManagedDevices|Where-Object ManagedDeviceOwnerType -EQ 'company'
$PersonalDevices=$ManagedDevices|Where-Object ManagedDeviceOwnerType -EQ 'personal'

New-HTML -TitleText "Intune Dashboard" -Online -FilePath "$OutputFolder\Intune-Dashboard.html" {
    New-HTMLSection -HeaderText "Devices Overview" -HeaderTextSize 14 -HeaderBackGroundColor "#708090" -CanCollapse {
        New-HTMLInfoCard -Title "Windows Devices" -Number $WindowsDevices.Count -Icon "🖥️" -IconColor "#0078d4"
        New-HTMLInfoCard -Title "macOS Devices" -Number $MacDevices.Count -Icon "🍎" -IconColor "#8e44ad"
        New-HTMLInfoCard -Title "Android Devices" -Number $AndroidDevices.Count -Icon "🤖" -IconColor "#f39c12"
        New-HTMLInfoCard -Title "Linux Devices" -Number $LinuxDevices.Count -Icon "🐧" -IconColor "#27ae60"
        New-HTMLInfoCard -Title "Inactive Devices (≥ 30 days)" -Number $InactiveDevices.Count -Icon "⏳" -IconColor "purple"
        New-HTMLInfoCard -Title "Devices with low storage (< 100 GB)" -Number $LowStorageDevices.Count -Icon "💾" -IconColor "#ffc107"
    }

    # DataTable Section with All Devices first
    New-HTMLSection -HeaderText "All Devices (Detailed Inventory)" -HeaderTextSize 14 -HeaderBackGroundColor "#708090" -CanCollapse {
        New-HTMLTable -DataTable (
            $ManagedDevices | Select-Object DeviceName,SerialNumber,Model,@{Name="DeviceIP";Expression={if($_.IpAddress){$_.IpAddress}elseif($_.WiFiMacAddress){$_.WiFiMacAddress}elseif($_.EthernetMacAddress){$_.EthernetMacAddress}else{""}}},UserPrincipalName
        ) -Filtering -PagingLength 50
    }

    New-HTMLSection -HeaderText "Defender disabled" -HeaderTextSize 14 -HeaderBackGroundColor "#708090" -CanCollapse {
        New-HTMLTable -DataTable ($UnprotectedDevices|Select-Object DeviceName,SerialNumber,UserPrincipalName,OperatingSystem,Manufacturer,Model,OSVersion,ComplianceState,IsEncrypted,LastSyncDateTime,EnrolledDateTime) -Filtering -PagingLength 50
    }
    New-HTMLSection -HeaderText "Noncompliant Devices" -HeaderTextSize 14 -HeaderBackGroundColor "#708090" -CanCollapse {
        New-HTMLTable -DataTable ($NoncompliantDevices|Select-Object DeviceName,SerialNumber,UserPrincipalName,OperatingSystem,Manufacturer,Model,OSVersion,ComplianceState,IsEncrypted,LastSyncDateTime,EnrolledDateTime) -Filtering -PagingLength 50
    }
    New-HTMLSection -HeaderText "BitLocker disabled" -HeaderTextSize 14 -HeaderBackGroundColor "#708090" -CanCollapse {
        New-HTMLTable -DataTable ($UnecryptedDevices|Select-Object DeviceName,SerialNumber,UserPrincipalName,OperatingSystem,Manufacturer,Model,OSVersion,ComplianceState,IsEncrypted,LastSyncDateTime,EnrolledDateTime) -Filtering -PagingLength 50
    }
    New-HTMLSection -HeaderText "Azure Unregistered Devices" -HeaderTextSize 14 -HeaderBackGroundColor "#708090" -CanCollapse {
        New-HTMLTable -DataTable ($AzureUnregisteredDevices|Select-Object DeviceName,SerialNumber,UserPrincipalName,OperatingSystem,Manufacturer,Model,OSVersion,ComplianceState,IsEncrypted,LastSyncDateTime,EnrolledDateTime) -Filtering -PagingLength 50
    }
    New-HTMLSection -HeaderText "Personal Devices" -HeaderTextSize 14 -HeaderBackGroundColor "#708090" -CanCollapse {
        New-HTMLTable -DataTable ($PersonalDevices|Select-Object DeviceName,SerialNumber,UserPrincipalName,OperatingSystem,Manufacturer,Model,OSVersion,ComplianceState,IsEncrypted,LastSyncDateTime,EnrolledDateTime) -Filtering -PagingLength 50
    }
    New-HTMLSection -HeaderText "Inactive Devices" -HeaderTextSize 14 -HeaderBackGroundColor "#708090" -CanCollapse {
        New-HTMLTable -DataTable ($InactiveDevices|Select-Object DeviceName,SerialNumber,UserPrincipalName,OperatingSystem,Manufacturer,Model,OSVersion,ComplianceState,IsEncrypted,LastSyncDateTime,EnrolledDateTime|Sort-Object -Descending ComplianceState) -Filtering -PagingLength 50
    }
    New-HTMLSection -HeaderText "Devices with low storage" -HeaderTextSize 14 -HeaderBackGroundColor "#708090" -CanCollapse {
        New-HTMLTable -DataTable ($LowStorageDevices|Select-Object DeviceName,SerialNumber,UserPrincipalName,OperatingSystem,Manufacturer,Model,OSVersion,ComplianceState,IsEncrypted,LastSyncDateTime,EnrolledDateTime,@{Name="FreeSpaceGB";Expression={[math]::Round($_.FreeStorageSpaceInBytes/1GB,2)}}|Sort-Object -Descending ComplianceState) -Filtering -PagingLength 50
    }
} -ShowHTML
