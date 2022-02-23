#--------------------------------------------------------------------------------------------------------------------
# Setting up the breaching-Defenses.com lab
#--------------------------------------------------------------------------------------------------------------------
$labName = 'BreachingDefensesLab2' #the name of the lab
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
Add-LabMachineDefinition -Name DC1 -ResourceName 2-DC1 -IpAddress 192.168.57.10 -Roles $roleDC -PostInstallationActivity $roleBadBlood, $roleInstallElastic

# The Exchange Server 
Add-LabMachineDefinition -Name OWA -ResourceName 2-OWA -MaxMemory 6144MB -Memory 6144MB -IpAddress 192.168.57.11 -PostInstallationActivity $roleExchange2016, $roleInstallElastic
#--------------------------------------------------------------------------------------------------------------------

Install-Lab

Write-ScreenInfo -Message 'Install Tools' -TaskStart
. $PSScriptRoot\tools.ps1 -labSource $labSources 
Write-ScreenInfo -Message 'Finished' -TaskEnd

Checkpoint-LabVM -All -SnapshotName 'FirstSnapshot'
