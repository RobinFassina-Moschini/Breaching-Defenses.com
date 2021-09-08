param(
    [Parameter(Mandatory)]
    [string]$port
)

$remoteport = bash.exe -c "ifconfig eth0 | grep 'inet '"
$found = $remoteport -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

if( $found ){
  $remoteport = $matches[0];
} else{
  echo "WSL2 ip cannot be found";
  exit;
}

$name = 'WSL2_network_' + $port
#adding Exception Rules for inbound and outbound Rules
iex "New-NetFireWallRule -Group 'WSL2_network' -DisplayName $name -Direction Outbound -LocalPort $port -Action Allow -Protocol TCP";
iex "New-NetFireWallRule -Group 'WSL2_network' -DisplayName $name -Direction Inbound -LocalPort $port -Action Allow -Protocol TCP";
iex "New-NetFireWallRule -Group 'WSL2_network' -DisplayName $name -Direction Outbound -LocalPort $port -Action Allow -Protocol UDP";
iex "New-NetFireWallRule -Group 'WSL2_network' -DisplayName $name -Direction Inbound -LocalPort $port -Action Allow -Protocol UDP";

iex "netsh interface portproxy delete v4tov4 listenport=$port listenaddress='0.0.0.0'";
iex "netsh interface portproxy add v4tov4 listenport=$port listenaddress='0.0.0.0' connectport=$port connectaddress=$remoteport";
