import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const exists = await this.prisma.user.findUnique({
      where: { phone: dto.phone },
    });

    if (exists) {
      throw new ConflictException('Số điện thoại đã tồn tại');
    }

    const passwordHash = await bcrypt.hash(dto.password, 12);

    const user = await this.prisma.user.create({
      data: {
        phone: dto.phone,
        passwordHash,
        fullName: dto.fullName,
        roles: {
          create: { role: 'CUSTOMER' },
        },
      },
      include: { roles: true },
    });

    return this.issueToken(user.id, user.phone, user.roles.map((r) => r.role));
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { phone: dto.phone },
      include: { roles: true },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedException('Tài khoản không hợp lệ');
    }

    const valid = await bcrypt.compare(dto.password, user.passwordHash);

    if (!valid) {
      throw new UnauthorizedException('Sai số điện thoại hoặc mật khẩu');
    }

    return this.issueToken(user.id, user.phone, user.roles.map((r) => r.role));
  }

  private async issueToken(id: string, phone: string, roles: string[]) {
    const accessToken = await this.jwt.signAsync({
      sub: id,
      phone,
      roles,
    });

    return {
      accessToken,
      user: { id, phone, roles },
    };
  }
}
