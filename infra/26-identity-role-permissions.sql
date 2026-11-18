-- Retrofit identity role permissions onto an existing database.
-- Safe to run repeatedly. Permission names are the canonical values from
-- TSQR.Common.Authorization.Permissions.
\connect tsqr_identity

CREATE TABLE IF NOT EXISTS roles_permissions (
    RoleId      VARCHAR(128) NOT NULL REFERENCES roles(Id) ON DELETE CASCADE,
    Permission  VARCHAR(100) NOT NULL,
    PRIMARY KEY (RoleId, Permission),
    CONSTRAINT CK_roles_permissions_Permission_NotBlank
        CHECK (length(btrim(Permission)) > 0)
);

CREATE INDEX IF NOT EXISTS IX_roles_permissions_Permission
    ON roles_permissions(Permission);

INSERT INTO roles_permissions (RoleId, Permission)
SELECT r.Id, p.Permission
FROM roles r
INNER JOIN (VALUES
    ('Admin', 'users.manage'),
    ('Admin', 'roles.manage'),
    ('Admin', 'members.register'),
    ('Admin', 'members.manage'),
    ('Admin', 'reservations.self-service'),
    ('Admin', 'reservations.confirm-pickup'),
    ('Admin', 'reservations.complete'),
    ('Admin', 'tools.manage'),
    ('Admin', 'tools.operate'),
    ('Admin', 'loans.manage'),
    ('Admin', 'communities.manage'),
    ('Admin', 'geography.manage'),
    ('Admin', 'support.manage'),
    ('LocationCoordinator', 'members.register'),
    ('LocationCoordinator', 'reservations.self-service'),
    ('LocationCoordinator', 'reservations.confirm-pickup'),
    ('LocationCoordinator', 'reservations.complete'),
    ('LocationCoordinator', 'tools.manage'),
    ('LocationCoordinator', 'tools.operate'),
    ('LocationCoordinator', 'communities.manage'),
    ('LocationCoordinator', 'support.manage'),
    ('Repairman', 'reservations.self-service'),
    ('Repairman', 'reservations.confirm-pickup'),
    ('Repairman', 'tools.operate'),
    ('Regular', 'reservations.self-service')
) AS p(RoleName, Permission) ON p.RoleName = r.Name
ON CONFLICT (RoleId, Permission) DO NOTHING;
