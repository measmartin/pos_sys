export interface UserDto {
  userId: number;
  username: string;
  email?: string;
  displayName?: string;
  isActive: boolean;
  lastLoginAt?: string;
}

export interface LoginDto {
  username: string;
  password: string;
}

export interface RegisterDto {
  username: string;
  password: string;
  email?: string;
  displayName?: string;
}

export interface ChangePasswordDto {
  currentPassword: string;
  newPassword: string;
}

export interface AuthResponseDto {
  token: string;
  refreshToken: string;
  tokenType: string;
  expiresIn: number;
  user: UserDto;
}

export interface RefreshTokenDto {
  refreshToken: string;
}
