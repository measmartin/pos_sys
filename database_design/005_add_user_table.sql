-- =============================================
-- Migration: Add User Authentication Table
-- =============================================

IF OBJECT_ID('[User]', 'U') IS NOT NULL DROP TABLE [User];

CREATE TABLE [User] (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    email NVARCHAR(100) NULL,
    display_name NVARCHAR(100) NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NULL,
    last_login_at DATETIME2 NULL
);

-- Create index for username lookups
CREATE INDEX IX_User_Username ON [User](username);
CREATE INDEX IX_User_Email ON [User](email) WHERE email IS NOT NULL;

-- Insert default admin user
-- Password: admin123
-- This hash is generated with PBKDF2-SHA256, 100000 iterations, 16-byte salt
-- To regenerate: use the AuthService HashPassword method or a temporary tool
INSERT INTO [User] (username, password_hash, display_name, is_active)
VALUES ('admin', 'tBO/R1AcF9GfTTqXxBjXSyiezfWQGce11KCd2HoUfiQlizG3/R01cqrFihVznKhg', 'Administrator', 1);
