-- Add CommunityId to all tool-library tables
-- Communities live in the tsqr_communities database/service, so CommunityId is a
-- soft reference (plain INTEGER) rather than a cross-database foreign key.
\connect tsqr_tool_library

ALTER TABLE Members ADD COLUMN CommunityId INTEGER NOT NULL DEFAULT 1;
ALTER TABLE Tools ADD COLUMN CommunityId INTEGER NOT NULL DEFAULT 1;
ALTER TABLE InventoryItems ADD COLUMN CommunityId INTEGER NOT NULL DEFAULT 1;
ALTER TABLE Manufacturers ADD COLUMN CommunityId INTEGER NOT NULL DEFAULT 1;
ALTER TABLE Loans ADD COLUMN CommunityId INTEGER NOT NULL DEFAULT 1;
ALTER TABLE Reservations ADD COLUMN CommunityId INTEGER NOT NULL DEFAULT 1;
ALTER TABLE MaintenanceRecords ADD COLUMN CommunityId INTEGER NOT NULL DEFAULT 1;
