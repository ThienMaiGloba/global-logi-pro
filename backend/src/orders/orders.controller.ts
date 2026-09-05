import { Controller, Get, Post, Body, Param, Patch } from '@nestjs/common';

@Controller('orders')
export class OrdersController {
  private orders = [
    { id: 'ORD-001', customer: 'Nguyen Van A', route: 'Q.1 -> Q.7', price: 150000, status: 'Mới tạo' },
    { id: 'ORD-002', customer: 'Tran Thi B', route: 'Thu Duc -> Binh Thanh', price: 280000, status: 'Đang tìm tài xế' },
  ];

  @Get()
  findAll() {
    return this.orders;
  }

  @Patch(':id/status')
  updateStatus(@Param('id') id: string, @Body('status') status: string) {
    const order = this.orders.find(o => o.id === id);
    if (order) {
      order.status = status;
    }
    return order;
  }
}
