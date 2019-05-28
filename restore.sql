
DECLARE @fileListTable TABLE (
    [LogicalName]           NVARCHAR(128),
    [PhysicalName]          NVARCHAR(260),
    [Type]                  CHAR(1),
    [FileGroupName]         NVARCHAR(128),
    [Size]                  NUMERIC(20,0),
    [MaxSize]               NUMERIC(20,0),
    [FileID]                BIGINT,
    [CreateLSN]             NUMERIC(25,0),
    [DropLSN]               NUMERIC(25,0),
    [UniqueID]              UNIQUEIDENTIFIER,
    [ReadOnlyLSN]           NUMERIC(25,0),
    [ReadWriteLSN]          NUMERIC(25,0),
    [BackupSizeInBytes]     BIGINT,
    [SourceBlockSize]       INT,
    [FileGroupID]           INT,
    [LogGroupGUID]          UNIQUEIDENTIFIER,
    [DifferentialBaseLSN]   NUMERIC(25,0),
    [DifferentialBaseGUID]  UNIQUEIDENTIFIER,
    [IsReadOnly]            BIT,
    [IsPresent]             BIT,
    [TDEThumpprint]         NVARCHAR(128),
    [SnapshotUrl]           NVARCHAR(128)
)
INSERT INTO @fileListTable EXEC(N'RESTORE FILELISTONLY FROM DISK=''$(backup)''')
SELECT * FROM @fileListTable

DECLARE @mdf nvarchar(255)
SELECT @mdf = [LogicalName] FROM @fileListTable WHERE [Type] = 'D'
DECLARE @mdfLocation nvarchar(255)
SELECT @mdfLocation = N'$(databaseLocation)' + '\' + [LogicalName] + '.mdf' FROM @fileListTable WHERE [Type] = 'D'

DECLARE @ldf nvarchar(255)
SELECT @ldf = [LogicalName] FROM @fileListTable WHERE [Type] = 'L'
DECLARE @ldfLocation nvarchar(255)
SELECT @ldfLocation = N'$(databaseLocation)' + '\' + [LogicalName] + '.ldf' FROM @fileListTable WHERE [Type] = 'L'

RESTORE DATABASE [$(databaseName)] FROM DISK= N'$(backup)'
WITH 
   MOVE @mdf TO @mdfLocation,
   MOVE @ldf TO @ldfLocation