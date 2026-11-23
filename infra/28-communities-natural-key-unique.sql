-- Enforce natural-key uniqueness for quick-registered geography.
--
-- Quick registration resolves a country/city/neighbourhood by name and
-- creates it when missing. The unique indexes make the insert race-safe when
-- combined with INSERT ... ON CONFLICT DO NOTHING, while the partial predicate
-- allows a soft-deleted row to be replaced by a new active row.
\connect tsqr_communities

DROP INDEX IF EXISTS IX_Cities_CountryId_Name_Active;
DROP INDEX IF EXISTS IX_Cities_CountryId_NameLower_Active;
DROP INDEX IF EXISTS IX_Neighbourhoods_CityId_Name_Active;
DROP INDEX IF EXISTS IX_Neighbourhoods_CityId_NameLower_Active;

CREATE UNIQUE INDEX IF NOT EXISTS UX_Cities_CountryId_NameLower_Active
    ON Cities (CountryId, LOWER(Name)) WHERE DeletedAt IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS UX_Neighbourhoods_CityId_NameLower_Active
    ON Neighbourhoods (CityId, LOWER(Name)) WHERE DeletedAt IS NULL;
