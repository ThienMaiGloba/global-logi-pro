import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';

@Injectable()
export class RolesGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const handler = context.getHandler();

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user?.roles || !Array.isArray(user.roles)) {
      throw new ForbiddenException('Tài khoản chưa có quyền');
    }

    const roles = Reflect.getMetadata('roles', handler) as string[] | undefined;

    if (!roles || roles.length === 0) {
      return true;
    }

    if (!roles.some((role) => user.roles.includes(role))) {
      throw new ForbiddenException('Không đủ quyền thực hiện thao tác');
    }

    return true;
  }
}
