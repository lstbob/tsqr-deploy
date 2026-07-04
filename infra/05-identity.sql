-- TSQR Identity - Profile Schema
\connect tsqr_identity

ALTER TABLE Users ADD COLUMN IF NOT EXISTS AvatarUrl VARCHAR(500) NULL;
ALTER TABLE Users ADD COLUMN IF NOT EXISTS Bio TEXT NULL;

CREATE TABLE IF NOT EXISTS PendingEmailChanges (
    Id          UUID PRIMARY KEY,
    UserId      UUID NOT NULL REFERENCES Users(Id),
    NewEmail    VARCHAR(200) NOT NULL,
    TokenHash   VARCHAR(128) NOT NULL UNIQUE,
    ExpiresAt   TIMESTAMP NOT NULL,
    CreatedAt   TIMESTAMP NOT NULL DEFAULT now(),
    IsConfirmed BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS IX_PendingEmailChanges_UserId ON PendingEmailChanges(UserId);
CREATE INDEX IF NOT EXISTS IX_PendingEmailChanges_TokenHash ON PendingEmailChanges(TokenHash);
