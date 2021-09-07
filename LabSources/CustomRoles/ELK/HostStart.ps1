param(
    [Parameter(Mandatory)]
    [string]$ComputerName
)

function InstallElasticSearch
{
    if (-not (Get-Service elasticsearch -ErrorAction SilentlyContinue)) {
        Write-Host "elasticsearch is installing"
        Write-Host "Create keystore"
        cmd.exe /c "C:\Tools\ELK\elasticsearch\bin\elasticsearch-keystore create"
        Write-Host "Create bootstrap password"
        cmd.exe /c "C:\Tools\ELK\elasticsearch\bin\elasticsearch-keystore add -x bootstrap.password -f < C:\Tools\ELK\elasticsearch\bin\Bootstrap.txt"
        Write-Host "Create elk user"
        cmd.exe /c "C:\Tools\ELK\elasticsearch\bin\elasticsearch-users useradd elk -p Password1 -r superuser"
        #cmd.exe /c "C:\Tools\ELK\elasticsearch\bin\elasticsearch-setup-passwords.bat -s interactive < C:\Tools\ELK\elasticsearch\bin\Passwords.txt"
        Write-Host "Create service"
        C:\Tools\nssm.exe install elasticsearch 'C:\Tools\ELK\elasticsearch\bin\elasticsearch.bat'
        C:\Tools\nssm.exe set elasticsearch start SERVICE_DELAYED_AUTO_START
        C:\Tools\nssm.exe start elasticsearch
    } else {
        Write-Host "elasticsearch already installed"
    }
    Write-Host "Set firewall"
    New-NetFirewallRule -DisplayName "Allow TCP 9200 for elastic" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 9200
}

function InstallKibana
{
    if (-not (Get-Service kibana -ErrorAction SilentlyContinue)) {
        Write-Host "kibana is installing"
        C:\Tools\nssm.exe install kibana 'C:\Tools\ELK\kibana\bin\kibana.bat'
        C:\Tools\nssm.exe set kibana DependOnService elasticsearch
        C:\Tools\nssm.exe set kibana start SERVICE_DELAYED_AUTO_START
        C:\Tools\nssm.exe start kibana
    } else {
        Write-Host "kibana already installed"
    }
}


function InstallLogstash
{
    if (-not (Get-Service logstash -ErrorAction SilentlyContinue)) {
        Write-Host "logstash is installing"
        C:\Tools\nssm.exe install logstash 'C:\Tools\ELK\logstash\bin\logstash.bat'
        C:\Tools\nssm.exe set logstash DependOnService elasticsearch
        C:\Tools\nssm.exe set logstash start SERVICE_DELAYED_AUTO_START
        C:\Tools\nssm.exe start logstash
    } else {
        Write-Host "logstash already installed"
    }
}

#function InstallFleet
#{
#    Write-Host "fleet is installing"
#    C:\Tools\ELK\elasticsearch\bin\elasticsearch-plugin install file:///C:/Tools/ELK/fleetServer.zip
#    Write-Host "fleet is installed"
#}

function InstallPackages
{
    Write-ScreenInfo -Message 'Install ELK files' -TaskStart
    Write-ScreenInfo -Message "Installing  elasticsearch"
    Invoke-LabCommand -ActivityName InstallElasticsearch -ScriptBlock {InstallElasticSearch} -Function (Get-Command InstallElasticSearch) -ComputerName $ComputerName -PassThru
    
    Write-ScreenInfo -Message "Installing  kibana"
    Invoke-LabCommand -ActivityName InstallKibana -ScriptBlock {InstallKibana} -Function (Get-Command InstallKibana) -ComputerName $ComputerName -PassThru
    
    Write-ScreenInfo -Message "Installing  logstash"
    Invoke-LabCommand -ActivityName InstallLogstash -ScriptBlock {InstallLogstash} -Function (Get-Command InstallLogstash) -ComputerName $ComputerName -PassThru
    
    #Write-ScreenInfo -Message "Installing  fleet"
    #Invoke-LabCommand -ActivityName InstallFleet -ScriptBlock {InstallFleet} -Function (Get-Command InstallFleet) -ComputerName $ComputerName -PassThru
    
    Write-ScreenInfo 'finished' -TaskEnd
}

function Install-ELK
{
    Write-ScreenInfo "Installing ELK on '$ComputerName'"  -TaskStart
    Write-ScreenInfo "Starting machine '$ComputerName'" -NoNewLine
    Start-LabVM -ComputerName $ComputerName -Wait
    InstallPackages
    Write-ScreenInfo 'finished' -TaskEnd
}

Import-Lab -Name $data.Name

Write-ScreenInfo "Intalling ELK on '$ComputerName'..." -TaskStart

Install-ELK

Write-ScreenInfo "Finished installing ELK on '$ComputerName'" -TaskEnd
