# XE_AlwaysOn_Health
This script library provides a detailed view of the AlwasOn__Health Extended Event xml file.

The default AlwaysOn_Health Extened Event session logs the following events:

- alwayson_ddl_executed
- availability_group_lease_expired
- availability_replica_automatic_failover_validation
- availability_replica_manager_state_change
- availability_replica_state
- availability_replica_state_change
- error_reported
- hadr_db_partner_set_sync_state
- lock_redo_blocked

Script has 2 parameters:
1. @filePath: this is the path of the xel files.
2. @fileNamePattern: this is the file name pattern which will be searched for. This library is using the default AlwaysOn_Health file name convention/pattern.

Each result set returns the different event types with all details where available. Not all event fields are availabel in all versions. 
