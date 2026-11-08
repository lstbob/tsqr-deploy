-- Retrofit communities schema hardening onto an existing database.
-- Safe to run repeatedly. Adds soft-delete columns, the status CHECK
-- constraint, and indexes for the list/geography query paths.
\connect tsqr_communities

ALTER TABLE Countries ADD COLUMN IF NOT EXISTS DeletedAt TIMESTAMP;
ALTER TABLE Countries ADD COLUMN IF NOT EXISTS DeletedBy VARCHAR(200);
ALTER TABLE Cities ADD COLUMN IF NOT EXISTS DeletedAt TIMESTAMP;
ALTER TABLE Cities ADD COLUMN IF NOT EXISTS DeletedBy VARCHAR(200);
ALTER TABLE Neighbourhoods ADD COLUMN IF NOT EXISTS DeletedAt TIMESTAMP;
ALTER TABLE Neighbourhoods ADD COLUMN IF NOT EXISTS DeletedBy VARCHAR(200);
ALTER TABLE Communities ADD COLUMN IF NOT EXISTS DeletedAt TIMESTAMP;
ALTER TABLE Communities ADD COLUMN IF NOT EXISTS DeletedBy VARCHAR(200);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'CK_Communities_Status'
          AND conrelid = 'Communities'::regclass
    ) THEN
        ALTER TABLE Communities
            ADD CONSTRAINT CK_Communities_Status CHECK (Status IN (1, 2, 3, 4));
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS IX_Countries_Name_Active
    ON Countries (Name) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Countries_NameLower_Active
    ON Countries (LOWER(Name)) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Cities_CountryId_Name_Active
    ON Cities (CountryId, Name) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Cities_CountryId_NameLower_Active
    ON Cities (CountryId, LOWER(Name)) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Neighbourhoods_CityId_Name_Active
    ON Neighbourhoods (CityId, Name) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Neighbourhoods_CityId_NameLower_Active
    ON Neighbourhoods (CityId, LOWER(Name)) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Communities_NeighbourhoodId_Active
    ON Communities (NeighbourhoodId) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Communities_Status_CreatedAt_Active
    ON Communities (Status, CreatedAt DESC) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Communities_CreatedAt_Active
    ON Communities (CreatedAt DESC) WHERE DeletedAt IS NULL;
