param(
    [Parameter(Mandatory)]
    [string]$labName
)

#--------------------------------------------------------------------------------------------------------------------
# Global variables
#--------------------------------------------------------------------------------------------------------------------
$domain = 'breachdefs.com'
$child = 'it'
$childDomain = $child + "." + $domain
#--------------------------------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------------------------------
# Change the variables in disk_config.ps1 to adapte to your disk config
#--------------------------------------------------------------------------------------------------------------------
. $PSScriptRoot\disk_config.ps1
#--------------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------------
# Update the lab
#--------------------------------------------------------------------------------------------------------------------
function Update-The-Labs
{
    $LabDownloadLink = "https://github.com/RobinFassina-Moschini/Breaching-Defenses.com_labs"
    Write-ScreenInfo -Message "Update the lab from '$LabDownloadLink'"
    cd $PSScriptRoot
    git pull
    Write-ScreenInfo -Message "Update the Custom Roles"
    Copy-Item -Path "$PSScriptRoot\LabSources\CustomRoles" -Destination "$labSources" -Recurse -Force
    Write-ScreenInfo -Message "Update the Tools"
    Copy-Item -Path "$PSScriptRoot\LabSources\Tools\ELK" -Destination "$labSources\Tools" -Recurse -Force
    Write-ScreenInfo 'finished'
}

Update-The-Labs
#--------------------------------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------------------------------
# Download the ISOs
#--------------------------------------------------------------------------------------------------------------------
function Download-ISOs
{
    $Windows2016DownloadLink = "https://software-download.microsoft.com/download/pr/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO"
    $Window10DownloadLink = "https://archive.org/download/microsoft-windows-10-business-x-64-english/1507/English/en_windows_10_multiple_editions_x64_dvd_6846432.iso"
    $WindowsSQL2014DownloadLink = "http://download.microsoft.com/download/7/9/F/79F4584A-A957-436B-8534-3397F33790A6/SQLServer2014SP3-FullSlipstream-x64-ENU.iso"
    $Office2016DownloadLink = "https://archive.org/download/Office.2016/Office.2016.En.Santos.iso"
    $Office2013DownloadLink = "https://archive.org/download/en_office_professional_plus_2013_x86_x64_dvd_1135709/en_office_professional_plus_2013_x86_x64_dvd_1135709.iso"
    
    Write-ScreenInfo -Message 'Download ISO' -TaskStart
    $downloadTargetFolder = "$labSources\ISOs"
    #create the folder
    if (-not (Test-Path $downloadTargetFolder)) { New-Item $downloadTargetFolder -ItemType Directory | out-Null }

    Write-ScreenInfo -Message "Downloading Windows Server 2016 from '$Windows2016DownloadLink'"
    $res = Get-LabInternetFile -Uri $Windows2016DownloadLink -Path $downloadTargetFolder -PassThru -ErrorAction Stop
    
    Write-ScreenInfo -Message "Downloading Windows 10 from '$Window10DownloadLink'"
    $res = Get-LabInternetFile -Uri $Window10DownloadLink -Path $downloadTargetFolder -PassThru -ErrorAction Stop
    
    Write-ScreenInfo -Message "Downloading Windows SQL 2014 from '$WindowsSQL2014DownloadLink'"
    $res = Get-LabInternetFile -Uri $WindowsSQL2014DownloadLink -Path $downloadTargetFolder -PassThru -ErrorAction Stop
    
    Write-ScreenInfo -Message "Downloading Office 2016 from '$Office2016DownloadLink'"
    $downloadTarget = $downloadTargetFolder + "\en_office_professional_plus_2016_x86_x64_dvd_6962141.iso"
    $res = Get-LabInternetFile -Uri $Office2016DownloadLink -Path $downloadTarget -PassThru -ErrorAction Stop
    
    #Write-ScreenInfo -Message "Downloading Office 2013 from '$Office2013DownloadLink'"
    #$res = Get-LabInternetFile -Uri $Office2013DownloadLink -Path $downloadTargetFolder -PassThru -ErrorAction Stop
    
    Write-ScreenInfo 'finished' -TaskEnd
}

Download-ISOs


#--------------------------------------------------------------------------------------------------------------------
# Download the BadBlood
#--------------------------------------------------------------------------------------------------------------------
function Download-BadBlood
{
    $BadBloodDownloadLink = "https://github.com/RobinFassina-Moschini/BadBlood.git"
    
    Write-ScreenInfo -Message 'Download BadBlood' -TaskStart
    $downloadTargetFolder = "$labSources\Tools\BadBlood"

    if (-not (Test-Path $downloadTargetFolder)) {
        Write-ScreenInfo -Message "Downloading BadBlood from '$BadBloodDownloadLink'"
        cd "$labSources\Tools\"
        git clone $BadBloodDownloadLink 
    } else {
        Write-ScreenInfo -Message "Updating BadBlood from '$BadBloodDownloadLink'"
        cd $downloadTargetFolder
        git pull
    }
    Write-ScreenInfo 'finished' -TaskEnd
}

Download-BadBlood

#--------------------------------------------------------------------------------------------------------------------
# Download the ressources to SetUp the ELK 
#--------------------------------------------------------------------------------------------------------------------
function Download-ELKSources
{
    #The version of ELK
    $versionELK = '7.14.1'
    $elasticsearchDownloadLink = "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$versionELK-windows-x86_64.zip"
    $kibanaDownloadLink = "https://artifacts.elastic.co/downloads/kibana/kibana-$versionELK-windows-x86_64.zip"
    $logstashDownloadLink = "https://artifacts.elastic.co/downloads/logstash/logstash-$versionELK-windows-x86_64.zip"
    $beatDownloadLink = "https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-$versionELK-windows-x86_64.zip"
    # Elastic EDR, waiting for the air gap solution
    # docker.elastic.co/package-registry/distribution:production
    #$elasticAgentDownloadLink = "https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-$versionELK-windows-x86_64.zip"
    #$fleetServerDownloadLink = 'https://epr.elastic.co/epr/fleet_server/fleet_server-1.0.0.zip'
    
    Write-ScreenInfo -Message 'Download ELK requirements' -TaskStart
    $downloadTargetFolder = "$labSources\Tools\ELK"
    #create the folder
    if (-not (Test-Path $downloadTargetFolder)) { New-Item $downloadTargetFolder -ItemType Directory | out-Null }

    Write-ScreenInfo -Message "Downloading elasticsearch from '$elasticsearchDownloadLink'"
    $script:elasticInstallFile = Get-LabInternetFile -Uri $elasticsearchDownloadLink -Path $downloadTargetFolder -PassThru -ErrorAction Stop
    if (-not (Test-Path $downloadTargetFolder\elasticsearch)) {
        Expand-Archive -Force $elasticInstallFile.FullName $downloadTargetFolder
        $orig = "$downloadTargetFolder\elasticsearch-$versionELK"
        $dest = "$downloadTargetFolder\elasticsearch"
        Move-Item -Path $orig -Destination $dest
    }
    Copy-Item -Path "$labSources\Tools\ELK\elasticsearch.yml" -Destination "$labSources\Tools\ELK\elasticsearch\config\elasticsearch.yml"
    Copy-Item -Path "$labSources\Tools\ELK\Passwords.txt" -Destination "$labSources\Tools\ELK\elasticsearch\bin\Passwords.txt"
    Copy-Item -Path "$labSources\Tools\ELK\Bootstrap.txt" -Destination "$labSources\Tools\ELK\elasticsearch\bin\Bootstrap.txt"
    
    Write-ScreenInfo -Message "Downloading kibana from '$kibanaDownloadLink'"
    $script:kibanaInstallFile = Get-LabInternetFile -Uri $kibanaDownloadLink -Path $downloadTargetFolder -PassThru -ErrorAction Stop
    if (-not (Test-Path $downloadTargetFolder\kibana)) {
        Expand-Archive -Force $kibanaInstallFile.FullName $downloadTargetFolder
        $orig = "$downloadTargetFolder\kibana-$versionELK-windows-x86_64"
        $dest = "$downloadTargetFolder\kibana"
        Move-Item -Path $orig -Destination $dest
    }
    Copy-Item -Path "$labSources\Tools\ELK\kibana.yml" -Destination "$labSources\Tools\ELK\kibana\config\kibana.yml"
    
    Write-ScreenInfo -Message "Downloading logstash from '$logstashDownloadLink'"
    $script:logstashInstallFile = Get-LabInternetFile -Uri $logstashDownloadLink -Path $downloadTargetFolder -PassThru -ErrorAction Stop
    if (-not (Test-Path $downloadTargetFolder\logstash)) {
        Expand-Archive -Force $logstashInstallFile.FullName $downloadTargetFolder
        $orig = "$downloadTargetFolder\logstash-$versionELK"
        $dest = "$downloadTargetFolder\logstash"
        Move-Item -Path $orig -Destination $dest
    }
    
    #Write-ScreenInfo -Message "Downloading fleetPlugin from '$fleetServerDownloadLink'"
    #$script:fleetInstallFile = Get-LabInternetFile -Uri $fleetServerDownloadLink -Path $downloadTargetFolder -PassThru -ErrorAction Stop
    #if (-not (Test-Path $downloadTargetFolder\fleetServer.zip)) {
    #    $dest = "$downloadTargetFolder\fleetServer.zip"
    #    Copy-Item $fleetInstallFile.FullName $dest
    #}
    
    #Write-ScreenInfo -Message "Downloading elastic-agent from '$elasticAgentDownloadLink'"
    #$script:elasticAgentInstallFile = Get-LabInternetFile -Uri $elasticAgentDownloadLink -Path $downloadTargetFolder -PassThru -ErrorAction Stop
    #if (-not (Test-Path $downloadTargetFolder\elastic-agent)) {
    #    $dest = "$downloadTargetFolder\elastic-agent.zip"
    #    Copy-Item $elasticAgentInstallFile.FullName $dest
    #    Expand-Archive -Force $dest $downloadTargetFolder
    #    $orig = "$downloadTargetFolder\elastic-agent-$versionELK-windows-x86_64"
    #    $dest = "$downloadTargetFolder\elastic-agent"
    #    Move-Item -Path $orig -Destination $dest
    #}
    
    Write-ScreenInfo -Message "Downloading winlogbeat from '$beatDownloadLink'"
    $script:beatInstallFile = Get-LabInternetFile -Uri $beatDownloadLink -Path $downloadTargetFolder -PassThru -ErrorAction Stop
    if (-not (Test-Path $downloadTargetFolder\winlogbeat)) {
        Expand-Archive -Force $beatInstallFile.FullName $downloadTargetFolder
        $orig = "$downloadTargetFolder\winlogbeat-$versionELK-windows-x86_64"
        $dest = "$downloadTargetFolder\winlogbeat"
        Move-Item -Path $orig -Destination $dest
    }
    Copy-Item -Path "$labSources\Tools\ELK\winlogbeat.yml" -Destination "$labSources\Tools\ELK\winlogbeat\winlogbeat.yml"
    Copy-Item -Path "$labSources\Tools\ELK\winlogbeatPolicy.json" -Destination "$labSources\Tools\ELK\winlogbeat\winlogbeatPolicy.json"
    
    Write-ScreenInfo 'finished' -TaskEnd
}

Download-ELKSources
#--------------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------------
# Download the Tools
#--------------------------------------------------------------------------------------------------------------------
function Download-Tools
{
    $firefoxDownloadLink = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US"
    $nssmDownloadLink = "https://nssm.cc/release/nssm-2.24.zip"
    $processHackerDownloadLink = "https://github.com/processhacker/processhacker/releases/download/v2.39/processhacker-2.39-setup.exe"
    $pythonDownloadLink = "https://www.python.org/ftp/python/3.9.6/python-3.9.6-amd64.exe"
    $sheeplDownloadLink = "https://github.com/lorentzenman/sheepl.git"
    $autoITDownloadLink = "https://web.archive.org/web/20210708181215/https://www.autoitscript.com/files/autoit3/autoit-v3-setup.exe"
    
    $downloadTargetFolder = "$labSources\Tools"
    Write-ScreenInfo -Message "Downloading firefox from '$firefoxDownloadLink'"
    $script:firefoxInstallFile = Get-LabInternetFile -Uri $firefoxDownloadLink -Path $downloadTargetFolder -PassThru -ErrorAction Stop
    Copy-Item -Path $firefoxInstallFile.FullName -Destination "$labSources\Tools\Firefox.exe"
    
    if (-not (Test-Path $labSources\Tools\nssm.exe)) {
        Write-ScreenInfo -Message "Downloading nssm from '$nssmDownloadLink'"
        $script:nssmInstallFile = Get-LabInternetFile -Uri $nssmDownloadLink -Path $downloadTargetFolder -PassThru -ErrorAction Stop
        Expand-Archive -Force $nssmInstallFile.FullName $downloadTargetFolder 
        $orig = "$downloadTargetFolder\nssm-2.24\win64\nssm.exe"   
        Move-Item -Path $orig -Destination "$labSources\Tools\nssm.exe"
    }
    
    if (-not (Test-Path $labSources\Tools\processhacker.exe)) {
        Write-ScreenInfo -Message "Downloading processhacker from '$processHackerDownloadLink'"
        $script:processHackerInstallFile = Get-LabInternetFile -Uri $processHackerDownloadLink -Path $downloadTargetFolder -PassThru -ErrorAction Stop
        Copy-Item -Path $processHackerInstallFile.FullName -Destination "$labSources\Tools\processhacker.exe"
    }
    
    if (-not (Test-Path $labSources\Tools\autoit-v3-setup.exe)) {
        Write-ScreenInfo -Message "Downloading autoIT from '$autoITDownloadLink'"
        $script:autoITInstallFile = Get-LabInternetFile -Uri $autoITDownloadLink -Path $downloadTargetFolder -PassThru -ErrorAction Stop
    }
    
    if (-not (Test-Path $labSources\Tools\python.exe)) {
        Write-ScreenInfo -Message "Downloading python from '$pythonDownloadLink'"
        $script:pythonInstallFile = Get-LabInternetFile -Uri $pythonDownloadLink -Path $downloadTargetFolder -PassThru -ErrorAction Stop
        Copy-Item -Path $pythonInstallFile.FullName -Destination "$labSources\Tools\python.exe"
    }
    
    $downloadTargetFolder = "$labSources\Tools\sheepl"
    if (-not (Test-Path $downloadTargetFolder)) {
        Write-ScreenInfo -Message "Downloading sheepl from '$sheeplDownloadLink'"
        cd "$labSources\Tools\"
        git clone $sheeplDownloadLink 
    } else {
        Write-ScreenInfo -Message "Updating sheepl from '$sheeplDownloadLink'"
        cd $downloadTargetFolder
        git pull
    }
    
    Write-ScreenInfo 'finished' -TaskEnd
}


Download-Tools

#--------------------------------------------------------------------------------------------------------------------
# Create the lab structure
#--------------------------------------------------------------------------------------------------------------------
# set the path for the lab
$labFolder = Join-Path -Path $vmDrive -ChildPath $labName
# create the folder for the lab if it doesn't exist
if (-not (Test-Path $labFolder)) { New-Item $labFolder -ItemType Directory | out-Null }
# create an empty lab template and define where the lab XML files and the VMs will be stored
New-LabDefinition -VmPath $labFolder -Name $labName -DefaultVirtualizationEngine HyperV
# make the network definition
Add-LabVirtualNetworkDefinition -Name BreachingDefenses -AddressSpace 192.168.42.0/24
$AdminUser = 'Install'
$AdminPassword = 'Password1'
Set-LabInstallationCredential -Username $AdminUser -Password $AdminPassword
#--------------------------------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------------------------------
# Defining default parameter values, as these ones are the same for all the machines
#--------------------------------------------------------------------------------------------------------------------
#'Add-LabMachineDefinition:HypervProperties' = @{AutomaticStartAction = 'Start'; AutomaticStartDelay = '10'; AutomaticStopAction = 'Save'}
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:ToolsPath'= "$labSources\Tools"
    'Add-LabMachineDefinition:OperatingSystem'= 'Windows Server 2016 Datacenter Evaluation (Desktop Experience)'
    'Add-LabMachineDefinition:MinMemory'= 512MB
    'Add-LabMachineDefinition:MaxMemory'= 2048MB
    'Add-LabMachineDefinition:Memory'= 1024MB
    'Add-LabMachineDefinition:Processors' = 1
    'Add-LabMachineDefinition:DomainName'= $domain
    'Add-LabMachineDefinition:DnsServer1'= '192.168.42.10'
}
#--------------------------------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------------------------------
# Def Roles
#--------------------------------------------------------------------------------------------------------------------
# for the root Domain Controller
$roleDC = Get-LabMachineRoleDefinition -Role RootDC @{
    ForestFunctionalLevel = 'Win2012R2'
    DomainFunctionalLevel = 'Win2012R2'
    SiteName = 'Prod'
    SiteSubnet = '192.168.42.0/25'
}

# for the Child Domain Controller 
$roleDCChild = Get-LabMachineRoleDefinition -Role FirstChildDC @{
    ParentDomain = $domain
    NewDomain = $child
    DomainFunctionalLevel = 'Win2012R2'
    SiteName = 'IT'
    SiteSubnet = '192.168.42.128/25'
}

# for the root Domain Controller
$roleDCOnlyForest = Get-LabMachineRoleDefinition -Role RootDC @{
    ForestFunctionalLevel = 'Win2012R2'
    DomainFunctionalLevel = 'Win2012R2'
    SiteName = 'Prod'
    SiteSubnet = '192.168.42.0/24'
}

# for the SQL Server
Add-LabIsoImageDefinition -Name SQLServer2014 -Path "$labSources\ISOs\SQLServer2014SP3-FullSlipstream-x64-ENU.iso"

# for the ELK Agents
$roleInstallElastic = Get-LabPostInstallationActivity -CustomRole Elastic_agent

# for the ELKServer
$roleELK = Get-LabPostInstallationActivity -CustomRole ELK

# for Exchange 2016
$roleExchange2016 = Get-LabPostInstallationActivity -CustomRole Exchange2016_vuln -Properties @{ 
    OrganizationName = 'breachdefs'
    exchangeDownloadUrl = 'https://download.microsoft.com/download/2/5/8/258D30CF-CA4C-433A-A618-FB7E6BCC4EEE/ExchangeServer2016-x64-cu12.iso'
}

# Office 2016 trial
Add-LabIsoImageDefinition -Name Office2016 -Path "$labSources\ISOs\en_office_professional_plus_2016_x86_x64_dvd_6962141.iso"

# Office 2013 trial
#Add-LabIsoImageDefinition -Name Office2013 -Path "$labSources\ISOs\en_office_professional_plus_2013_x86_x64_dvd_1135709.iso"

# for BadBlood
$roleBadBlood = Get-LabPostInstallationActivity -CustomRole BadBlood
#--------------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------------
# DNS config
#--------------------------------------------------------------------------------------------------------------------
Copy-Item -Path $PSScriptRoot\hosts -Destination C:\Windows\System32\drivers\etc\hosts -Force
#--------------------------------------------------------------------------------------------------------------------

