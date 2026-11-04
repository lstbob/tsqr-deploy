-- Retrofit community scoping onto the support database. Safe to run repeatedly.
-- CommunityId is a soft reference to tsqr_communities (no cross-database FK).
\connect tsqr_support

ALTER TABLE Incidents ADD COLUMN IF NOT EXISTS CommunityId INTEGER NOT NULL DEFAULT 1;
ALTER TABLE Tickets ADD COLUMN IF NOT EXISTS CommunityId INTEGER NOT NULL DEFAULT 1;
