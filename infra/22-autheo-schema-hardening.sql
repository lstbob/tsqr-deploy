-- TSQR Autheo - Schema hardening (idempotent retrofit)
\connect tsqr_autheo

-- RoleName is persisted as the enum name. Reject unknown values so typos and
-- manual writes cannot create users that the application cannot rehydrate.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM pg_constraint
         WHERE conname = 'CK_Users_RoleName'
           AND conrelid = 'Users'::regclass
    ) THEN
        ALTER TABLE Users
            ADD CONSTRAINT CK_Users_RoleName
            CHECK (RoleName IN ('Regular', 'Repairman', 'LocationCoordinator', 'Admin'));
    END IF;
END $$;
