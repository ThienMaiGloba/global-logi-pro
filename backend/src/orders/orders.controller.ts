import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
} from '@nestjs/common';
import { OrderStatus } from '@prisma/client';
import { CreateOrderDto } from './dto/create-order.dto';
import { OrdersService } from './orders.service';

@Controller('orders')
export class OrdersController {
  constructor(private readonly orders: OrdersService) {}

  @Get()
  findAll() {
    return this.orders.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.orders.findOne(id);
  }

  // Temporary development endpoint.
  // Production will derive customerId from JWT instead.
  @Post()
  create(
    @Body()
    body: CreateOrderDto & { customerId: string },
  ) {
    return this.orders.create(body.customerId, body);
  }

  @Patch(':id/status')
  transition(
    @Param('id') id: string,
    @Body('status') status: OrderStatus,
  ) {
    return this.orders.transition(id, status);
  }
}
