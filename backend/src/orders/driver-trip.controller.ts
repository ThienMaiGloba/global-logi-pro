import {
  Controller,
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

@Controller('driver/orders')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('DRIVER_BIKE', 'DRIVER_CAR', 'DRIVER_TRUCK')
export class DriverTripController {
  constructor(private readonly orders: OrdersService) {}

  @Post(':orderId/arrive')
  arrive(
    @CurrentUser() user: AuthenticatedUser,
    @Param('orderId') orderId: string,
  ) {
    return this.orders.driverArrive(orderId, user.sub);
  }

  @Post(':orderId/start-loading')
  startLoading(
    @CurrentUser() user: AuthenticatedUser,
    @Param('orderId') orderId: string,
  ) {
    return this.orders.driverStartLoading(orderId, user.sub);
  }

  @Post(':orderId/start-trip')
  startTrip(
    @CurrentUser() user: AuthenticatedUser,
    @Param('orderId') orderId: string,
  ) {
    return this.orders.driverStartTrip(orderId, user.sub);
  }

  @Post(':orderId/arrive-stop')
  arriveStop(
    @CurrentUser() user: AuthenticatedUser,
    @Param('orderId') orderId: string,
  ) {
    return this.orders.driverArriveStop(orderId, user.sub);
  }

  @Post(':orderId/start-delivery')
  startDelivery(
    @CurrentUser() user: AuthenticatedUser,
    @Param('orderId') orderId: string,
  ) {
    return this.orders.driverStartDelivery(orderId, user.sub);
  }

  @Post(':orderId/complete-delivery')
  completeDelivery(
    @CurrentUser() user: AuthenticatedUser,
    @Param('orderId') orderId: string,
  ) {
    return this.orders.driverCompleteDelivery(orderId, user.sub);
  }
}
