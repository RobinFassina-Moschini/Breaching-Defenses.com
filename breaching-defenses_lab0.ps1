#--------------------------------------------------------------------------------------------------------------------
# Setting up the breaching-Defenses.com lab
#--------------------------------------------------------------------------------------------------------------------
$labName = 'BreachingDefensesLab0' #the name of the lab
#--------------------------------------------------------------------------------------------------------------------

Write-ScreenInfo -Message 'Prepare resources' -TaskStart
. $PSScriptRoot\utils.ps1 -labName $labName 
Write-ScreenInfo -Message 'Finished' -TaskEnd


#--------------------------------------------------------------------------------------------------------------------
# Set the credentials
#--------------------------------------------------------------------------------------------------------------------
Add-LabDomainDefinition -Name $domain -AdminUser $AdminUser -AdminPassword $AdminPassword
#--------------------------------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------------------------------
# Forest breachdefs.com
#--------------------------------------------------------------------------------------------------------------------
# the domain controller of the first forest
Add-LabMachineDefinition -Name DC1  -ResourceName 0-DC1 -IpAddress 192.168.42.10 -Roles $roleDCOnlyForest -PostInstallationActivity $roleBadBlood
#--------------------------------------------------------------------------------------------------------------------


Install-Lab

Write-ScreenInfo -Message 'Install Tools' -TaskStart
. $PSScriptRoot\tools.ps1 -labSource $labSources 
Write-ScreenInfo -Message 'Finished' -TaskEnd

Checkpoint-LabVM -All -SnapshotName 'FirstSnapshot'
