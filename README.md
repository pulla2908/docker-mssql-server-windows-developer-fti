# Windows Docker Image for Sql Server 2017 with Full-Text Index

# Content
Docker definition for Microsoft SQL Server Developer 2017 including **Full-Text Index** enabled based on Windows Server Core 1809. This docker definition is a fork from [Microsoft/mssql-docker on GitHub](https://github.com/Microsoft/mssql-docker) and was extended to support Full-Text Index.

# Requirements
This image is compatible with Windows Server 2016 and Windows 10.

# Configuration
```
SA_PASSWORD (mandatory)
```
When creating a container a password needs to be provided. The password must be strong and full-fill sql server **password policy** (e.g. a GUID ;-) ). Regarding password policy have a look at [Password Policy](https://docs.microsoft.com/en-us/sql/relational-databases/security/password-policy?view=sql-server-2017)
```
ATTACH_DBS (optional)
```
Attach a set of databases to the server automatically when creating the container. The set is configured in JSON. This parameter must be used in combination to **-v** to mount the physical database location.
>```
>[
>   {
>       'dbName': 'SampleDB', 
>       'dbFiles': ['C:\\databases\\SampleDB.mdf', 'C:\\databases\\SampleDB.ldf']
>   },
>   ...
>]
>```

> - dbName: The name of the database
> - dbFiles: Database files **within the container**

# How to use
Create image from docker definition:
```
docker build -t mssql-developer-fti .
```

To create a new container run the following command:
```
docker run -e SA_PASSWORD=<sa-password> -p 1533:1433 -d --name mssql-fti mssql-developer-fti
```

Create a new container and attach a database (e.g. database 'SampleDB' exists at c:/databases/):
```
docker run -e SA_PASSWORD=<sa-password> -v C:/databases/:C:/databases/ -e ATTACH_DBS="[{'dbName':'SampleDB','dbFiles':['C:\\databases\\SampleDB.mdf','C:\\databases\\SampleDB.ldf']}]" -p 1533:1433 -d --name mssql-fti mssql-developer-fti
```

To connect to the server you can use e.g. [SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017).
For an app the connectionstring should look like this:
```
Connectionstring for container: Data Source=localhost,1533; User Id=sa; pwd=<sa-password>;
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

Connect to the container via sqlcmd:
```
sqlcmd -U sa -P <sa-password> -S localhost,1533
> print Suser_Sname()
> GO
>> Should show "sa"
> QUIT
```