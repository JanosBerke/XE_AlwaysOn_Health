-- find XE file location
SELECT
    CAST(xt.[target_data] AS XML).value('(/EventFileTarget/File/@name)[1]', 'varchar(8000)')
FROM 
    sys.dm_xe_session_targets xt  
JOIN	   
    sys.dm_xe_sessions xe ON xe.[address] = xt.[event_session_address]
WHERE 
    xe.[name] = 'AlwaysOn_health' 
AND
    xt.[target_name] = 'event_file' 
GO

/***************************************
AG_Health
https://msdn.microsoft.com/en-us/library/dn135324(v=sql.110).aspx#BKMK_Debugging
Not all data types are valid for different versions!!!
Not All columns are available in different versions!!!
****************************************/

DROP TABLE IF EXISTS [#XE_Raw]
GO
CREATE TABLE [#XE_Raw]
(
    [object_name] nvarchar(256),
    [event_data] xml
)
GO
CREATE CLUSTERED INDEX [CI] ON [#XE_Raw] ([object_name])
GO

DECLARE @filePath varchar(8000) = 'd:\temp\aghealth\'
DECLARE @fileNamePattern varchar(8000) = 'AlwaysOn*.xel'

INSERT INTO [#XE_Raw]
SELECT
    [object_name],
    [event_data]
FROM sys.fn_xe_file_target_read_file(@filePath+@fileNamePattern, @filePath+'a.xem', NULL, NULL)
GO

-- alwayson_ddl_executed
SELECT
    --[object_name],
    --[event_data],
    [event_data].value('(event/@timestamp)[1]', 'datetime') AS [timestamp],
    [event_data].value('(event/data[@name=''ddl_action'']/text)[1]', 'varchar(255)') AS [ddl_action],
    [event_data].value('(event/data[@name=''ddl_phase'']/text)[1]', 'varchar(255)') AS [ddl_phase],
    [event_data].value('(event/data[@name=''statement'']/value)[1]', 'varchar(8000)') AS [statement],
    [event_data].value('(event/data[@name=''availability_group_id'']/value)[1]', 'uniqueidentifier') AS [availability_group_id],
    [event_data].value('(event/data[@name=''availability_group_name'']/value)[1]', 'nvarchar(255)') AS [availability_group_name]
FROM
    [#XE_Raw]
WHERE
    [object_name] = 'alwayson_ddl_executed'
GO
-- availability_group_lease_expired
SELECT
    --[object_name],
    --[event_data],
    [event_data].value('(event/@timestamp)[1]', 'datetime') AS [timestamp],
    [event_data].value('(event/data[@name=''current_time'']/value)[1]', 'bigint') AS [current_time],
    [event_data].value('(event/data[@name=''new_timeout'']/value)[1]', 'bigint') AS [new_timeout],
    [event_data].value('(event/data[@name=''lease_interval'']/value)[1]', 'bigint') AS [lease_interval],
    [event_data].value('(event/data[@name=''state'']/text)[1]', 'varchar(8000)') AS [state],
    [event_data].value('(event/data[@name=''availability_group_id'']/value)[1]', 'uniqueidentifier') AS [availability_group_id],
    [event_data].value('(event/data[@name=''availability_group_name'']/value)[1]', 'nvarchar(255)') AS [availability_group_name]
FROM
    [#XE_Raw]
WHERE
    [object_name] = 'availability_group_lease_expired'
GO
-- availability_replica_manager_state_change
SELECT
    --[object_name],
    --[event_data],
    [event_data].value('(event/@timestamp)[1]', 'datetime') AS [timestamp],
    [event_data].value('(event/data[@name=''current_state'']/text)[1]', 'varchar(255)') AS [current_state]
FROM
    [#XE_Raw]
WHERE
    [object_name] = 'availability_replica_manager_state_change'
GO
-- availability_replica_state
SELECT
    --[object_name],
    --[event_data],
    [event_data].value('(event/@timestamp)[1]', 'datetime') AS [timestamp],
    [event_data].value('(event/data[@name=''current_state'']/text)[1]', 'varchar(255)') AS [current_state],
    [event_data].value('(event/data[@name=''availability_group_id'']/value)[1]', 'uniqueidentifier') AS [availability_group_id],
    [event_data].value('(event/data[@name=''availability_group_name'']/value)[1]', 'nvarchar(255)') AS [availability_group_name]
FROM
    [#XE_Raw]
WHERE
    [object_name] = 'availability_replica_state'
GO
-- availability_replica_state_change
SELECT
    --[object_name],
    --[event_data],
    [event_data].value('(event/@timestamp)[1]', 'datetime') AS [timestamp],
    [event_data].value('(event/data[@name=''previous_state'']/text)[1]', 'varchar(255)') AS [previous_state],
    [event_data].value('(event/data[@name=''current_state'']/text)[1]', 'varchar(255)') AS [current_state],
    [event_data].value('(event/data[@name=''availability_group_id'']/value)[1]', 'uniqueidentifier') AS [availability_group_id],
    [event_data].value('(event/data[@name=''availability_group_name'']/value)[1]', 'nvarchar(255)') AS [availability_group_name],
    [event_data].value('(event/data[@name=''availability_replica_name'']/value)[1]', 'nvarchar(255)') AS [availability_replica_name]
FROM
    [#XE_Raw]
WHERE
    [object_name] = 'availability_replica_state_change'
GO
-- error_reported
SELECT
    --[object_name],
    --[event_data],
    [event_data].value('(event/@timestamp)[1]', 'datetime') AS [timestamp],
    [event_data].value('(event/data[@name=''error_number'']/value)[1]', 'int') AS [error_number],
    [event_data].value('(event/data[@name=''severity'']/value)[1]', 'int') AS [severity],
    [event_data].value('(event/data[@name=''state'']/value)[1]', 'int') AS [state],
    [event_data].value('(event/data[@name=''user_defined'']/value)[1]', 'bit') AS [user_defined],
    [event_data].value('(event/data[@name=''category'']/text)[1]', 'nvarchar(4000)') AS [category],
    [event_data].value('(event/data[@name=''destination'']/text)[1]', 'varchar(8000)') AS [destination],
    [event_data].value('(event/data[@name=''is_intercepted'']/value)[1]', 'bit') AS [is_intercepted],
    [event_data].value('(event/data[@name=''message'']/value)[1]', 'nvarchar(max)') AS [message]
FROM
    [#XE_Raw]
WHERE
    [object_name] = 'error_reported'
GO
-- hadr_db_partner_set_sync_state
SELECT
    --[object_name],
    --[event_data],
    [event_data].value('(event/@timestamp)[1]', 'datetime') AS [timestamp],
    [event_data].value('(event/data[@name=''database_id'']/value)[1]', 'smallint') AS [database_id],
    [event_data].value('(event/data[@name=''commit_policy'']/text)[1]', 'varchar(255)') AS [commit_policy],
    [event_data].value('(event/data[@name=''commit_policy_target'']/text)[1]', 'varchar(255)') AS [commit_policy_target],
    [event_data].value('(event/data[@name=''sync_state'']/text)[1]', 'varchar(255)') AS [sync_state],
    [event_data].value('(event/data[@name=''sync_log_block'']/value)[1]', 'bigint') AS [sync_log_block],
    [event_data].value('(event/data[@name=''group_id'']/value)[1]', 'uniqueidentifier') AS [group_id],
    [event_data].value('(event/data[@name=''replica_id'']/value)[1]', 'uniqueidentifier') AS [replica_id],
    [event_data].value('(event/data[@name=''ag_database_id'']/value)[1]', 'uniqueidentifier') AS [ag_database_id]
FROM
    [#XE_Raw]
WHERE
    [object_name] = 'hadr_db_partner_set_sync_state'
GO
-- lock_redo_blocked
SELECT
    --[object_name],
    --[event_data],
    [event_data].value('(event/@timestamp)[1]', 'datetime') AS [timestamp],
    [event_data].value('(event/data[@name=''resource_type'']/text)[1]', 'varchar(8000)') AS [resource_type],
    [event_data].value('(event/data[@name=''mode'']/text)[1]', 'varchar(255)') AS [mode],
    [event_data].value('(event/data[@name=''owner_type'']/text)[1]', 'varchar(255)') AS [owner_type],
    [event_data].value('(event/data[@name=''transaction_id'']/value)[1]', 'bigint') AS [transaction_id],
    [event_data].value('(event/data[@name=''database_id'']/value)[1]', 'smallint') AS [database_id],
    [event_data].value('(event/data[@name=''lockspace_workspace_id'']/value)[1]', 'varchar(255)') AS [lockspace_workspace_id], --varbimary(64)
    [event_data].value('(event/data[@name=''lockspace_sub_id'']/value)[1]', 'int') AS [lockspace_sub_id],
    [event_data].value('(event/data[@name=''lockspace_nest_id'']/value)[1]', 'int') AS [lockspace_nest_id],
    [event_data].value('(event/data[@name=''resource_0'']/value)[1]', 'bigint') AS [resource_0],
    [event_data].value('(event/data[@name=''resource_1'']/value)[1]', 'bigint') AS [resource_1],
    [event_data].value('(event/data[@name=''resource_2'']/value)[1]', 'bigint') AS [resource_2],
    [event_data].value('(event/data[@name=''object_id'']/value)[1]', 'int') AS [object_id],
    [event_data].value('(event/data[@name=''associated_object_id'']/value)[1]', 'bigint') AS [associated_object_id],
    [event_data].value('(event/data[@name=''duration'']/value)[1]', 'bigint') AS [duration_ms],
    [event_data].value('(event/data[@name=''resource_description'']/value)[1]', 'nvarchar(4000)') AS [resource_description],
    [event_data].value('(event/data[@name=''database_name'']/value)[1]', 'sysname') AS [database_name]
FROM
    [#XE_Raw]
WHERE
    [object_name] = 'lock_redo_blocked'
GO
-- availability_replica_automatic_failover_validation

SELECT
    --[object_name],
    --[event_data],
    [event_data].value('(event/@timestamp)[1]', 'datetime') AS [timestamp],
    [event_data].value('(event/data[@name=''forced_quorum'']/value)[1]', 'bit') AS [forced_quorum],
    [event_data].value('(event/data[@name=''joined_and_synchronized'']/value)[1]', 'bit') AS [joined_and_synchronized],
    [event_data].value('(event/data[@name=''previous_primary_or_automatic_failover_target'']/value)[1]', 'bit') AS [previous_primary_or_automatic_failover_target],
    [event_data].value('(event/data[@name=''availability_group_id'']/value)[1]', 'uniqueidentifier') AS [availability_group_id],
    [event_data].value('(event/data[@name=''availability_group_name'']/value)[1]', 'nvarchar(255)') AS [availability_group_name],
    [event_data].value('(event/data[@name=''availability_replica_id'']/value)[1]', 'uniqueidentifier') AS [availability_replica_id],
    [event_data].value('(event/data[@name=''availability_replica_name'']/value)[1]', 'nvarchar(255)') AS [availability_replica_name]
FROM
    [#XE_Raw]
WHERE
    [object_name] = 'availability_replica_automatic_failover_validation'
GO
