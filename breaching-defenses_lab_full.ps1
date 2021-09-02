#--------------------------------------------------------------------------------------------------------------------
# Setting up the breaching-Defenses.com lab
#--------------------------------------------------------------------------------------------------------------------
$labName = 'BreachingDefensesFull' #the name of the lab
#--------------------------------------------------------------------------------------------------------------------


Write-ScreenInfo -Message 'Prepare resources' -TaskStart
. $PSScriptRoot\utils.ps1 -labName $labName 
Write-ScreenInfo -Message 'Finished' -TaskEnd



#--------------------------------------------------------------------------------------------------------------------
# Set the credentials
#--------------------------------------------------------------------------------------------------------------------
Add-LabDomainDefinition -Name $domain -AdminUser $AdminUser -AdminPassword $AdminPassword
Add-LabDomainDefinition -Name $childDomain -AdminUser $AdminUser -AdminPassword $AdminPassword
#--------------------------------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------------------------------
# Forest breachdefs.com
#--------------------------------------------------------------------------------------------------------------------
# the domain controller of the first forest
Add-LabMachineDefinition -Name DC1 -ResourceName DC1 -IpAddress 192.168.42.10 -Roles $roleDC -PostInstallationActivity $roleBadBlood, $roleInstallElastic

# The Exchange Server 
Add-LabMachineDefinition -Name OWA -ResourceName OWA -MaxMemory 6144MB -Memory 6144MB -IpAddress 192.168.42.11 -PostInstallationActivity $roleExchange2016, $roleInstallElastic

# The SQL Servers
Add-LabMachineDefinition -Name SQL1 -ResourceName SQL1 -IpAddress 192.168.42.12 -Roles SQLServer2014 -PostInstallationActivity $roleInstallElastic
Add-LabMachineDefinition -Name SQL2 -ResourceName SQL2 -IpAddress 192.168.42.13 -Roles SQLServer2014 -PostInstallationActivity $roleInstallElastic

#--------------------------------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------------------------------
# Forest it.breachdefs.com
#--------------------------------------------------------------------------------------------------------------------
# The child domain controller 
Add-LabMachineDefinition -Name DC2 -ResourceName DC2 -IpAddress 192.168.42.150 -DnsServer1 192.168.42.150 -DnsServer2 192.168.42.10 -DomainName $childDomain -Roles $roleDCChild -PostInstallationActivity $roleBadBlood, $roleInstallElastic

# The Workstations
Add-LabMachineDefinition -Name Wrkstn-1 -ResourceName Wrkstn-1 -IpAddress 192.168.42.151 -DnsServer1 192.168.42.150 -DnsServer2 192.168.42.10 -DomainName $childDomain -OperatingSystem 'Windows 10 Pro' -PostInstallationActivity $roleInstallElastic
Add-LabMachineDefinition -Name Wrkstn-2 -ResourceName Wrkstn-2 -IpAddress 192.168.42.152 -DnsServer1 192.168.42.150 -DnsServer2 192.168.42.10 -DomainName $childDomain -OperatingSystem 'Windows 10 Pro' -PostInstallationActivity $roleInstallElastic

# The ELK Server 
Add-LabMachineDefinition -Processors 2 -MaxMemory 4096MB -Memory 4096MB -Name ELK -ResourceName ELK -IpAddress 192.168.42.200 -DnsServer1 192.168.42.150 -DnsServer2 192.168.42.10 -DomainName $childDomain -PostInstallationActivity $roleELK
#--------------------------------------------------------------------------------------------------------------------

Install-Lab

Write-ScreenInfo -Message 'Install Tools' -TaskStart
. $PSScriptRoot\tools.ps1 -labSources $labSources 
Write-ScreenInfo -Message 'Finished' -TaskEnd

Checkpoint-LabVM -All -SnapshotName 'FirstSnapshot'
