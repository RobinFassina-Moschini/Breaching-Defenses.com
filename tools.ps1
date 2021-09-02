param(
    [Parameter(Mandatory)]
    [string]$labSource
)

#--------------------------------------------------------------------------------------------------------------------
# Install software to all lab machines
#--------------------------------------------------------------------------------------------------------------------
$packs = @()
$packs += Get-LabSoftwarePackage -Path $labSource\Tools\processhacker.exe -CommandLine "install /silent"
$packs += Get-LabSoftwarePackage -Path $labSource\Tools\SysInternals\Sysmon64.exe -CommandLine "-i -accepteula -h md5,sha256 -l"
$packs += Get-LabSoftwarePackage -Path $labSource\Tools\Firefox.exe -CommandLine "/S"

Install-LabSoftwarePackages -Machine (Get-LabVM -All) -SoftwarePackage $packs
#--------------------------------------------------------------------------------------------------------------------
