-- Retrofit the policy snapshot columns added to tool-lib's local init.sql.
-- LateFeePerDay is captured at checkout so later policy changes do not
-- retroactively alter in-flight loans. Safe to run repeatedly.
\connect tsqr_tool_library

ALTER TABLE Loans ADD COLUMN IF NOT EXISTS LateFeePerDay NUMERIC(10,2) NOT NULL DEFAULT 1.00;
ALTER TABLE Loans ADD COLUMN IF NOT EXISTS RenewalCount INTEGER NOT NULL DEFAULT 0;
