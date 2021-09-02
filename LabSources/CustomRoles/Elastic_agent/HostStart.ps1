param(
    [Parameter(Mandatory)]
    [string]$ComputerName
)

function CopyPackages
{
    Write-ScreenInfo -Message 'Copy elastic-agent files' -TaskStart
    Invoke-LabCommand -ActivityName CreateFolder -ScriptBlock { $targetFolder = "C:\ELK"; if (-not (Test-Path $targetFolder)) { New-Item $targetFolder -ItemType Directory | out-Null }} -ComputerName $ComputerName -PassThru
    
    Write-ScreenInfo -Message "Copy winlogbeat"
    Invoke-LabCommand -ActivityName CopyFile -ScriptBlock { Copy-Item -Path C:\Tools\ELK\winlogbeat -Destination $targetFolder -Recurse -Force} -ComputerName $ComputerName -PassThru
    
    #Write-ScreenInfo -Message "Copy elastic-agent"
    #Invoke-LabCommand -ActivityName CopyFile -ScriptBlock { Copy-Item -Path C:\Tools\ELK\elastic-agent -Destination $targetFolder -Recurse -Force} -ComputerName $ComputerName -PassThru
    
    Write-ScreenInfo -Message "Copy nssm.exe"
    Invoke-LabCommand -ActivityName CopyFile -ScriptBlock { Copy-Item -Path C:\Tools\nssm.exe -Destination $targetFolder -Recurse -Force} -ComputerName $ComputerName -PassThru

    Write-ScreenInfo 'finished' -TaskEnd
}

function InstallWinlogbeat
{
    if (-not (Get-Service winlogbeat -ErrorAction SilentlyContinue)) {
        Write-Host "winlogbeat is installing";
        powershell -f 'C:\ELK\winlogbeat\install-service-winlogbeat.ps1';
        Start-Service winlogbeat;
    } else {
        Write-Host "winlogbeat already installed";
    }
}

#function InstallElasticAgent
#{
#    if (-not (Get-Service elastic-agent -ErrorAction SilentlyContinue)) {
#        Write-Host "elastic-agent is installing";
#        C:\ELK\elastic-agent\elastic-agent.exe install;
#    } else {
#        Write-Host "kibana already installed";
#    }
#}

function InstallPackages
{
    Write-ScreenInfo -Message 'Install Elastic-agents' -TaskStart
    
    #Write-ScreenInfo -Message "Installing  elasticsearch"
    #Invoke-LabCommand -ActivityName InstallElasticAgent -ScriptBlock {InstallElasticAgent} -Function (Get-Command InstallElasticAgent) -ComputerName $ComputerName -PassThru
    
    Write-ScreenInfo -Message "Installing  Winlogbeat"
    Invoke-LabCommand -ActivityName InstallWinlogbeat -ScriptBlock {InstallWinlogbeat} -Function (Get-Command InstallWinlogbeat) -ComputerName $ComputerName -PassThru

    Write-ScreenInfo 'finished' -TaskEnd
}

function Install-Elastic
{
    Write-ScreenInfo "Installing Elastic-agents on '$ComputerName'"  -TaskStart
    Write-ScreenInfo "Starting machine '$ComputerName'" -NoNewLine
    Start-LabVM -ComputerName $ComputerName -Wait
    CopyPackages
    InstallPackages
    Write-ScreenInfo 'finished' -TaskEnd
}

Import-Lab -Name $data.Name

Write-ScreenInfo "Intalling Elastic-agents on '$ComputerName'..." -TaskStart

Install-Elastic

Write-ScreenInfo "Finished installing Elastic-agents on '$ComputerName'" -TaskEnd
