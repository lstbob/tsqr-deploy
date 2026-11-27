-- Allow the Lost loan status and the Cancelled maintenance status on an existing tool-library DB.
-- Safe to run repeatedly.
\connect tsqr_tool_library

BEGIN;
ALTER TABLE Loans DROP CONSTRAINT IF EXISTS CK_Loans_Status;
ALTER TABLE Loans ADD CONSTRAINT CK_Loans_Status CHECK (Status BETWEEN 0 AND 5);
ALTER TABLE MaintenanceRecords DROP CONSTRAINT IF EXISTS CK_MaintenanceRecords_Status;
ALTER TABLE MaintenanceRecords ADD CONSTRAINT CK_MaintenanceRecords_Status CHECK (Status BETWEEN 0 AND 4);
COMMIT;
