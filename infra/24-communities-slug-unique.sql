-- Retrofit communities slug uniqueness onto an existing database.
-- Slugs are used in URLs, so active rows must be unique. Soft-deleted rows are
-- excluded so a slug can be reused after a community is deleted.
\connect tsqr_communities

CREATE UNIQUE INDEX IF NOT EXISTS UX_Communities_Slug_Active
    ON Communities (Slug) WHERE DeletedAt IS NULL;
