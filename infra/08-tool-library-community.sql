-- Retrofit CommunityId onto tool-library tables that predate community scoping.
-- Communities live in the tsqr_communities database/service, so CommunityId is a
-- soft reference (plain INTEGER) rather than a cross-database foreign key.
--
-- This script is idempotent: fresh installs already create these columns in
-- 02-tool-library.sql, and existing databases can run it safely.
\connect tsqr_tool_library

ALTER TABLE Members ADD COLUMN IF NOT EXISTS CommunityId INTEGER NOT NULL DEFAULT 1;
ALTER TABLE Tools ADD COLUMN IF NOT EXISTS CommunityId INTEGER NOT NULL DEFAULT 1;
ALTER TABLE InventoryItems ADD COLUMN IF NOT EXISTS CommunityId INTEGER NOT NULL DEFAULT 1;
ALTER TABLE Manufacturers ADD COLUMN IF NOT EXISTS CommunityId INTEGER NOT NULL DEFAULT 1;
ALTER TABLE Loans ADD COLUMN IF NOT EXISTS CommunityId INTEGER NOT NULL DEFAULT 1;
ALTER TABLE Reservations ADD COLUMN IF NOT EXISTS CommunityId INTEGER NOT NULL DEFAULT 1;
ALTER TABLE MaintenanceRecords ADD COLUMN IF NOT EXISTS CommunityId INTEGER NOT NULL DEFAULT 1;
