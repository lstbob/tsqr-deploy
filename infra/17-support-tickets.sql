-- Add priority and the Closed status to existing support tickets.
-- Safe to run repeatedly.
\connect tsqr_support

ALTER TABLE Tickets ADD COLUMN IF NOT EXISTS Priority INTEGER NOT NULL DEFAULT 2;

-- Existing tickets predate priorities; Normal (2) is the safe default.
UPDATE Tickets
SET Priority = 2
WHERE Priority IS NULL OR Priority < 1 OR Priority > 4;
