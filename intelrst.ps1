Param (
[switch]$version = $false,
[ValidateSet("lld","info")][Parameter(Position=0, Mandatory=$True)][string]$action,
[ValidateSet("pd","ld")][Parameter(Position=1, Mandatory=$True)][string]$part
)
function makeobj ($count,$array)
{
$obj=for ($i = 0; $i -lt ($array | measure -Line).Lines; $i += $count)
{
   $strings = $array | select -First $count -Skip $i
   $table = @{}
   foreach ($string in $strings){ $fstring = $string -split ":" ; $table.add($fstring[0].trim(),$fstring[1].trim())}
   New-Object psobject -Property $table
 }
 return $obj
}
# this function define rstcli (vroccli) depending on driver version
function rstcmdver
{
$rstpath="C://zabbix_agent//diskutils//rst//"
$cmd="4.6.0_rstcli64.exe"
$rstdriverver=(@((gwmi -query "select DriverVersion from Win32_PnPSignedDriver WHERE DriverProviderName like '%Intel%' and DeviceClass like 'SCSIADAPTER' and not DeviceName like '%Ethernet Virtual Storage%'" | select-object -ExpandProperty DriverVersion).replace(".","")) -join '')
$rstdriverver=$rstdriverver[0,1,2,3] -join '' 
$rstdriverver=[int]$rstdriverver
if 
($rstdriverver -le 1700)
{
$cmd="13_16_rstcli64.exe"
}
elseif 
($rstdriverver -le 5000)
{
$cmd="4.6.0_rstcli64.exe"
}
elseif 
($rstdriverver -le 5030)
{
$cmd="5.0.0_rstcli64.exe"
}
elseif 
($rstdriverver -le 5300)
{
$cmd="5.0.3_rstcli64.exe"
}
elseif 
($rstdriverver -le 5600)
{
$cmd="5.6.0_rstcli64.exe"
}
elseif 
($rstdriverver -le 6200)
{
$cmd="IntelVROCCli.exe"
}
else
{
$cmd="5.3.0_rstcli64.exe"
}
$cmd=$rstpath+$cmd
return $cmd
}
function ldlld
{
$idx = 0
$cmd=rstcmdver
$ldnames=(((& $cmd -I | select-string "Raid Level" -Context 1,0) -split"\n") -match "Name:" -replace "Name:").trim() 2>$null
$ldprejson = ""
$ldjson = ""
foreach ($ldname in $ldnames) 
{
  if (($idx -eq $ldnames.count) -or ($idx -eq 0))
    { 
    }
	else
    {
    $ldprejson +=  ",`n"  
    }
    $ldprejson += "`t {`n " +
            "`t`t`"{#LDNAME}`":`""+$ldname+"`""+    
          "`t }"    
    $idx++;
			}

$ldjson = "{" + "`n" + " `"data`""+ ":[" + $ldprejson + "]" + "`n" + "}"  
return $ldjson
}
function pdlld
{
$idx = 0
$npd=2
$pdjson = ""
$pdprejson = ""
$cmd=rstcmdver
$pdsearchstring='^Type:\s*Disk'
$pdsearchstringfin='(ID|Serial)'
$pdcutstring='(^(?!(.*ID|.*Serial)).*$)'
$pddata=(((((& $cmd -I | select-string -Pattern $pdsearchstring -Context 1,8) -replace ">", "") -replace ":\s*",":")).split("`n") |select-string -pattern $pdsearchstringfin) 2>$null
$pddata=($pddata -ireplace "Serial Number","{#PDSN}")
$pddata=($pddata -ireplace "ID","{#PDID}")
$pdinfo=(makeobj($npd)($pddata))
foreach ($line in $pdinfo)
{
 if (($idx -eq $pdinfo.count) -or ($idx -eq 0))
    { 
    }
	else
    {
    $pdprejson+=  ",`n"  
    }
    $pdprejson+=($line | ConvertTo-Json)
    $idx++;
}

$pdjson = "{" + "`n" + " `"data`""+ ":[" + $pdprejson + "]" + "`n" + "}"  
return $pdjson
}
function ldinfo
{
$idx = 0
$nld=6
$ldjson=@{}
$cmd=rstcmdver
$lddata=((((& $cmd -I | select-string "Raid Level" -Context 1,4) -replace ">", "") -replace ":\s*",":")).split("`n") 2>$null
$ldinfo=(makeobj($nld)($lddata))
$ldinfo | ForEach-Object{
$ID=$_."Name"
$ldjson[$ID]=@{
"State"=$_."State"
"Raid Level"=$_."Raid Level"
"Disks number"=$_."Num Disks"
}
}
return ($ldjson | ConvertTo-Json)
}
function pdinfo
{
$idx = 0
$npd=10
$pdjson=@{}
$cmd=rstcmdver
$pdsearchstring='^Type:\s*Disk'
$pddata=((((& $cmd -I | select-string -Pattern $pdsearchstring -Context 1,8) -replace ">", "") -replace ":\s*",":")).split("`n") 2>$null
$pdinfo=(makeobj($npd)($pddata))
$pdinfo | ForEach-Object{
$ID=$_."ID"
$pdjson[$ID]=@{
"State"=$_."State"
"Serial number"=$_."Serial Number"
"Model"=$_."Model"
}
}
return ($pdjson | ConvertTo-Json)
}
switch($action){
    "lld" {
        switch($part){
            "ld" { write-host $(ldlld)}
            "pd" { write-host $(pdlld)}
        }
    }
    "info" {
        switch($part) {
           "ld" { write-host $(ldinfo) }
           "pd" { write-host $(pdinfo) }
        }
    }
    default {Write-Host "ERROR: Wrong argument: use 'lld' or 'health'"}
}