-- Retrofit support schema hardening onto an existing database.
-- Safe to run repeatedly: adds soft-delete audit columns, enum CHECK
-- constraints, and indexes for the community/status query paths.
\connect tsqr_support

ALTER TABLE Incidents ADD COLUMN IF NOT EXISTS DeletedAt TIMESTAMP NULL;
ALTER TABLE Incidents ADD COLUMN IF NOT EXISTS DeletedBy VARCHAR(200) NULL;
ALTER TABLE Tickets ADD COLUMN IF NOT EXISTS DeletedAt TIMESTAMP NULL;
ALTER TABLE Tickets ADD COLUMN IF NOT EXISTS DeletedBy VARCHAR(200) NULL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE LOWER(conname) = 'ck_apps_status'
           AND conrelid = 'Apps'::regclass
    ) THEN
        ALTER TABLE Apps ADD CONSTRAINT CK_Apps_Status
            CHECK (Status IN (1, 2, 3));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE LOWER(conname) = 'ck_servicestatuses_state'
           AND conrelid = 'ServiceStatuses'::regclass
    ) THEN
        ALTER TABLE ServiceStatuses ADD CONSTRAINT CK_ServiceStatuses_State
            CHECK (State IN (1, 2, 3));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE LOWER(conname) = 'ck_servicestatuses_uptime'
           AND conrelid = 'ServiceStatuses'::regclass
    ) THEN
        ALTER TABLE ServiceStatuses ADD CONSTRAINT CK_ServiceStatuses_Uptime
            CHECK (UptimePercent30d BETWEEN 0 AND 100);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE LOWER(conname) = 'ck_incidents_status'
           AND conrelid = 'Incidents'::regclass
    ) THEN
        ALTER TABLE Incidents ADD CONSTRAINT CK_Incidents_Status
            CHECK (Status IN (1, 2, 3));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE LOWER(conname) = 'ck_incidents_durationminutes'
           AND conrelid = 'Incidents'::regclass
    ) THEN
        ALTER TABLE Incidents ADD CONSTRAINT CK_Incidents_DurationMinutes
            CHECK (DurationMinutes >= 0);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE LOWER(conname) = 'ck_incidents_communityid'
           AND conrelid = 'Incidents'::regclass
    ) THEN
        ALTER TABLE Incidents ADD CONSTRAINT CK_Incidents_CommunityId
            CHECK (CommunityId > 0);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE LOWER(conname) = 'ck_tickets_category'
           AND conrelid = 'Tickets'::regclass
    ) THEN
        ALTER TABLE Tickets ADD CONSTRAINT CK_Tickets_Category
            CHECK (Category IN (1, 2, 3, 4));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE LOWER(conname) = 'ck_tickets_priority'
           AND conrelid = 'Tickets'::regclass
    ) THEN
        ALTER TABLE Tickets ADD CONSTRAINT CK_Tickets_Priority
            CHECK (Priority IN (1, 2, 3, 4));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE LOWER(conname) = 'ck_tickets_status'
           AND conrelid = 'Tickets'::regclass
    ) THEN
        ALTER TABLE Tickets ADD CONSTRAINT CK_Tickets_Status
            CHECK (Status IN (1, 2, 3, 4));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE LOWER(conname) = 'ck_tickets_communityid'
           AND conrelid = 'Tickets'::regclass
    ) THEN
        ALTER TABLE Tickets ADD CONSTRAINT CK_Tickets_CommunityId
            CHECK (CommunityId > 0);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS IX_Apps_Status
    ON Apps (Status);
CREATE INDEX IF NOT EXISTS IX_ServiceStatuses_State
    ON ServiceStatuses (State);
CREATE INDEX IF NOT EXISTS IX_Incidents_CommunityId_OccurredOn
    ON Incidents (CommunityId, OccurredOn DESC) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Incidents_Status
    ON Incidents (Status) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Tickets_CommunityId_ReportedAt
    ON Tickets (CommunityId, ReportedAt DESC) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Tickets_CommunityId_Status_ReportedAt
    ON Tickets (CommunityId, Status, ReportedAt DESC) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Tickets_Status
    ON Tickets (Status) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_ContactMessages_TicketId
    ON ContactMessages (TicketId);
