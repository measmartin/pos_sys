-- =============================================
-- Migration: Add Refresh Tokens Table
-- =============================================

IF OBJECT_ID('RefreshToken', 'U') IS NOT NULL DROP TABLE RefreshToken;

CREATE TABLE RefreshToken (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    token NVARCHAR(255) NOT NULL UNIQUE,
    expires_at DATETIME2 NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    revoked_at DATETIME2 NULL,
    replaced_by_token NVARCHAR(255) NULL,
    CONSTRAINT FK_RefreshToken_User FOREIGN KEY (user_id) REFERENCES [User](user_id) ON DELETE CASCADE
);

CREATE INDEX IX_RefreshToken_Token ON RefreshToken(token);
CREATE INDEX IX_RefreshToken_UserId ON RefreshToken(user_id);
