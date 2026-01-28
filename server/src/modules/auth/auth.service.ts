import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async register(registerDto: RegisterDto) {
    const { email, phone, password, nickname } = registerDto;

    // 检查用户是否已存在
    const existingUser = await this.prisma.user.findFirst({
      where: {
        OR: [
          email ? { email } : {},
          phone ? { phone } : {},
        ].filter((condition) => Object.keys(condition).length > 0),
      },
    });

    if (existingUser) {
      throw new ConflictException('用户已存在');
    }

    // 加密密码
    const passwordHash = await bcrypt.hash(password, 10);

    // 创建用户
    const user = await this.prisma.user.create({
      data: {
        email,
        phone,
        passwordHash,
        nickname: nickname || '读者',
      },
    });

    // 生成 token
    const tokens = await this.generateTokens(user.id);

    return {
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        nickname: user.nickname,
        avatar: user.avatar,
      },
      ...tokens,
    };
  }

  async login(loginDto: LoginDto) {
    const { email, phone, password } = loginDto;

    // 查找用户
    const user = await this.prisma.user.findFirst({
      where: {
        OR: [
          email ? { email } : {},
          phone ? { phone } : {},
        ].filter((condition) => Object.keys(condition).length > 0),
      },
    });

    if (!user) {
      throw new UnauthorizedException('用户名或密码错误');
    }

    // 验证密码
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('用户名或密码错误');
    }

    // 生成 token
    const tokens = await this.generateTokens(user.id);

    return {
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        nickname: user.nickname,
        avatar: user.avatar,
      },
      ...tokens,
    };
  }

  async refreshToken(refreshToken: string) {
    // 验证 refresh token
    const tokenRecord = await this.prisma.refreshToken.findUnique({
      where: { token: refreshToken },
      include: { user: true },
    });

    if (!tokenRecord || tokenRecord.expiresAt < new Date()) {
      throw new UnauthorizedException('无效的刷新令牌');
    }

    // 删除旧的 refresh token
    await this.prisma.refreshToken.delete({
      where: { id: tokenRecord.id },
    });

    // 生成新的 tokens
    const tokens = await this.generateTokens(tokenRecord.user.id);

    return tokens;
  }

  async logout(userId: string, refreshToken?: string) {
    if (refreshToken) {
      await this.prisma.refreshToken.deleteMany({
        where: { token: refreshToken },
      });
    } else {
      // 删除用户所有的 refresh tokens
      await this.prisma.refreshToken.deleteMany({
        where: { userId },
      });
    }

    return { message: '退出登录成功' };
  }

  private async generateTokens(userId: string) {
    const payload = { sub: userId };

    // 生成 access token
    const accessToken = this.jwtService.sign(payload);

    // 生成 refresh token (7 天过期)
    const refreshToken = this.jwtService.sign(payload, {
      expiresIn: '7d',
    });

    // 计算过期时间
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    // 保存 refresh token
    await this.prisma.refreshToken.create({
      data: {
        userId,
        token: refreshToken,
        expiresAt,
      },
    });

    return {
      accessToken,
      refreshToken,
    };
  }
}
