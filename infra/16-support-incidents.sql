-- Add the Incident aggregate fields to an existing support database.
-- Safe to run repeatedly.
\connect tsqr_support

ALTER TABLE Incidents ADD COLUMN IF NOT EXISTS Description TEXT NOT NULL DEFAULT '';
ALTER TABLE Incidents ADD COLUMN IF NOT EXISTS AssignedTeam VARCHAR(200) NOT NULL DEFAULT 'Unassigned';
ALTER TABLE Incidents ADD COLUMN IF NOT EXISTS Findings TEXT NULL;
ALTER TABLE Incidents ADD COLUMN IF NOT EXISTS ResolvedAt TIMESTAMP NULL;

UPDATE Incidents
SET Description = 'Legacy incident for ' || ServiceName
WHERE Description = '';

UPDATE Incidents
SET AssignedTeam = 'Unassigned'
WHERE AssignedTeam = '';

UPDATE Incidents
SET ResolvedAt = OccurredOn + (DurationMinutes * INTERVAL '1 minute')
WHERE Status = 3 AND ResolvedAt IS NULL;
