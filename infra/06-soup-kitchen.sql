-- TSQR Soup Kitchen - Schema & Seed Data
\connect tsqr_soup_kitchen

CREATE TABLE IF NOT EXISTS Events (
    Id SERIAL PRIMARY KEY,
    Name VARCHAR(200) NOT NULL,
    Description TEXT NOT NULL DEFAULT '',
    EventDate TIMESTAMP,
    Location VARCHAR(500) NOT NULL DEFAULT '',
    Status INTEGER NOT NULL DEFAULT 1,
    MaxGuests INTEGER,
    CreatedAt TIMESTAMP NOT NULL DEFAULT NOW(),
    DeletedAt TIMESTAMP NULL,
    DeletedBy VARCHAR(200) NULL,
    CONSTRAINT CK_Events_Status CHECK (Status IN (1, 2, 3, 4)),
    CONSTRAINT CK_Events_MaxGuests CHECK (MaxGuests IS NULL OR MaxGuests > 0)
);

CREATE TABLE IF NOT EXISTS Meals (
    Id SERIAL PRIMARY KEY,
    EventId INTEGER NOT NULL REFERENCES Events(Id),
    Name VARCHAR(200) NOT NULL,
    Description TEXT NOT NULL DEFAULT '',
    Category INTEGER NOT NULL DEFAULT 1,
    QuantityNeeded INTEGER NOT NULL DEFAULT 0,
    QuantityPrepared INTEGER NOT NULL DEFAULT 0,
    DeletedAt TIMESTAMP NULL,
    DeletedBy VARCHAR(200) NULL,
    CONSTRAINT CK_Meals_Category CHECK (Category IN (1, 2, 3, 4, 5, 6)),
    CONSTRAINT CK_Meals_QuantityNeeded CHECK (QuantityNeeded >= 0),
    CONSTRAINT CK_Meals_QuantityPrepared CHECK (QuantityPrepared >= 0)
);

CREATE TABLE IF NOT EXISTS Volunteers (
    Id SERIAL PRIMARY KEY,
    EventId INTEGER NOT NULL REFERENCES Events(Id),
    MemberId INTEGER NOT NULL,
    Role INTEGER NOT NULL DEFAULT 6,
    Status INTEGER NOT NULL DEFAULT 1,
    HoursScheduled NUMERIC(5,1),
    Notes TEXT,
    DeletedAt TIMESTAMP NULL,
    DeletedBy VARCHAR(200) NULL,
    CONSTRAINT CK_Volunteers_Role CHECK (Role IN (1, 2, 3, 4, 5, 6)),
    CONSTRAINT CK_Volunteers_Status CHECK (Status IN (1, 2, 3)),
    CONSTRAINT CK_Volunteers_HoursScheduled CHECK (HoursScheduled IS NULL OR HoursScheduled >= 0)
);

-- Prevent duplicate active volunteer sign-ups for the same event and member.
CREATE UNIQUE INDEX IF NOT EXISTS UX_Volunteers_EventId_MemberId
    ON Volunteers (EventId, MemberId)
    WHERE Status <> 3 AND DeletedAt IS NULL;

CREATE TABLE IF NOT EXISTS Donations (
    Id SERIAL PRIMARY KEY,
    EventId INTEGER NOT NULL REFERENCES Events(Id),
    DonorName VARCHAR(200) NOT NULL,
    Item VARCHAR(200) NOT NULL,
    Quantity INTEGER NOT NULL DEFAULT 1,
    DonationDate TIMESTAMP NOT NULL DEFAULT NOW(),
    Notes TEXT,
    DeletedAt TIMESTAMP NULL,
    DeletedBy VARCHAR(200) NULL,
    CONSTRAINT CK_Donations_Quantity CHECK (Quantity > 0)
);

CREATE TABLE IF NOT EXISTS Guests (
    Id SERIAL PRIMARY KEY,
    EventId INTEGER NOT NULL REFERENCES Events(Id),
    Name VARCHAR(200) NOT NULL,
    ContactInfo VARCHAR(200),
    GuestCount INTEGER NOT NULL DEFAULT 1,
    Status INTEGER NOT NULL DEFAULT 1,
    RegisteredAt TIMESTAMP NOT NULL DEFAULT NOW(),
    DeletedAt TIMESTAMP NULL,
    DeletedBy VARCHAR(200) NULL,
    CONSTRAINT CK_Guests_Status CHECK (Status IN (1, 2, 3)),
    CONSTRAINT CK_Guests_GuestCount CHECK (GuestCount > 0)
);

CREATE INDEX IF NOT EXISTS IX_Meals_EventId_Active
    ON Meals (EventId) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Volunteers_EventId_Active
    ON Volunteers (EventId) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Donations_EventId_Active
    ON Donations (EventId) WHERE DeletedAt IS NULL;
CREATE INDEX IF NOT EXISTS IX_Guests_EventId_Active
    ON Guests (EventId) WHERE DeletedAt IS NULL;

-- Seed: Events
INSERT INTO Events (Name, Description, EventDate, Location, Status, MaxGuests, CreatedAt) VALUES
    ('Community Thanksgiving Dinner', 'Annual community Thanksgiving meal for those in need.', '2026-11-26 12:00:00', 'Downtown Community Center', 1, 200, NOW()),
    ('Winter Warmth Soup Night', 'Hot soup and bread for the community during winter months.', '2026-01-15 17:00:00', 'North Side Church Hall', 2, 150, NOW()),
    ('Summer Lunch Program', 'Free lunch for children and families during summer break.', '2026-07-01 11:30:00', 'East End Park Pavilion', 1, 300, NOW());

-- Seed: Meals
INSERT INTO Meals (EventId, Name, Description, Category, QuantityNeeded, QuantityPrepared) VALUES
    (1, 'Roast Turkey', 'Oven-roasted turkey with herbs', 2, 20, 15),
    (1, 'Mashed Potatoes', 'Creamy mashed potatoes with gravy', 3, 200, 150),
    (1, 'Pumpkin Pie', 'Classic pumpkin pie with whipped cream', 4, 30, 20),
    (2, 'Tomato Basil Soup', 'Creamy tomato basil soup', 1, 150, 100),
    (2, 'French Bread', 'Fresh baked French bread', 6, 20, 15),
    (3, 'Grilled Cheese', 'Classic grilled cheese sandwiches', 2, 200, 0),
    (3, 'Lemonade', 'Fresh-squeezed lemonade', 5, 300, 0);

-- Seed: Volunteers
INSERT INTO Volunteers (EventId, MemberId, Role, Status, HoursScheduled, Notes) VALUES
    (1, 1, 4, 2, 8.0, 'Event coordinator'),
    (1, 3, 1, 2, 6.0, 'Head cook'),
    (1, 5, 2, 2, 4.0, 'Server'),
    (2, 8, 1, 1, 4.0, 'Soup maker'),
    (2, 10, 3, 1, 3.0, 'Cleanup crew');

-- Seed: Donations
INSERT INTO Donations (EventId, DonorName, Item, Quantity, DonationDate, Notes) VALUES
    (1, 'Local Bakery', 'Bread loaves', 20, NOW(), 'Donated fresh bread for Thanksgiving'),
    (1, 'Community Grocer', 'Turkey', 10, NOW(), 'Frozen turkeys'),
    (2, 'Jane Doe', 'Canned tomatoes', 48, NOW(), 'For the soup');

-- Seed: Guests
INSERT INTO Guests (EventId, Name, ContactInfo, GuestCount, Status, RegisteredAt) VALUES
    (1, 'Smith Family', 'smith@email.com', 4, 2, NOW()),
    (1, 'Robert Johnson', 'rj@email.com', 1, 2, NOW()),
    (2, 'Maria Garcia', NULL, 3, 1, NOW()),
    (2, 'Williams Family', 'williams@email.com', 5, 1, NOW()),
    (3, 'Davis Family', 'davis@email.com', 2, 1, NOW());
