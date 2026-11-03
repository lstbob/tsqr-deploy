-- TSQR Autheo - Schema & Seed Data
\connect tsqr_autheo

CREATE TABLE IF NOT EXISTS Users (
    Id              UUID PRIMARY KEY,
    Email           VARCHAR(200) NOT NULL UNIQUE,
    PasswordHash    TEXT NOT NULL,
    FullName        VARCHAR(300) NOT NULL,
    RoleName        VARCHAR(50)  NOT NULL,
    MemberId        UUID NULL,
    IsActive        BOOLEAN NOT NULL DEFAULT TRUE,
    IsEmailConfirmed BOOLEAN NOT NULL DEFAULT TRUE,
    CreatedAt       TIMESTAMP NOT NULL DEFAULT now(),
    UpdatedAt       TIMESTAMP NOT NULL DEFAULT now(),
    LastLoginAt     TIMESTAMP NULL
);

CREATE TABLE IF NOT EXISTS RefreshTokens (
    Id                  UUID PRIMARY KEY,
    UserId              UUID NOT NULL REFERENCES Users(Id),
    TokenHash           VARCHAR(128) NOT NULL UNIQUE,
    ExpiresAt           TIMESTAMP NOT NULL,
    CreatedAt           TIMESTAMP NOT NULL DEFAULT now(),
    CreatedByIp         VARCHAR(50),
    RevokedAt           TIMESTAMP NULL,
    RevokedByIp         VARCHAR(50) NULL,
    ReplacedByTokenHash VARCHAR(128) NULL,
    RevokedReasonIsReuse BOOLEAN NULL
);

CREATE INDEX IF NOT EXISTS IX_RefreshTokens_UserId ON RefreshTokens(UserId);
CREATE INDEX IF NOT EXISTS IX_RefreshTokens_TokenHash ON RefreshTokens(TokenHash);

-- Keep existing databases in sync when this script is re-run manually.
ALTER TABLE RefreshTokens ADD COLUMN IF NOT EXISTS RevokedReasonIsReuse BOOLEAN NULL;

CREATE TABLE IF NOT EXISTS PasswordResetTokens (
    Id              UUID PRIMARY KEY,
    UserId          UUID NOT NULL REFERENCES Users(Id),
    TokenHash       VARCHAR(128) NOT NULL UNIQUE,
    ExpiresAt       TIMESTAMP NOT NULL,
    CreatedAt       TIMESTAMP NOT NULL DEFAULT now(),
    IsUsed          BOOLEAN NOT NULL DEFAULT FALSE,
    UsedAt          TIMESTAMP NULL
);

CREATE INDEX IF NOT EXISTS IX_PasswordResetTokens_TokenHash ON PasswordResetTokens(TokenHash);
CREATE INDEX IF NOT EXISTS IX_PasswordResetTokens_UserId ON PasswordResetTokens(UserId);

-- Seed: admin user. Password = "ChangeMe!123" (Pbkdf2, 100k iter, HMACSHA256).
-- Format: "{iterations}.{salt-base64}.{hash-base64}". Regenerate via autheo's
-- IPasswordHasher.Hash if you want to rotate. The default is intentionally
-- documented here so first-boot login is possible.
INSERT INTO Users (Id, Email, PasswordHash, FullName, RoleName, MemberId, IsActive, IsEmailConfirmed, CreatedAt, UpdatedAt, LastLoginAt) VALUES
    ('11111111-1111-1111-1111-111111111111',
     'admin@townssquare.local',
     '100000.hCQNMKy8aIzNgAxbSJf7qg==.TEvPJnH5wCOZD4ICfOPPCLfbmTl+ND4vGYNGMLf1OsU=',
     'Platform Administrator',
     'Admin',
     NULL,
     TRUE, TRUE, now(), now(), NULL)
ON CONFLICT (Email) DO NOTHING;