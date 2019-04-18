param(
    [Parameter(Mandatory=$false)]
    [string]$sa_password
)

Write-Verbose "Starting SQL Server"
start-service MSSQLSERVER

if(!$sa_password) {
    Write-Verbose "ERROR: No password for user 'sa' provided"
    exit 1
} 
else 
{
    Write-Verbose "Changing SA login credentials"
    $sqlcmd = "ALTER LOGIN sa with password=" +"'" + $sa_password + "'" + ";ALTER LOGIN sa ENABLE;"
    & sqlcmd -Q $sqlcmd
}

Write-Verbose "Started SQL Server."

$lastCheck = (Get-Date).AddSeconds(-2) 
while ($true) 
{ 
    Get-EventLog -LogName Application -Source "MSSQL*" -After $lastCheck | Select-Object TimeGenerated, EntryType, Message	 
    $lastCheck = Get-Date 
    Start-Sleep -Seconds 2 
}