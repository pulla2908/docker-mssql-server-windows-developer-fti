param(
    [Parameter(Mandatory=$false)]
    [string]$sa_password,

    [Parameter(Mandatory=$false)]
    [string]$attach_dbs,

    [Parameter(Mandatory=$false)]
    [string]$restore_dbs
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

$attach_dbs_cleaned = $attach_dbs.TrimStart('\\').TrimEnd('\\')
$attach_dbs_Json = $attach_dbs_cleaned | ConvertFrom-Json

if ($null -ne $attach_dbs_Json -And $attach_dbs_Json.Length -gt 0)
{
    Write-Verbose "Attaching $($attach_dbs_Json.Length) database(s)"
	    
    Foreach($db in $attach_dbs_Json) 
    {            
        $files = @();
        Foreach($file in $db.dbFiles)
        {
            $files += "(FILENAME = N'$($file)')";           
        }

        $files = $files -join ","
        $sqlcmd = "IF EXISTS (SELECT 1 FROM SYS.DATABASES WHERE NAME = '" + $($db.dbName) + "') BEGIN EXEC sp_detach_db [$($db.dbName)] END;CREATE DATABASE [$($db.dbName)] ON $($files) FOR ATTACH;"

        Write-Verbose "Invoke-Sqlcmd -Query $($sqlcmd)"
        & sqlcmd -Q $sqlcmd
	}
}

$restore_dbs_cleaned = $restore_dbs.TrimStart('\\').TrimEnd('\\')
$restore_dbs_Json = $restore_dbs_cleaned | ConvertFrom-Json

if ($null -ne $restore_dbs_Json -And $restore_dbs_Json.Length -gt 0)
{
    Write-Verbose "Restoring $($restore_dbs_Json.Length) database(s)"
	    
    Foreach($db in $restore_dbs_Json) 
    {            
        $parameters = @("backup=" + $db.dbBackup + "") + @("databaseName=" + $db.dbName + "") + @("databaseLocation=" + $db.dbLocation + "")

        Write-Host "Parameters for restore:" $parameters

        Invoke-Sqlcmd -InputFile "restore.sql" -Variable $parameters
	}
}

Write-Verbose "Started SQL Server."

$lastCheck = (Get-Date).AddSeconds(-2) 
while ($true) 
{ 
    Get-EventLog -LogName Application -Source "MSSQL*" -After $lastCheck | Select-Object TimeGenerated, EntryType, Message	 
    $lastCheck = Get-Date 
    Start-Sleep -Seconds 2 
}