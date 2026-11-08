-- TSQR Communities - Schema & Seed Data
\connect tsqr_communities

CREATE TABLE IF NOT EXISTS Countries (
    Id SERIAL PRIMARY KEY,
    Name VARCHAR(200) NOT NULL,
    Code VARCHAR(3) NOT NULL,
    DeletedAt TIMESTAMP,
    DeletedBy VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS Cities (
    Id SERIAL PRIMARY KEY,
    Name VARCHAR(200) NOT NULL,
    CountryId INTEGER NOT NULL REFERENCES Countries(Id),
    DeletedAt TIMESTAMP,
    DeletedBy VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS Neighbourhoods (
    Id SERIAL PRIMARY KEY,
    Name VARCHAR(200) NOT NULL,
    CityId INTEGER NOT NULL REFERENCES Cities(Id),
    DeletedAt TIMESTAMP,
    DeletedBy VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS Communities (
    Id SERIAL PRIMARY KEY,
    NeighbourhoodId INTEGER NOT NULL REFERENCES Neighbourhoods(Id),
    Name VARCHAR(200) NOT NULL,
    Slug VARCHAR(200) NOT NULL,
    Description TEXT NOT NULL DEFAULT '',
    ContactEmail VARCHAR(200),
    ContactPhone VARCHAR(50),
    Status INTEGER NOT NULL DEFAULT 1 CONSTRAINT CK_Communities_Status CHECK (Status IN (1, 2, 3, 4)),
    CreatedAt TIMESTAMP NOT NULL DEFAULT NOW(),
    DeletedAt TIMESTAMP,
    DeletedBy VARCHAR(200)
);

CREATE INDEX IF NOT EXISTS IX_Countries_Name_Active
    ON Countries (Name) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Countries_NameLower_Active
    ON Countries (LOWER(Name)) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Cities_CountryId_Name_Active
    ON Cities (CountryId, Name) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Cities_CountryId_NameLower_Active
    ON Cities (CountryId, LOWER(Name)) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Neighbourhoods_CityId_Name_Active
    ON Neighbourhoods (CityId, Name) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Neighbourhoods_CityId_NameLower_Active
    ON Neighbourhoods (CityId, LOWER(Name)) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Communities_NeighbourhoodId_Active
    ON Communities (NeighbourhoodId) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Communities_Status_CreatedAt_Active
    ON Communities (Status, CreatedAt DESC) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Communities_CreatedAt_Active
    ON Communities (CreatedAt DESC) WHERE DeletedAt IS NULL;

-- Seed: Bulgaria + cities + neighbourhoods
INSERT INTO Countries (Name, Code) VALUES ('Bulgaria', 'BG');

INSERT INTO Cities (Name, CountryId) VALUES
    ('Sofia', 1), ('Plovdiv', 1), ('Varna', 1), ('Burgas', 1), ('Ruse', 1), ('Stara Zagora', 1);

INSERT INTO Neighbourhoods (Name, CityId) VALUES
    ('Lozenets', 1), ('Mladost', 1), ('Studentski', 1),
    ('Trakia', 2), ('Smirnenski', 2), ('Karshiaka', 2),
    ('Chaika', 3), ('Asparuhovo', 3), ('Vladislavovo', 3),
    ('Meden Rudnik', 4), ('Slaveykov', 4), ('Izgrev', 4),
    ('Druzhba', 5), ('Zora', 5), ('Vazrazhdane', 5),
    ('Samara', 6), ('Bedechka', 6), ('Kazanski', 6);

-- Seed: one active community (Sofia, Lozenets)
INSERT INTO Communities (NeighbourhoodId, Name, Slug, Description, ContactEmail, ContactPhone, Status, CreatedAt) VALUES
    (1, 'Sofia Community Center', 'sofia-community-center', 'Main community center for Sofia Lozenets area.', 'contact@sofiacc.bg', '+359 2 123 4567', 2, NOW());
