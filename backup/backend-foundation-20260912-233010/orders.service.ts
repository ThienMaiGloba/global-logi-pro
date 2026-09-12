import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { OrderStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateOrderDto } from './dto/create-order.dto';

const transitions: Record<OrderStatus, OrderStatus[]> = {
  DRAFT: ['QUOTED', 'CANCELLED'],
  QUOTED: ['CONFIRMED', 'CANCELLED'],
  CONFIRMED: ['SEARCHING_DRIVER', 'CANCELLED'],
  SEARCHING_DRIVER: ['DRIVER_OFFER', 'CANCELLED'],
  DRIVER_OFFER: ['DRIVER_ACCEPTED', 'SEARCHING_DRIVER', 'CANCELLED'],
  DRIVER_ACCEPTED: ['DRIVER_ARRIVING', 'CANCELLED'],
  DRIVER_ARRIVING: ['ARRIVED_PICKUP', 'CANCELLED'],
  ARRIVED_PICKUP: ['LOADING', 'CANCELLED'],
  LOADING: ['IN_TRANSIT', 'CANCELLED'],
  IN_TRANSIT: ['ARRIVED_STOP', 'DELIVERING', 'CANCELLED'],
  ARRIVED_STOP: ['DELIVERING', 'IN_TRANSIT', 'CANCELLED'],
  DELIVERING: ['DELIVERED', 'CANCELLED'],
  DELIVERED: ['COMPLETED'],
  COMPLETED: [],
  CANCELLED: [],
};

@Injectable()
export class OrdersService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.order.findMany({
      include: {
        stops: { orderBy: { sequence: 'asc' } },
        assignments: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    const order = await this.prisma.order.findUnique({
      where: { id },
      include: {
        stops: { orderBy: { sequence: 'asc' } },
        assignments: true,
      },
    });

    if (!order) throw new NotFoundException('Không tìm thấy đơn hàng');

    return order;
  }

  async create(customerId: string, dto: CreateOrderDto) {
    if (dto.stops.length < 2) {
      throw new BadRequestException('Đơn hàng phải có ít nhất 2 điểm');
    }

    const sequences = dto.stops.map((s) => s.sequence);
    if (new Set(sequences).size !== sequences.length) {
      throw new BadRequestException('Sequence điểm dừng bị trùng');
    }

    for (const stop of dto.stops) {
      if (
        stop.latitude < -90 ||
        stop.latitude > 90 ||
        stop.longitude < -180 ||
        stop.longitude > 180
      ) {
        throw new BadRequestException('Tọa độ GPS không hợp lệ');
      }
    }

    return this.prisma.order.create({
      data: {
        customerId,
        price: dto.price,
        notes: dto.notes,
        idempotencyKey: dto.idempotencyKey,
        stops: {
          create: dto.stops.map((s) => ({
            sequence: s.sequence,
            type: s.type,
            latitude: s.latitude,
            longitude: s.longitude,
            address: s.address,
          })),
        },
      },
      include: {
        stops: { orderBy: { sequence: 'asc' } },
      },
    });
  }

  async transition(id: string, next: OrderStatus) {
    const order = await this.prisma.order.findUnique({ where: { id } });

    if (!order) throw new NotFoundException('Không tìm thấy đơn hàng');

    if (!transitions[order.status].includes(next)) {
      throw new BadRequestException(
        `Không thể chuyển ${order.status} -> ${next}`,
      );
    }

    return this.prisma.order.update({
      where: { id },
      data: { status: next },
      include: {
        stops: { orderBy: { sequence: 'asc' } },
      },
    });
  }
}
