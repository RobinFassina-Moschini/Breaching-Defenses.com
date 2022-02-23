param(
    [Parameter(Mandatory)]
    [string]$ComputerName
)

function InstallElasticAgent
{
    if (-not (Get-Service elastic-agent -ErrorAction SilentlyContinue)) {
        Write-Host "elastic-agent is installing";
        C:\Tools\ELK\elastic-agent\elastic-agent.exe install --insecure -f --url=http://elk.breachdefs.com:28220 --enrollment-token=dE9EOUduOEJWdGtRcU9OQ3BXMUU6RE9yRjctYTlTMzZhRjRtT2RtSTJMdw==;
    } else {
        Write-Host "Elastic agent already installed";
   }
}

function InstallPackages
{
    Write-ScreenInfo -Message 'Install Elastic-agents' -TaskStart
    
    Write-ScreenInfo -Message "Installing  elasticsearch"
    Invoke-LabCommand -ActivityName InstallElasticAgent -ScriptBlock {InstallElasticAgent} -Function (Get-Command InstallElasticAgent) -ComputerName $ComputerName -PassThru

    Write-ScreenInfo 'finished' -TaskEnd
}

function Install-Elastic
{
    Write-ScreenInfo "Installing Elastic-agents on '$ComputerName'"  -TaskStart
    Write-ScreenInfo "Starting machine '$ComputerName'" -NoNewLine
    Start-LabVM -ComputerName $ComputerName -Wait
    InstallPackages
    Write-ScreenInfo 'finished' -TaskEnd
}

Import-Lab -Name $data.Name

Write-ScreenInfo "Intalling Elastic-agents on '$ComputerName'..." -TaskStart

Install-Elastic

Write-ScreenInfo "Finished installing Elastic-agents on '$ComputerName'" -TaskEnd
