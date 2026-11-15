-- Retrofit soup-kitchen volunteer uniqueness onto an existing database.
-- A cancelled volunteer may sign up again, so the index only covers active rows.
\connect tsqr_soup_kitchen

CREATE UNIQUE INDEX IF NOT EXISTS UX_Volunteers_EventId_MemberId
    ON Volunteers (EventId, MemberId)
    WHERE Status <> 3;
