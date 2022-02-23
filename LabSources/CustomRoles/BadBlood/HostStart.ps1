param(
    [Parameter(Mandatory)]
    [string]$ComputerName
)

function Disable-PasswordComplexity
{
    param()

    $secEditPath = [System.Environment]::ExpandEnvironmentVariables("%SystemRoot%\system32\secedit.exe")
    $tempFile = [System.IO.Path]::GetTempFileName()

    $exportArguments = '/export /cfg "{0}" /quiet' -f $tempFile
    $importArguments = '/configure /db secedit.sdb /cfg "{0}" /quiet' -f $tempFile

    Start-Process -FilePath $secEditPath -ArgumentList $exportArguments -Wait

    $currentConfig = Get-Content -Path $tempFile

    $currentConfig = $currentConfig -replace 'PasswordComplexity = .', 'PasswordComplexity = 0'
    $currentConfig = $currentConfig -replace 'MinimumPasswordLength = .', 'MinimumPasswordLength = 0'
    $currentConfig | Out-File -FilePath $tempFile

    Start-Process -FilePath $secEditPath -ArgumentList $importArguments -Wait
   
    Remove-Item -Path .\secedit.sdb
    Remove-Item -Path $tempFile
}

function Install-BadBlood
{
    Write-ScreenInfo -Message 'Run BadBlood' -TaskStart
    Invoke-LabCommand -ActivityName RunBadBlood -ScriptBlock { cd C:\Tools\BadBlood ; .\Invoke-BadBlood.ps1 -NonInteractive -UserCount 500 -GroupCount 50 -ComputerCount 100 } -ComputerName $ComputerName -PassThru

    Write-ScreenInfo 'finished' -TaskEnd
}

function Create-LowPriv-Account
{
    $pwd = "Password1"
    new-aduser -Description "Low privaccount" -DisplayName Dummy -GivenName Dummy -name Dummy -SamAccountName Dummy -Surname Dummy -Enabled $true -AccountPassword (ConvertTo-SecureString ($pwd) -AsPlainText -force)
}

Import-Lab -Name $data.Name

Write-ScreenInfo "Intalling BadBlood on '$ComputerName'..." -TaskStart
Write-ScreenInfo "Disabling password complexity on '$ComputerName'..."
Invoke-LabCommand -ActivityName Disable-PasswordComplexity -ScriptBlock {Disable-PasswordComplexity} -Function (Get-Command Disable-PasswordComplexity) -ComputerName $ComputerName -PassThru
Write-ScreenInfo "Create dummy account on '$ComputerName'..."
Invoke-LabCommand -ActivityName Create-LowPriv-Account -ScriptBlock {Create-LowPriv-Account} -Function (Get-Command Create-LowPriv-Account) -ComputerName $ComputerName -PassThru
Write-ScreenInfo "Running BadBlood on '$ComputerName'..."
#Install-BadBlood

Write-ScreenInfo "Finished installing BadBlood on '$ComputerName'" -TaskEnd
