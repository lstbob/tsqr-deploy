-- Retrofit tool-library schema hardening onto an existing database.
-- Safe to run repeatedly. Adds CHECK constraints for INTEGER-encoded enums
-- and indexes for the member, inventory, reservation, and loan query paths.
\connect tsqr_tool_library

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE LOWER(conname) = 'ck_tools_tooltype'
          AND conrelid = 'Tools'::regclass
    ) THEN
        ALTER TABLE Tools
            ADD CONSTRAINT CK_Tools_ToolType CHECK (ToolType BETWEEN 0 AND 6);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE LOWER(conname) = 'ck_tools_amortizationrate'
          AND conrelid = 'Tools'::regclass
    ) THEN
        ALTER TABLE Tools
            ADD CONSTRAINT CK_Tools_AmortizationRate
            CHECK (AmortizationRate BETWEEN 0 AND 3);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE LOWER(conname) = 'ck_toolscarcitybylocation_scarcitylevel'
          AND conrelid = 'ToolScarcityByLocation'::regclass
    ) THEN
        ALTER TABLE ToolScarcityByLocation
            ADD CONSTRAINT CK_ToolScarcityByLocation_ScarcityLevel
            CHECK (ScarcityLevel BETWEEN 0 AND 4);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE LOWER(conname) = 'ck_members_status'
          AND conrelid = 'Members'::regclass
    ) THEN
        ALTER TABLE Members
            ADD CONSTRAINT CK_Members_Status CHECK (Status BETWEEN 0 AND 3);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE LOWER(conname) = 'ck_members_membershiptype'
          AND conrelid = 'Members'::regclass
    ) THEN
        ALTER TABLE Members
            ADD CONSTRAINT CK_Members_MembershipType
            CHECK (MembershipType IS NULL OR MembershipType BETWEEN 0 AND 4);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE LOWER(conname) = 'ck_inventoryitems_status'
          AND conrelid = 'InventoryItems'::regclass
    ) THEN
        ALTER TABLE InventoryItems
            ADD CONSTRAINT CK_InventoryItems_Status CHECK (Status BETWEEN 0 AND 5);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE LOWER(conname) = 'ck_inventoryitems_condition'
          AND conrelid = 'InventoryItems'::regclass
    ) THEN
        ALTER TABLE InventoryItems
            ADD CONSTRAINT CK_InventoryItems_Condition
            CHECK (Condition BETWEEN 0 AND 5);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE LOWER(conname) = 'ck_reservations_status'
          AND conrelid = 'Reservations'::regclass
    ) THEN
        ALTER TABLE Reservations
            ADD CONSTRAINT CK_Reservations_Status CHECK (Status BETWEEN 0 AND 5);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE LOWER(conname) = 'ck_maintenancerecords_status'
          AND conrelid = 'MaintenanceRecords'::regclass
    ) THEN
        ALTER TABLE MaintenanceRecords
            ADD CONSTRAINT CK_MaintenanceRecords_Status
            CHECK (Status BETWEEN 0 AND 3);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE LOWER(conname) = 'ck_maintenancerecords_resultingcondition'
          AND conrelid = 'MaintenanceRecords'::regclass
    ) THEN
        ALTER TABLE MaintenanceRecords
            ADD CONSTRAINT CK_MaintenanceRecords_ResultingCondition
            CHECK (ResultingCondition IS NULL OR ResultingCondition BETWEEN 0 AND 5);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE LOWER(conname) = 'ck_policies_tooltype'
          AND conrelid = 'Policies'::regclass
    ) THEN
        ALTER TABLE Policies
            ADD CONSTRAINT CK_Policies_ToolType CHECK (ToolType BETWEEN 0 AND 6);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE LOWER(conname) = 'ck_loans_status'
          AND conrelid = 'Loans'::regclass
    ) THEN
        ALTER TABLE Loans
            ADD CONSTRAINT CK_Loans_Status CHECK (Status BETWEEN 0 AND 4);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS IX_Members_Email
    ON Members (Email);
CREATE INDEX IF NOT EXISTS IX_Members_CommunityId
    ON Members (CommunityId);
CREATE INDEX IF NOT EXISTS IX_InventoryItems_Status
    ON InventoryItems (Status);
CREATE INDEX IF NOT EXISTS IX_InventoryItems_CurrentHolderId
    ON InventoryItems (CurrentHolderId);
CREATE INDEX IF NOT EXISTS IX_Reservations_ItemId
    ON Reservations (ItemId);
CREATE INDEX IF NOT EXISTS IX_Loans_MemberId
    ON Loans (MemberId);
CREATE INDEX IF NOT EXISTS IX_Loans_Status
    ON Loans (Status);
