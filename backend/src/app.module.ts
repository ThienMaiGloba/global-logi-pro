import { Module } from '@nestjs/common';
import { OrdersController } from './orders/orders.controller';

@Module({
  imports: [],
  controllers: [OrdersController],
  providers: [],
})
export class AppModule {}
