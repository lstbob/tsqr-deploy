-- Retrofit identity audit fields onto an existing database.
-- Safe to run repeatedly.
\connect tsqr_identity

ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS CreatedBy VARCHAR(200);
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS UpdatedBy VARCHAR(200);
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS LockedBy VARCHAR(200);
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS LockReason VARCHAR(500);

ALTER TABLE user_roles ADD COLUMN IF NOT EXISTS AssignedAt TIMESTAMP NOT NULL DEFAULT now();
ALTER TABLE user_roles ADD COLUMN IF NOT EXISTS AssignedBy VARCHAR(200);
