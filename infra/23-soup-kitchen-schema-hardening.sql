-- Retrofit soup-kitchen schema hardening onto an existing database.
-- Safe to run repeatedly: adds audit columns, enum CHECK constraints, FK
-- indexes, and aligns the volunteer uniqueness index with soft deletes.
\connect tsqr_soup_kitchen

ALTER TABLE Events ADD COLUMN IF NOT EXISTS DeletedAt TIMESTAMP;
ALTER TABLE Events ADD COLUMN IF NOT EXISTS DeletedBy VARCHAR(200);
ALTER TABLE Meals ADD COLUMN IF NOT EXISTS DeletedAt TIMESTAMP;
ALTER TABLE Meals ADD COLUMN IF NOT EXISTS DeletedBy VARCHAR(200);
ALTER TABLE Volunteers ADD COLUMN IF NOT EXISTS DeletedAt TIMESTAMP;
ALTER TABLE Volunteers ADD COLUMN IF NOT EXISTS DeletedBy VARCHAR(200);
ALTER TABLE Donations ADD COLUMN IF NOT EXISTS DeletedAt TIMESTAMP;
ALTER TABLE Donations ADD COLUMN IF NOT EXISTS DeletedBy VARCHAR(200);
ALTER TABLE Guests ADD COLUMN IF NOT EXISTS DeletedAt TIMESTAMP;
ALTER TABLE Guests ADD COLUMN IF NOT EXISTS DeletedBy VARCHAR(200);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_events_status'
           AND conrelid = 'Events'::regclass
    ) THEN
        ALTER TABLE Events ADD CONSTRAINT CK_Events_Status
            CHECK (Status IN (1, 2, 3, 4));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_events_maxguests'
           AND conrelid = 'Events'::regclass
    ) THEN
        ALTER TABLE Events ADD CONSTRAINT CK_Events_MaxGuests
            CHECK (MaxGuests IS NULL OR MaxGuests > 0);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_meals_category'
           AND conrelid = 'Meals'::regclass
    ) THEN
        ALTER TABLE Meals ADD CONSTRAINT CK_Meals_Category
            CHECK (Category IN (1, 2, 3, 4, 5, 6));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_meals_quantityneeded'
           AND conrelid = 'Meals'::regclass
    ) THEN
        ALTER TABLE Meals ADD CONSTRAINT CK_Meals_QuantityNeeded
            CHECK (QuantityNeeded >= 0);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_meals_quantityprepared'
           AND conrelid = 'Meals'::regclass
    ) THEN
        ALTER TABLE Meals ADD CONSTRAINT CK_Meals_QuantityPrepared
            CHECK (QuantityPrepared >= 0);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_volunteers_role'
           AND conrelid = 'Volunteers'::regclass
    ) THEN
        ALTER TABLE Volunteers ADD CONSTRAINT CK_Volunteers_Role
            CHECK (Role IN (1, 2, 3, 4, 5, 6));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_volunteers_status'
           AND conrelid = 'Volunteers'::regclass
    ) THEN
        ALTER TABLE Volunteers ADD CONSTRAINT CK_Volunteers_Status
            CHECK (Status IN (1, 2, 3));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_volunteers_hoursscheduled'
           AND conrelid = 'Volunteers'::regclass
    ) THEN
        ALTER TABLE Volunteers ADD CONSTRAINT CK_Volunteers_HoursScheduled
            CHECK (HoursScheduled IS NULL OR HoursScheduled >= 0);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_donations_quantity'
           AND conrelid = 'Donations'::regclass
    ) THEN
        ALTER TABLE Donations ADD CONSTRAINT CK_Donations_Quantity
            CHECK (Quantity > 0);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_guests_status'
           AND conrelid = 'Guests'::regclass
    ) THEN
        ALTER TABLE Guests ADD CONSTRAINT CK_Guests_Status
            CHECK (Status IN (1, 2, 3));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_guests_guestcount'
           AND conrelid = 'Guests'::regclass
    ) THEN
        ALTER TABLE Guests ADD CONSTRAINT CK_Guests_GuestCount
            CHECK (GuestCount > 0);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS IX_Meals_EventId_Active
    ON Meals (EventId) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Volunteers_EventId_Active
    ON Volunteers (EventId) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Donations_EventId_Active
    ON Donations (EventId) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Guests_EventId_Active
    ON Guests (EventId) WHERE DeletedAt IS NULL;

-- A soft-deleted volunteer must not block a new sign-up. Recreate the unique
-- index only when it still lacks the DeletedAt predicate.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
          FROM pg_indexes
         WHERE schemaname = 'public'
           AND indexname = 'ux_volunteers_eventid_memberid'
           AND LOWER(indexdef) NOT LIKE '%deletedat is null%'
    ) THEN
        DROP INDEX UX_Volunteers_EventId_MemberId;
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS UX_Volunteers_EventId_MemberId
    ON Volunteers (EventId, MemberId)
    WHERE Status <> 3 AND DeletedAt IS NULL;
