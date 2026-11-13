-- TSQR Identity - Profile & User Management Schema
\connect tsqr_identity

CREATE TABLE IF NOT EXISTS user_profiles (
    Id          UUID PRIMARY KEY,
    FirstName   VARCHAR(200) NULL,
    LastName    VARCHAR(200) NULL,
    AvatarUrl   VARCHAR(500) NULL,
    Bio         TEXT NULL,
    CreatedAt   TIMESTAMP NOT NULL DEFAULT now(),
    UpdatedAt   TIMESTAMP NOT NULL DEFAULT now(),
    LockoutEnd  TIMESTAMP NULL,
    CreatedBy   VARCHAR(200) NULL,
    UpdatedBy   VARCHAR(200) NULL,
    LockedBy    VARCHAR(200) NULL,
    LockReason  VARCHAR(500) NULL,
    DeletedAt   TIMESTAMP NULL,
    DeletedBy   VARCHAR(200) NULL,
    CONSTRAINT CK_user_profiles_FirstName_NotBlank
        CHECK (FirstName IS NULL OR length(btrim(FirstName)) > 0),
    CONSTRAINT CK_user_profiles_LastName_NotBlank
        CHECK (LastName IS NULL OR length(btrim(LastName)) > 0),
    CONSTRAINT CK_user_profiles_AvatarUrl_NotBlank
        CHECK (AvatarUrl IS NULL OR length(btrim(AvatarUrl)) > 0)
);

CREATE TABLE IF NOT EXISTS roles (
    Id              VARCHAR(128) PRIMARY KEY,
    Name            VARCHAR(100) NOT NULL,
    NormalizedName  VARCHAR(100) NOT NULL UNIQUE,
    CONSTRAINT CK_roles_Name_NotBlank
        CHECK (length(btrim(Name)) > 0),
    CONSTRAINT CK_roles_NormalizedName_NotBlank
        CHECK (length(btrim(NormalizedName)) > 0)
);

CREATE TABLE IF NOT EXISTS user_roles (
    UserId      UUID NOT NULL REFERENCES user_profiles(Id),
    RoleId      VARCHAR(128) NOT NULL REFERENCES roles(Id),
    AssignedAt  TIMESTAMP NOT NULL DEFAULT now(),
    AssignedBy  VARCHAR(200) NULL,
    PRIMARY KEY (UserId, RoleId)
);

CREATE TABLE IF NOT EXISTS pending_email_changes (
    Id          VARCHAR(128) PRIMARY KEY,
    UserId      UUID NOT NULL REFERENCES user_profiles(Id),
    NewEmail    VARCHAR(200) NOT NULL,
    TokenHash   VARCHAR(128) NOT NULL UNIQUE,
    ExpiresAt   TIMESTAMP NOT NULL,
    CreatedAt   TIMESTAMP NOT NULL DEFAULT now(),
    IsConfirmed BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT CK_pending_email_changes_NewEmail_NotBlank
        CHECK (length(btrim(NewEmail)) > 0),
    CONSTRAINT CK_pending_email_changes_Expiry_AfterCreatedAt
        CHECK (ExpiresAt > CreatedAt)
);

CREATE INDEX IF NOT EXISTS IX_user_roles_RoleId ON user_roles(RoleId);
CREATE INDEX IF NOT EXISTS IX_pending_email_changes_UserId ON pending_email_changes(UserId);
CREATE INDEX IF NOT EXISTS IX_pending_email_changes_TokenHash ON pending_email_changes(TokenHash);
CREATE INDEX IF NOT EXISTS IX_pending_email_changes_ExpiresAt ON pending_email_changes(ExpiresAt);
CREATE INDEX IF NOT EXISTS IX_user_profiles_Active_CreatedAt
    ON user_profiles(CreatedAt DESC) WHERE DeletedAt IS NULL;

-- Seed default roles
INSERT INTO roles (Id, Name, NormalizedName) VALUES
    ('admin-role', 'Admin', 'ADMIN'),
    ('regular-role', 'Regular', 'REGULAR'),
    ('repairman-role', 'Repairman', 'REPAIRMAN'),
    ('coordinator-role', 'LocationCoordinator', 'LOCATIONCOORDINATOR')
ON CONFLICT (NormalizedName) DO NOTHING;

-- Seed admin user profile matching autheo's seeded admin
INSERT INTO user_profiles (Id, FirstName, LastName, CreatedAt, UpdatedAt) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Platform', 'Administrator', now(), now())
ON CONFLICT (Id) DO NOTHING;

INSERT INTO user_roles (UserId, RoleId) VALUES
    ('11111111-1111-1111-1111-111111111111', 'admin-role')
ON CONFLICT DO NOTHING;
