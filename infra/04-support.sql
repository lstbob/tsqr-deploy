-- TSQR Support - Schema & Seed Data
\connect tsqr_support

-- Apps catalog
CREATE TABLE IF NOT EXISTS Apps (
    Id          SERIAL PRIMARY KEY,
    Name        VARCHAR(200) NOT NULL,
    Description VARCHAR(1000) NOT NULL,
    Status      INTEGER NOT NULL DEFAULT 1  -- 1=Active, 2=ComingSoon, 3=Retired
);

-- Service uptime statuses
CREATE TABLE IF NOT EXISTS ServiceStatuses (
    Id                SERIAL PRIMARY KEY,
    Name              VARCHAR(200) NOT NULL,
    State             INTEGER NOT NULL,       -- 1=Up, 2=Degraded, 3=Down
    UptimePercent30d  NUMERIC(5,2) NOT NULL DEFAULT 100.00,
    Summary           TEXT NULL
);

-- Incident history
CREATE TABLE IF NOT EXISTS Incidents (
    Id              SERIAL PRIMARY KEY,
    OccurredOn      DATE NOT NULL,
    ServiceName     VARCHAR(200) NOT NULL,
    DurationMinutes INTEGER NOT NULL,
    Status          INTEGER NOT NULL DEFAULT 3, -- 1=Investigating, 2=Ongoing, 3=Resolved
    Description     TEXT NOT NULL DEFAULT '',
    AssignedTeam    VARCHAR(200) NOT NULL DEFAULT 'Unassigned',
    Findings        TEXT NULL,
    ResolvedAt      TIMESTAMP NULL,
    CommunityId     INTEGER NOT NULL DEFAULT 1  -- soft reference to tsqr_communities
);

-- Support tickets
CREATE TABLE IF NOT EXISTS Tickets (
    Id                SERIAL PRIMARY KEY,
    Subject           VARCHAR(500) NOT NULL,
    Category          INTEGER NOT NULL,           -- 1=BugReport, 2=FeatureRequest, 3=AccessIssue, 4=GeneralInquiry
    Priority          INTEGER NOT NULL DEFAULT 2, -- 1=Low, 2=Normal, 3=High, 4=Urgent
    Status            INTEGER NOT NULL DEFAULT 1, -- 1=Open, 2=InProgress, 3=Resolved, 4=Closed
    SubmitterEmail    VARCHAR(200) NULL,
    -- Auth user id (JWT sub). Cross-service identity is
    -- MemberId == User.Id == Sub; the `mbr` claim is retired.
    SubmitterMemberId UUID NULL,
    AssignedTo        VARCHAR(200) NULL,
    ReportedAt        TIMESTAMP NOT NULL DEFAULT now(),
    ResolvedAt        TIMESTAMP NULL,
    Description       TEXT NOT NULL,
    Summary           TEXT NULL,
    CommunityId       INTEGER NOT NULL DEFAULT 1 -- soft reference to tsqr_communities
);

-- Contact messages (linked to auto-created General Inquiry ticket)
CREATE TABLE IF NOT EXISTS ContactMessages (
    Id        SERIAL PRIMARY KEY,
    Name      VARCHAR(300) NOT NULL,
    Email     VARCHAR(200) NOT NULL,
    Message   TEXT NOT NULL,
    ReceivedAt TIMESTAMP NOT NULL DEFAULT now(),
    TicketId  INTEGER NULL REFERENCES Tickets(Id)
);

-- Team members for About Us
CREATE TABLE IF NOT EXISTS TeamMembers (
    Id       SERIAL PRIMARY KEY,
    Initials VARCHAR(10) NOT NULL,
    Name     VARCHAR(200) NOT NULL,
    RoleName VARCHAR(200) NOT NULL
);

-- CMS-style editable content for About Us
CREATE TABLE IF NOT EXISTS AboutContent (
    Key   VARCHAR(100) PRIMARY KEY,
    Value TEXT NOT NULL
);

-- ================================================================
-- Seed data
-- ================================================================

INSERT INTO Apps (Name, Description, Status) VALUES
    ('Tool Library', 'Browse, search, and manage the tool catalog across all locations.', 1),
    ('Member Management', 'Handle registrations, memberships, and verification workflows.', 1),
    ('Reservations', 'Manage tool reservations, waitlists, and pickup confirmations.', 1),
    ('Inventory', 'Track item conditions, loan history, and current holders.', 1),
    ('Maintenance', 'Report issues, track repair progress, and update conditions.', 1),
    ('Loans', 'Monitor active loans, due dates, fines, and returns.', 1),
    ('Support Portal', 'This support portal — submit tickets and monitor platform health.', 1),
    ('Admin Dashboard', 'Platform-wide analytics, user management, and configuration.', 2)
ON CONFLICT DO NOTHING;

INSERT INTO ServiceStatuses (Name, State, UptimePercent30d, Summary) VALUES
    ('Tool Library API', 1, 99.90, NULL),
    ('Member Service', 1, 99.80, NULL),
    ('Reservation Service', 1, 99.70, NULL),
    ('Inventory Service', 1, 99.90, NULL),
    ('Notification Service', 2, 95.20, NULL),
    ('Postgres Database', 1, 99.99, NULL)
ON CONFLICT DO NOTHING;

INSERT INTO Incidents (OccurredOn, ServiceName, DurationMinutes, Status, Description, AssignedTeam, ResolvedAt) VALUES
    ('2026-06-05', 'Notification Service', 134, 3, 'Legacy incident for Notification Service', 'Unassigned', '2026-06-05 02:14:00'),
    ('2026-06-01', 'Reservation Service', 45, 3, 'Legacy incident for Reservation Service', 'Unassigned', '2026-06-01 00:45:00'),
    ('2026-05-28', 'Member Service', 62, 3, 'Legacy incident for Member Service', 'Unassigned', '2026-05-28 01:02:00')
ON CONFLICT DO NOTHING;

INSERT INTO TeamMembers (Initials, Name, RoleName) VALUES
    ('LB', 'Lyuben Bobchev', 'Lead Developer'),
    ('TS', 'Support Team', 'Customer Success'),
    ('OP', 'Operations', 'Infrastructure & DevOps')
ON CONFLICT DO NOTHING;

INSERT INTO AboutContent (Key, Value) VALUES
    ('mission', 'TSQR (Tool Sharing & Quick Reservation) provides a centralized platform for communities and organizations to share tools efficiently. We believe that access to the right tool should never be a barrier to getting the job done.'),
    ('platform', 'Built with .NET 10, Dapper, and Postgres on the backend, with a modern Angular and Next.js frontend. The platform follows Domain-Driven Design principles with a focus on maintainability and performance.')
ON CONFLICT DO NOTHING;

INSERT INTO Tickets (Subject, Category, Priority, Status, SubmitterEmail, AssignedTo, ReportedAt, ResolvedAt, Description, Summary) VALUES
    ('Login failure on Member portal', 3, 4, 1, 'user@example.com', 'Infrastructure Team', '2026-06-07 09:00:00', NULL,
     'Cannot log in with valid credentials since this morning.', 'Reported Jun 7 — Assigned to infrastructure team'),
    ('Add export to CSV feature', 2, 2, 2, 'manager@example.com', 'Product Team', '2026-06-04 14:00:00', NULL,
     'It would be very useful to be able to export the tool catalog to CSV.', 'Reported Jun 4 — Estimated completion Jun 14'),
    ('Reservation expiry not sending emails', 1, 3, 3, 'admin@example.com', 'Backend Team', '2026-06-02 10:00:00', '2026-06-03 15:00:00',
     'Reservations that expire do not trigger the reminder email to the member.', 'Reported Jun 2 — Resolved Jun 3'),
    ('Tool image upload fails for large files', 1, 1, 3, 'coordinator@example.com', 'Frontend Team', '2026-05-28 11:00:00', '2026-05-30 09:00:00',
     'Uploading images larger than 5MB returns a 500 error.', 'Reported May 28 — Resolved May 30')
ON CONFLICT DO NOTHING;