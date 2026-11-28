-- TSQR Learning - Schema
\connect tsqr_learning

CREATE TABLE IF NOT EXISTS Decks (
    Id SERIAL PRIMARY KEY,
    CommunityId INTEGER NOT NULL,
    OwnerSub UUID NOT NULL,
    Name VARCHAR(200) NOT NULL,
    CreatedAt TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    DeletedAt TIMESTAMPTZ NULL,
    DeletedBy VARCHAR(200) NULL,
    CONSTRAINT CK_Decks_CommunityId CHECK (CommunityId > 0)
);

CREATE INDEX IF NOT EXISTS IX_Decks_Owner
    ON Decks (CommunityId, OwnerSub)
    WHERE DeletedAt IS NULL;

CREATE TABLE IF NOT EXISTS Cards (
    Id SERIAL PRIMARY KEY,
    DeckId INTEGER NOT NULL REFERENCES Decks(Id),
    CommunityId INTEGER NOT NULL,
    OwnerSub UUID NOT NULL,
    Cue TEXT NOT NULL,
    ExpectedAnswer TEXT NOT NULL,
    Box INTEGER NOT NULL DEFAULT 1,
    DueAt TIMESTAMPTZ NOT NULL,
    ReviewCount INTEGER NOT NULL DEFAULT 0,
    LapseCount INTEGER NOT NULL DEFAULT 0,
    LastReviewedAt TIMESTAMPTZ NULL,
    CreatedAt TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    DeletedAt TIMESTAMPTZ NULL,
    DeletedBy VARCHAR(200) NULL,
    CONSTRAINT CK_Cards_CommunityId CHECK (CommunityId > 0),
    CONSTRAINT CK_Cards_Box CHECK (Box BETWEEN 1 AND 5),
    CONSTRAINT CK_Cards_Counts CHECK (ReviewCount >= 0 AND LapseCount >= 0 AND LapseCount <= ReviewCount)
);

CREATE INDEX IF NOT EXISTS IX_Cards_DeckId ON Cards (DeckId);

CREATE INDEX IF NOT EXISTS IX_Cards_Due
    ON Cards (CommunityId, OwnerSub, DueAt)
    WHERE DeletedAt IS NULL;

CREATE TABLE IF NOT EXISTS Reviews (
    Id SERIAL PRIMARY KEY,
    CardId INTEGER NOT NULL REFERENCES Cards(Id),
    CommunityId INTEGER NOT NULL,
    OwnerSub UUID NOT NULL,
    GivenAnswer TEXT NOT NULL,
    Confidence INTEGER NOT NULL,
    WasCorrect BOOLEAN NOT NULL,
    BoxBefore INTEGER NOT NULL,
    BoxAfter INTEGER NOT NULL,
    ReviewedAt TIMESTAMPTZ NOT NULL,
    CONSTRAINT CK_Reviews_CommunityId CHECK (CommunityId > 0),
    CONSTRAINT CK_Reviews_Confidence CHECK (Confidence IN (1, 2, 3)),
    CONSTRAINT CK_Reviews_Boxes CHECK (BoxBefore BETWEEN 1 AND 5 AND BoxAfter BETWEEN 1 AND 5)
);

CREATE INDEX IF NOT EXISTS IX_Reviews_CardId ON Reviews (CardId);

CREATE INDEX IF NOT EXISTS IX_Reviews_Owner ON Reviews (CommunityId, OwnerSub);
