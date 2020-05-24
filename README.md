# Windows Docker Image for Microsoft Sql Server 2017 Developer with Full-Text Index

# Content
Docker definition for **Microsoft SQL Server 2017 Developer** including **Full-Text Index** enabled based on **Windows Server Core 2019 (ltsc)**. This docker definition is a fork from [Microsoft/mssql-docker on GitHub](https://github.com/Microsoft/mssql-docker) and was extended to support Full-Text Index.

This image is compatible with Windows Server 2016 and Windows 10 and available at [hub.docker.com](https://hub.docker.com/r/pulla/mssql-server-windows-developer-fti)

![](https://img.shields.io/docker/pulls/pulla/mssql-server-windows-developer-fti.svg)

# How to use this docker definition
## Get started
Create image from docker definition:
```
docker build -t mssql-server-windows-developer-fti .
```
Note: If you get an error like 'The remote name could not be resolved: 'go.microsoft.com'' then try to add **--network "Default Switch"** and run again (see [cannot resolve go.microsoft.com](https://github.com/pulla2908/docker-mssql-server-windows-developer-fti/issues/2)):
```
docker build -t mssql-server-windows-developer-fti . --network "Default Switch"
```
## How to configure
```
SA_PASSWORD (mandatory)
```
When creating a container a password needs to be provided. The password must be strong and full-fill sql server **password policy** (e.g. a GUID ;-) ). Regarding password policy have a look at [Password Policy](https://docs.microsoft.com/en-us/sql/relational-databases/security/password-policy?view=sql-server-2017)

All samples here use following valid default password: **Password123**

```
ATTACH_DBS (optional)
```
Attach a set of databases to the server automatically when creating the container. The set is configured in JSON. This parameter must be used in combination to **-v** to mount the physical database location.
>```
>[
>   {
>       'dbName': 'SampleDB', 
>       'dbFiles': ['c:\\databases\\SampleDB.mdf', 'c:\\databases\\SampleDB.ldf']
>   },
>   ...
>]
>```

> - dbName: The name of the database
> - dbFiles: Database files **within the container**

```
RESTORE_DBS (optional)
```
Restore a set of database backups to the server automatically when creating the container. The set is configured in JSON. This parameter must be used in combination to **-v** to mount the physical backup location.
>```
>[
>   {
>       'dbName': 'SampleDB', 
>       'dbBackup': 'C:\\databases\\SampleDB.bak',
>       'dbLocation': 'C:\\databases\\'
>   },
>   ...
>]
>```

> - dbName: The name of the database
> - dbBackup: The location of the backup **within the container**
> - dbLocation: Specifies the location **within the container** where database files of the backup should be relocated


## Create container from image
To create a new container run the following command:
```
docker run -e "SA_PASSWORD=Password123" -p 1533:1433 -d --name mssql-fti mssql-server-windows-developer-fti
```

Create a new container and attach a database (e.g. database 'SampleDB' exists at c:\databases\):
```
docker run -e "SA_PASSWORD=Password123" -v "c:/databases/:C:/databases/" -e "ATTACH_DBS=[{'dbName':'SampleDB','dbFiles':['c:\\databases\\SampleDB.mdf','c:\\databases\\SampleDB_log.ldf']}]" -p 1533:1433 -d --name mssql-fti mssql-server-windows-developer-fti
```

Create a new container and restore a backup of a database (e.g. backup exists at c:\databases\):
```
docker run -e "SA_PASSWORD=Password123" -v "c:/databases/:C:/databases/" -e "RESTORE_DBS=[{'dbName':'SampleDB','dbBackup':'C:\\databases\\SampleDB.bak', 'dbLocation':'C:\\databases\\'}]" -p 1533:1433 -d --name mssql-fti mssql-server-windows-developer-fti
```

To connect to the server you can use e.g. [SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017).
For an app the connectionstring should look like this:
```
Connectionstring for container: Data Source=localhost,1533; User Id=sa; pwd=Password123;
```

# Some useful commands
The ip address of the server can be obtained by this:
```
docker inspect --format '{{.NetworkSettings.Networks.nat.IPAddress}}' mssql-fti
```

View logs for trouble shooting:
```
docker logs mssql-fti
```

Connect to the container via sqlcmd and list databases:
```
sqlcmd -U sa -P Password123 -S localhost,1533
> SELECT name FROM master.sys.databases
> GO
>> Should show a list of databases
> QUIT
```

Execute sqlcmd within the container and list databases:
```
docker exec mssql-fti sqlcmd -q "SELECT name FROM master.sys.databases"
```

Restore a database from backup within the container. Note: c:\databases is mounted to the container and the original file location of the backup is c:\databases.
```
docker exec mssql-fti sqlcmd -q "RESTORE DATABASE SampleDB FROM DISK = 'c:\databases\SampleDB.bak'"
```