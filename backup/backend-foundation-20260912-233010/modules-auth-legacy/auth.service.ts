import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from './prisma.service';
import * as bcrypt from 'bcrypt';
import { RegisterDto, LoginDto } from './dto/auth.dto';
import { RoleType } from '@prisma/client';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const existing = await this.prisma.user.findUnique({ where: { phone: dto.phone } });
    if (existing) {
      throw new BadRequestException('Số điện thoại đã được đăng ký.');
    }

    const hashedPassword = await bcrypt.hash(dto.password, 10);
    const roleType = dto.role || RoleType.CUSTOMER;

    const user = await this.prisma.user.create({
      data: {
        phone: dto.phone,
        email: dto.email,
        passwordHash: hashedPassword,
        fullName: dto.fullName,
        roles: {
          create: { role: roleType },
        },
      },
      include: { roles: true },
    });

    const token = this.jwtService.sign({ sub: user.id, phone: user.phone, roles: user.roles.map(r => r.role) });
    return { accessToken: token, user: { id: user.id, phone: user.phone, fullName: user.fullName, roles: user.roles } };
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { phone: dto.phone },
      include: { roles: true },
    });

    if (!user || !(await bcrypt.compare(dto.password, user.passwordHash))) {
      throw new UnauthorizedException('Số điện thoại hoặc mật khẩu không chính xác.');
    }

    const token = this.jwtService.sign({ sub: user.id, phone: user.phone, roles: user.roles.map(r => r.role) });
    return { accessToken: token, user: { id: user.id, phone: user.phone, fullName: user.fullName, roles: user.roles } };
  }
}
