-- Retrofit the Policies table added to tool-lib's local init.sql, including
-- the default global policy per tool type. Safe to run repeatedly.
\connect tsqr_tool_library

CREATE TABLE IF NOT EXISTS Policies (
    Id SERIAL PRIMARY KEY,
    ToolType INTEGER NOT NULL,
    -- NULL = global policy for the tool type; non-NULL = location-specific override.
    LocationId INTEGER REFERENCES Locations(Id),
    Name VARCHAR(200) NOT NULL,
    Description VARCHAR(1000) NOT NULL,
    LateFeePerDay NUMERIC(10,2) NOT NULL,
    MaxLoanDurationDays INTEGER NOT NULL,
    MaxRenewalCount INTEGER NOT NULL,
    MaxLoanReservationDays INTEGER NOT NULL
);

INSERT INTO Policies (ToolType, LocationId, Name, Description, LateFeePerDay, MaxLoanDurationDays, MaxRenewalCount, MaxLoanReservationDays)
SELECT 1, NULL::INTEGER, 'Hand tool policy', 'Default lending policy for hand tools', 0.50, 7, 2, 14
WHERE NOT EXISTS (SELECT 1 FROM Policies WHERE ToolType = 1 AND LocationId IS NULL);

INSERT INTO Policies (ToolType, LocationId, Name, Description, LateFeePerDay, MaxLoanDurationDays, MaxRenewalCount, MaxLoanReservationDays)
SELECT 2, NULL::INTEGER, 'Power tool policy', 'Default lending policy for power tools', 1.50, 5, 1, 10
WHERE NOT EXISTS (SELECT 1 FROM Policies WHERE ToolType = 2 AND LocationId IS NULL);

INSERT INTO Policies (ToolType, LocationId, Name, Description, LateFeePerDay, MaxLoanDurationDays, MaxRenewalCount, MaxLoanReservationDays)
SELECT 3, NULL::INTEGER, 'Gardening tool policy', 'Default lending policy for gardening tools', 0.75, 7, 2, 14
WHERE NOT EXISTS (SELECT 1 FROM Policies WHERE ToolType = 3 AND LocationId IS NULL);

INSERT INTO Policies (ToolType, LocationId, Name, Description, LateFeePerDay, MaxLoanDurationDays, MaxRenewalCount, MaxLoanReservationDays)
SELECT 4, NULL::INTEGER, 'Construction tool policy', 'Default lending policy for construction tools', 0.75, 7, 2, 14
WHERE NOT EXISTS (SELECT 1 FROM Policies WHERE ToolType = 4 AND LocationId IS NULL);

INSERT INTO Policies (ToolType, LocationId, Name, Description, LateFeePerDay, MaxLoanDurationDays, MaxRenewalCount, MaxLoanReservationDays)
SELECT 5, NULL::INTEGER, 'Specialty tool policy', 'Default lending policy for specialty tools', 3.00, 3, 0, 7
WHERE NOT EXISTS (SELECT 1 FROM Policies WHERE ToolType = 5 AND LocationId IS NULL);

INSERT INTO Policies (ToolType, LocationId, Name, Description, LateFeePerDay, MaxLoanDurationDays, MaxRenewalCount, MaxLoanReservationDays)
SELECT 6, NULL::INTEGER, 'Other tool policy', 'Default lending policy for other tools', 0.50, 7, 2, 14
WHERE NOT EXISTS (SELECT 1 FROM Policies WHERE ToolType = 6 AND LocationId IS NULL);
