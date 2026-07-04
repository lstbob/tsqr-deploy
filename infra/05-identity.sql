-- TSQR Identity - Schema for custom profile/identity stores
\connect tsqr_identity

CREATE TABLE IF NOT EXISTS AspNetRoles (
    Id              VARCHAR(128) PRIMARY KEY,
    Name            VARCHAR(256) NULL,
    NormalizedName  VARCHAR(256) NULL UNIQUE,
    ConcurrencyStamp VARCHAR(256) NULL
);

CREATE TABLE IF NOT EXISTS AspNetUsers (
    Id                  VARCHAR(128) PRIMARY KEY,
    UserName            VARCHAR(256) NULL,
    NormalizedUserName  VARCHAR(256) NULL UNIQUE,
    Email               VARCHAR(256) NULL,
    NormalizedEmail     VARCHAR(256) NULL,
    EmailConfirmed      BOOLEAN NOT NULL DEFAULT FALSE,
    PasswordHash        TEXT NULL,
    SecurityStamp       VARCHAR(256) NULL,
    ConcurrencyStamp    VARCHAR(256) NULL,
    PhoneNumber         VARCHAR(50) NULL,
    PhoneNumberConfirmed BOOLEAN NOT NULL DEFAULT FALSE,
    TwoFactorEnabled    BOOLEAN NOT NULL DEFAULT FALSE,
    LockoutEnd          TIMESTAMP NULL,
    LockoutEnabled      BOOLEAN NOT NULL DEFAULT FALSE,
    AccessFailedCount   INTEGER NOT NULL DEFAULT 0,
    FirstName           VARCHAR(200) NULL,
    LastName            VARCHAR(200) NULL,
    AvatarUrl           VARCHAR(500) NULL,
    Bio                 TEXT NULL,
    CreatedAt           TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS AspNetUserRoles (
    UserId  VARCHAR(128) NOT NULL REFERENCES AspNetUsers(Id),
    RoleId  VARCHAR(128) NOT NULL REFERENCES AspNetRoles(Id),
    PRIMARY KEY (UserId, RoleId)
);

CREATE TABLE IF NOT EXISTS AspNetUserClaims (
    Id          SERIAL PRIMARY KEY,
    UserId      VARCHAR(128) NOT NULL REFERENCES AspNetUsers(Id),
    ClaimType   VARCHAR(256) NULL,
    ClaimValue  VARCHAR(256) NULL
);

CREATE INDEX IF NOT EXISTS IX_AspNetUsers_NormalizedUserName ON AspNetUsers(NormalizedUserName);
CREATE INDEX IF NOT EXISTS IX_AspNetUsers_NormalizedEmail ON AspNetUsers(NormalizedEmail);
CREATE INDEX IF NOT EXISTS IX_AspNetUserRoles_RoleId ON AspNetUserRoles(RoleId);
CREATE INDEX IF NOT EXISTS IX_AspNetUserClaims_UserId ON AspNetUserClaims(UserId);

CREATE TABLE IF NOT EXISTS PendingEmailChanges (
    Id          VARCHAR(128) PRIMARY KEY,
    UserId      VARCHAR(128) NOT NULL REFERENCES AspNetUsers(Id),
    NewEmail    VARCHAR(200) NOT NULL,
    TokenHash   VARCHAR(128) NOT NULL UNIQUE,
    ExpiresAt   TIMESTAMP NOT NULL,
    CreatedAt   TIMESTAMP NOT NULL DEFAULT now(),
    IsConfirmed BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS IX_PendingEmailChanges_UserId ON PendingEmailChanges(UserId);
CREATE INDEX IF NOT EXISTS IX_PendingEmailChanges_TokenHash ON PendingEmailChanges(TokenHash);

-- Seed default roles
INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp) VALUES
    ('admin-role', 'Admin', 'ADMIN', gen_random_uuid()::text),
    ('regular-role', 'Regular', 'REGULAR', gen_random_uuid()::text),
    ('repairman-role', 'Repairman', 'REPAIRMAN', gen_random_uuid()::text),
    ('coordinator-role', 'LocationCoordinator', 'LOCATIONCOORDINATOR', gen_random_uuid()::text)
ON CONFLICT (NormalizedName) DO NOTHING;

-- Seed admin user matching autheo's seeded admin
INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed,
    FirstName, LastName, CreatedAt)
VALUES (
    '11111111-1111-1111-1111-111111111111',
    'admin@townssquare.local',
    'ADMIN@TOWNSSQUARE.LOCAL',
    'admin@townssquare.local',
    'ADMIN@TOWNSSQUARE.LOCAL',
    TRUE,
    'Platform',
    'Administrator',
    now()
) ON CONFLICT (Id) DO NOTHING;

INSERT INTO AspNetUserRoles (UserId, RoleId) VALUES
    ('11111111-1111-1111-1111-111111111111', 'admin-role')
ON CONFLICT DO NOTHING;
