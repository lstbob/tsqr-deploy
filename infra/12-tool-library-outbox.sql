-- Retrofit the transactional outbox table added to tool-lib's schema.
-- Safe to run repeatedly.
\connect tsqr_tool_library

CREATE TABLE IF NOT EXISTS OutboxMessages (
    EventId UUID PRIMARY KEY,
    EventType VARCHAR(500) NOT NULL,
    Payload TEXT NOT NULL,
    OccurredOn TIMESTAMPTZ NOT NULL,
    ProcessedOn TIMESTAMPTZ,
    Attempts INTEGER NOT NULL DEFAULT 0,
    LastError TEXT,
    NextAttemptOn TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS IX_OutboxMessages_Pending
    ON OutboxMessages (NextAttemptOn)
    WHERE ProcessedOn IS NULL;
