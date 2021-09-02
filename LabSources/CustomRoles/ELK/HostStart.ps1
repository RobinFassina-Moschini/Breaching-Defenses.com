param(
    [Parameter(Mandatory)]
    [string]$ComputerName
)

function CopyPackages
{
    Write-ScreenInfo -Message 'Copy ELK files' -TaskStart
    Invoke-LabCommand -ActivityName CreateFolder -ScriptBlock { $targetFolder = "C:\ELK"; if (-not (Test-Path $targetFolder)) { New-Item $targetFolder -ItemType Directory | out-Null }} -ComputerName $ComputerName -PassThru
    
    Write-ScreenInfo -Message "Copy elasticsearch"
    Invoke-LabCommand -ActivityName CopyFile -ScriptBlock { Copy-Item -Path C:\Tools\ELK\elasticsearch -Destination $targetFolder -Recurse -Force} -ComputerName $ComputerName -PassThru
    
    Write-ScreenInfo -Message "Copy kibana"
    Invoke-LabCommand -ActivityName CopyFile -ScriptBlock { Copy-Item -Path C:\Tools\ELK\kibana -Destination $targetFolder -Recurse -Force} -ComputerName $ComputerName -PassThru
    
    Write-ScreenInfo -Message "Copy logstash"
    Invoke-LabCommand -ActivityName CopyFile -ScriptBlock { Copy-Item -Path C:\Tools\ELK\logstash -Destination $targetFolder -Recurse -Force} -ComputerName $ComputerName -PassThru
    
    #Write-ScreenInfo -Message "Copy fleet"
    #Invoke-LabCommand -ActivityName CopyFile -ScriptBlock { Copy-Item -Path C:\Tools\ELK\fleetServer.zip -Destination $targetFolder -Recurse -Force} -ComputerName $ComputerName -PassThru
    
    Write-ScreenInfo -Message "Copy nssm.exe"
    Invoke-LabCommand -ActivityName CopyFile -ScriptBlock { Copy-Item -Path C:\Tools\nssm.exe -Destination $targetFolder -Recurse -Force} -ComputerName $ComputerName -PassThru

    Write-ScreenInfo 'finished' -TaskEnd
}

function InstallElasticSearch
{
    if (-not (Get-Service elasticsearch -ErrorAction SilentlyContinue)) {
        Write-Host "elasticsearch is installing"
        C:\ELK\nssm.exe install elasticsearch 'C:\ELK\elasticsearch\bin\elasticsearch.bat'
        C:\ELK\nssm.exe set elasticsearch start SERVICE_DELAYED_AUTO_START
        C:\ELK\nssm.exe start elasticsearch
        cmd.exe /c "C:\ELK\elasticsearch\bin\elasticsearch-keystore create"
        C:\ELK\nssm.exe stop elasticsearch
        C:\ELK\nssm.exe start elasticsearch
        cmd.exe /c "C:\ELK\elasticsearch\bin\elasticsearch-setup-passwords.bat -s interactive < C:\ELK\elasticsearch\bin\Passwords.txt"
        C:\ELK\nssm.exe stop elasticsearch
        C:\ELK\nssm.exe start elasticsearch
    } else {
        Write-Host "elasticsearch already installed"
    }
    New-NetFirewallRule -DisplayName "Allow TCP 9200 for elastic" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 9200
}

function InstallKibana
{
    if (-not (Get-Service kibana -ErrorAction SilentlyContinue)) {
        Write-Host "kibana is installing"
        C:\ELK\nssm.exe install kibana 'C:\ELK\kibana\bin\kibana.bat'
        C:\ELK\nssm.exe set kibana DependOnService elasticsearch
        C:\ELK\nssm.exe set kibana start SERVICE_DELAYED_AUTO_START
        C:\ELK\nssm.exe start kibana
    } else {
        Write-Host "kibana already installed"
    }
}


function InstallLogstash
{
    if (-not (Get-Service logstash -ErrorAction SilentlyContinue)) {
        Write-Host "logstash is installing"
        C:\ELK\nssm.exe install logstash 'C:\ELK\logstash\bin\logstash.bat'
        C:\ELK\nssm.exe set logstash DependOnService elasticsearch
        C:\ELK\nssm.exe set logstash start SERVICE_DELAYED_AUTO_START
        C:\ELK\nssm.exe start logstash
    } else {
        Write-Host "logstash already installed"
    }
}

#function InstallFleet
#{
#    Write-Host "fleet is installing"
#    C:\ELK\elasticsearch\bin\elasticsearch-plugin install file:///C:/ELK/fleetServer.zip
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
    CopyPackages
    InstallPackages
    Write-ScreenInfo 'finished' -TaskEnd
}

Import-Lab -Name $data.Name

Write-ScreenInfo "Intalling ELK on '$ComputerName'..." -TaskStart

Install-ELK

Write-ScreenInfo "Finished installing ELK on '$ComputerName'" -TaskEnd
