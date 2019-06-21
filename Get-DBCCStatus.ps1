import-module dbatools;
$ServerToCheck = 'YOURSERVER'
$results = Get-DbaLastGoodCheckDb -SqlInstance $ServerToCheck;
$results;