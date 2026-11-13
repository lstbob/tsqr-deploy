-- Retrofit identity schema hardening onto an existing database.
-- Safe to run repeatedly. Fresh databases already get this shape from
-- 05-identity.sql; this file brings older volumes forward.
\connect tsqr_identity

-- user_profiles.Id is the auth subject (a GUID). Align the profile tables with
-- autheo's UUID Users.Id so the same value has the same database type.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'user_profiles'
          AND column_name = 'id'
          AND data_type = 'character varying'
    ) THEN
        ALTER TABLE user_roles
            DROP CONSTRAINT IF EXISTS user_roles_userid_fkey;
        ALTER TABLE pending_email_changes
            DROP CONSTRAINT IF EXISTS pending_email_changes_userid_fkey;

        ALTER TABLE user_roles
            ALTER COLUMN userid TYPE UUID USING userid::uuid;
        ALTER TABLE pending_email_changes
            ALTER COLUMN userid TYPE UUID USING userid::uuid;
        ALTER TABLE user_profiles
            ALTER COLUMN id TYPE UUID USING id::uuid;

        ALTER TABLE user_roles
            ADD CONSTRAINT user_roles_userid_fkey
            FOREIGN KEY (userid) REFERENCES user_profiles(id);
        ALTER TABLE pending_email_changes
            ADD CONSTRAINT pending_email_changes_userid_fkey
            FOREIGN KEY (userid) REFERENCES user_profiles(id);
    END IF;
END $$;

ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS DeletedAt TIMESTAMP NULL;
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS DeletedBy VARCHAR(200) NULL;

ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS CK_user_profiles_FirstName_NotBlank;
ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS CK_user_profiles_LastName_NotBlank;
ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS CK_user_profiles_AvatarUrl_NotBlank;
ALTER TABLE user_profiles
    ADD CONSTRAINT CK_user_profiles_FirstName_NotBlank
    CHECK (FirstName IS NULL OR length(btrim(FirstName)) > 0);
ALTER TABLE user_profiles
    ADD CONSTRAINT CK_user_profiles_LastName_NotBlank
    CHECK (LastName IS NULL OR length(btrim(LastName)) > 0);
ALTER TABLE user_profiles
    ADD CONSTRAINT CK_user_profiles_AvatarUrl_NotBlank
    CHECK (AvatarUrl IS NULL OR length(btrim(AvatarUrl)) > 0);

ALTER TABLE roles DROP CONSTRAINT IF EXISTS CK_roles_Name_NotBlank;
ALTER TABLE roles DROP CONSTRAINT IF EXISTS CK_roles_NormalizedName_NotBlank;
ALTER TABLE roles
    ADD CONSTRAINT CK_roles_Name_NotBlank
    CHECK (length(btrim(Name)) > 0);
ALTER TABLE roles
    ADD CONSTRAINT CK_roles_NormalizedName_NotBlank
    CHECK (length(btrim(NormalizedName)) > 0);

ALTER TABLE pending_email_changes DROP CONSTRAINT IF EXISTS CK_pending_email_changes_NewEmail_NotBlank;
ALTER TABLE pending_email_changes DROP CONSTRAINT IF EXISTS CK_pending_email_changes_Expiry_AfterCreatedAt;
ALTER TABLE pending_email_changes
    ADD CONSTRAINT CK_pending_email_changes_NewEmail_NotBlank
    CHECK (length(btrim(NewEmail)) > 0);
ALTER TABLE pending_email_changes
    ADD CONSTRAINT CK_pending_email_changes_Expiry_AfterCreatedAt
    CHECK (ExpiresAt > CreatedAt);

CREATE INDEX IF NOT EXISTS IX_pending_email_changes_ExpiresAt
    ON pending_email_changes(ExpiresAt);
CREATE INDEX IF NOT EXISTS IX_user_profiles_Active_CreatedAt
    ON user_profiles(CreatedAt DESC) WHERE DeletedAt IS NULL;
