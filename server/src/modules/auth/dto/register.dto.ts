import { IsEmail, IsOptional, IsString, MinLength, IsPhoneNumber } from 'class-validator';

export class RegisterDto {
  @IsOptional()
  @IsEmail({}, { message: '请输入有效的邮箱地址' })
  email?: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsString()
  @MinLength(6, { message: '密码至少6位' })
  password: string;

  @IsOptional()
  @IsString()
  nickname?: string;
}
