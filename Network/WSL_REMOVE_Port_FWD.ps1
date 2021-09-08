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
#Remove Firewall Exception Rules
iex "Remove-NetFireWallRule -DisplayName $name ";
iex "netsh interface portproxy delete v4tov4 listenport=$port listenaddress='0.0.0.0'";
