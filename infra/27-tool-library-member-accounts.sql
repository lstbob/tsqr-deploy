-- Retrofit explicit auth-subject mapping onto an existing tool-library DB.
-- Safe to run repeatedly. JWT `sub` is a UUID; Members.Id is an int.
\connect tsqr_tool_library

CREATE TABLE IF NOT EXISTS MemberAccounts (
    MemberId    INTEGER PRIMARY KEY REFERENCES Members(Id) ON DELETE CASCADE,
    AuthSubject UUID NOT NULL UNIQUE
);
