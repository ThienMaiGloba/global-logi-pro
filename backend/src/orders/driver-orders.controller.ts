import {
  Controller,
  Get,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import { OrdersService } from './orders.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedUser } from '../auth/guards/jwt-auth.guard';

@Controller('driver')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('DRIVER_BIKE', 'DRIVER_CAR', 'DRIVER_TRUCK')
export class DriverOrdersController {
  constructor(private readonly orders: OrdersService) {}

  @Get('offers')
  getOffers(@CurrentUser() user: AuthenticatedUser) {
    return this.orders.getDriverOffers(user.sub);
  }

  @Post('offers/:assignmentId/accept')
  acceptOffer(
    @CurrentUser() user: AuthenticatedUser,
    @Param('assignmentId') assignmentId: string,
  ) {
    return this.orders.acceptDriverOffer(
      assignmentId,
      user.sub,
    );
  }
}
