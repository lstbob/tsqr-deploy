-- Retire the unused mbr claim backing column.
--
-- Cross-service identity is the JWT sub claim (MemberId == User.Id == Sub).
-- The int member IDs in tool-lib/soup-kitchen are domain-local identifiers and
-- are not auth identities. This column was never written by the running
-- service and is safe to drop.
\connect tsqr_autheo

ALTER TABLE Users DROP COLUMN IF EXISTS MemberId;
