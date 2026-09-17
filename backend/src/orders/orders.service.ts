import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  AssignmentStatus,
  OrderStatus,
  Prisma,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { OfferOrderDto } from './dto/offer-order.dto';

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

const DRIVER_ROLES = [
  'DRIVER_BIKE',
  'DRIVER_CAR',
  'DRIVER_TRUCK',
] as const;

@Injectable()
export class OrdersService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.order.findMany({
      include: {
        stops: { orderBy: { sequence: 'asc' } },
        assignments: {
          include: {
            driver: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    const order = await this.prisma.order.findUnique({
      where: { id },
      include: {
        stops: { orderBy: { sequence: 'asc' } },
        assignments: {
          include: {
            driver: true,
          },
        },
      },
    });

    if (!order) {
      throw new NotFoundException('Không tìm thấy đơn hàng');
    }

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
    const order = await this.prisma.order.findUnique({
      where: { id },
    });

    if (!order) {
      throw new NotFoundException('Không tìm thấy đơn hàng');
    }

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
        assignments: true,
      },
    });
  }

  async offerOrder(orderId: string, dto: OfferOrderDto) {
    const now = new Date();

    return this.prisma.$transaction(
      async (tx) => {
        const order = await tx.order.findUnique({
          where: { id: orderId },
          include: {
            assignments: true,
          },
        });

        if (!order) {
          throw new NotFoundException('Không tìm thấy đơn hàng');
        }

        if (order.status !== OrderStatus.SEARCHING_DRIVER) {
          throw new BadRequestException(
            `Đơn phải ở SEARCHING_DRIVER để gửi offer. Hiện tại: ${order.status}`,
          );
        }

        const driver = await tx.driverProfile.findUnique({
          where: { id: dto.driverProfileId },
        });

        if (!driver) {
          throw new NotFoundException('Không tìm thấy DriverProfile');
        }

        if (!driver.online) {
          throw new BadRequestException('Tài xế hiện đang offline');
        }

        if (!driver.isVerified) {
          throw new ForbiddenException('Tài xế chưa được xác minh');
        }

        const driverUser = await tx.user.findFirst({
          where: {
            driverProfileId: driver.id,
          },
          include: {
            roles: true,
          },
        });

        if (!driverUser) {
          throw new BadRequestException(
            'DriverProfile chưa liên kết User',
          );
        }

        const hasDriverRole = driverUser.roles.some((role) =>
          (DRIVER_ROLES as readonly string[]).includes(role.role),
        );

        if (!hasDriverRole) {
          throw new ForbiddenException(
            'User không có quyền tài xế',
          );
        }

        const expiredOrderOffers = order.assignments.filter(
          (assignment) =>
            assignment.status === AssignmentStatus.OFFERED &&
            assignment.expiresAt <= now,
        );

        if (expiredOrderOffers.length > 0) {
          await tx.orderAssignment.updateMany({
            where: {
              id: {
                in: expiredOrderOffers.map((assignment) => assignment.id),
              },
              status: AssignmentStatus.OFFERED,
            },
            data: {
              status: AssignmentStatus.EXPIRED,
            },
          });
        }

        const activeOrderAssignment = order.assignments.find(
          (assignment) =>
            assignment.status === AssignmentStatus.ACCEPTED ||
            (assignment.status === AssignmentStatus.OFFERED &&
              assignment.expiresAt > now),
        );

        if (activeOrderAssignment) {
          throw new ConflictException(
            'Đơn hàng đã có assignment đang hoạt động',
          );
        }

        const activeDriverAssignment =
          await tx.orderAssignment.findFirst({
            where: {
              driverId: driver.id,
              order: {
                status: {
                  notIn: [
                    OrderStatus.COMPLETED,
                    OrderStatus.CANCELLED,
                  ],
                },
              },
              OR: [
                {
                  status: AssignmentStatus.ACCEPTED,
                },
                {
                  status: AssignmentStatus.OFFERED,
                  expiresAt: {
                    gt: now,
                  },
                },
              ],
            },
          });

        if (activeDriverAssignment) {
          throw new ConflictException(
            'Tài xế đang có assignment đang hoạt động',
          );
        }

        const expiresAt = new Date(
          now.getTime() + 20_000,
        );

        const assignment = await tx.orderAssignment.create({
          data: {
            orderId: order.id,
            driverId: driver.id,
            status: AssignmentStatus.OFFERED,
            offeredAt: now,
            expiresAt,
          },
          include: {
            driver: true,
            order: {
              include: {
                stops: {
                  orderBy: {
                    sequence: 'asc',
                  },
                },
              },
            },
          },
        });

        const updatedOrder = await tx.order.update({
          where: { id: order.id },
          data: {
            status: OrderStatus.DRIVER_OFFER,
          },
          include: {
            stops: {
              orderBy: {
                sequence: 'asc',
              },
            },
            assignments: true,
          },
        });

        return {
          order: updatedOrder,
          assignment,
        };
      },
      {
        isolationLevel:
          Prisma.TransactionIsolationLevel.Serializable,
      },
    );

  }

  async getDriverOffers(driverUserId: string) {
    const driver = await this.prisma.driverProfile.findFirst({
      where: {
        userId: driverUserId,
      },
    });

    if (!driver) {
      throw new NotFoundException(
        'Tài khoản chưa có DriverProfile',
      );
    }

    const now = new Date();

    return this.prisma.orderAssignment.findMany({
      where: {
        driverId: driver.id,
        status: AssignmentStatus.OFFERED,
        expiresAt: {
          gt: now,
        },
      },
      include: {
        order: {
          include: {
            stops: {
              orderBy: {
                sequence: 'asc',
              },
            },
          },
        },
      },
      orderBy: {
        offeredAt: 'asc',
      },
    });
  }

  async acceptDriverOffer(
    assignmentId: string,
    driverUserId: string,
  ) {
    const now = new Date();
    let expiredOffer = false;

    const result = await this.prisma.$transaction(
      async (tx) => {
        const driver = await tx.driverProfile.findFirst({
          where: {
            userId: driverUserId,
          },
        });

        if (!driver) {
          throw new NotFoundException(
            'Tài khoản chưa có DriverProfile',
          );
        }

        const assignment =
          await tx.orderAssignment.findUnique({
            where: {
              id: assignmentId,
            },
            include: {
              order: true,
            },
          });

        if (!assignment) {
          throw new NotFoundException(
            'Không tìm thấy lời mời chuyến',
          );
        }

        if (assignment.driverId !== driver.id) {
          throw new ForbiddenException(
            'Lời mời này không thuộc tài xế hiện tại',
          );
        }

        if (
          assignment.status !== AssignmentStatus.OFFERED
        ) {
          throw new ConflictException(
            `Lời mời không còn ở trạng thái OFFERED: ${assignment.status}`,
          );
        }

        if (assignment.expiresAt <= now) {
          await tx.orderAssignment.update({
            where: {
              id: assignment.id,
            },
            data: {
              status: AssignmentStatus.EXPIRED,
            },
          });

          await tx.order.updateMany({
            where: {
              id: assignment.orderId,
              status: OrderStatus.DRIVER_OFFER,
            },
            data: {
              status: OrderStatus.SEARCHING_DRIVER,
            },
          });

          expiredOffer = true;

          return {
            expired: true,
          };
        }

        if (
          assignment.order.status !==
          OrderStatus.DRIVER_OFFER
        ) {
          throw new ConflictException(
            `Đơn không còn ở DRIVER_OFFER: ${assignment.order.status}`,
          );
        }

        const acceptedAssignment =
          await tx.orderAssignment.updateMany({
            where: {
              id: assignment.id,
              driverId: driver.id,
              status: AssignmentStatus.OFFERED,
              expiresAt: {
                gt: now,
              },
            },
            data: {
              status: AssignmentStatus.ACCEPTED,
              acceptedAt: now,
              lockedAt: now,
            },
          });

        if (acceptedAssignment.count !== 1) {
          throw new ConflictException(
            'Lời mời đã được xử lý bởi một yêu cầu khác',
          );
        }

        const updatedOrder =
          await tx.order.updateMany({
            where: {
              id: assignment.orderId,
              status: OrderStatus.DRIVER_OFFER,
            },
            data: {
              status: OrderStatus.DRIVER_ACCEPTED,
            },
          });

        if (updatedOrder.count !== 1) {
          throw new ConflictException(
            'Đơn đã được tài xế khác nhận hoặc đã thay đổi trạng thái',
          );
        }

        await tx.orderAssignment.updateMany({
          where: {
            orderId: assignment.orderId,
            id: {
              not: assignment.id,
            },
            status: AssignmentStatus.OFFERED,
          },
          data: {
            status: AssignmentStatus.CANCELLED,
          },
        });

        return tx.orderAssignment.findUnique({
          where: {
            id: assignment.id,
          },
          include: {
            driver: true,
            order: {
              include: {
                stops: {
                  orderBy: {
                    sequence: 'asc',
                  },
                },
                assignments: true,
              },
            },
          },
        });
      },
      {
        isolationLevel:
          Prisma.TransactionIsolationLevel.Serializable,
      },
    );

    if (expiredOffer) {
      throw new ConflictException(
        'Lời mời đã hết hạn',
      );
    }

    return result;
  }

  private async getAcceptedDriverOrder(
    tx: any,
    orderId: string,
    driverUserId: string,
  ) {
    const driver = await tx.driverProfile.findFirst({
      where: {
        userId: driverUserId,
      },
    });

    if (!driver) {
      throw new NotFoundException(
        'Tài khoản chưa có DriverProfile',
      );
    }

    const order = await tx.order.findUnique({
      where: {
        id: orderId,
      },
      include: {
        assignments: true,
        stops: {
          orderBy: {
            sequence: 'asc',
          },
        },
      },
    });

    if (!order) {
      throw new NotFoundException(
        'Không tìm thấy đơn hàng',
      );
    }

    const acceptedAssignment = order.assignments.find(
      (assignment) =>
        assignment.driverId === driver.id &&
        assignment.status === AssignmentStatus.ACCEPTED,
    );

    if (!acceptedAssignment) {
      throw new ForbiddenException(
        'Đơn hàng chưa được giao cho tài xế hiện tại',
      );
    }

    return {
      driver,
      order,
      acceptedAssignment,
    };
  }

  async driverArrive(
    orderId: string,
    driverUserId: string,
  ) {
    const now = new Date();

    return this.prisma.$transaction(async (tx) => {
      const { order } =
        await this.getAcceptedDriverOrder(
          tx,
          orderId,
          driverUserId,
        );

      if (order.status !== OrderStatus.DRIVER_ACCEPTED) {
        throw new ConflictException(
          `Không thể báo đang đến từ trạng thái ${order.status}`,
        );
      }

      const pickup = order.stops.find(
        (stop) => stop.type === 'PICKUP',
      );

      if (!pickup) {
        throw new ConflictException(
          'Đơn hàng không có điểm PICKUP',
        );
      }

      await tx.orderStop.update({
        where: {
          id: pickup.id,
        },
        data: {
          arrivedAt: now,
        },
      });

      await tx.order.update({
        where: { id: orderId },
        data: {
          status: OrderStatus.DRIVER_ARRIVING,
        },
      });

      return tx.order.findUnique({
        where: { id: orderId },
        include: {
          stops: { orderBy: { sequence: 'asc' } },
          assignments: true,
        },
      });
    });
  }

  async driverStartLoading(
    orderId: string,
    driverUserId: string,
  ) {
    return this.prisma.$transaction(async (tx) => {
      const { order } =
        await this.getAcceptedDriverOrder(
          tx,
          orderId,
          driverUserId,
        );

      if (order.status !== OrderStatus.DRIVER_ARRIVING) {
        throw new ConflictException(
          `Không thể bắt đầu bốc hàng từ trạng thái ${order.status}`,
        );
      }

      const pickup = order.stops.find(
        (stop) => stop.type === 'PICKUP',
      );

      if (!pickup) {
        throw new ConflictException(
          'Đơn hàng không có điểm PICKUP',
        );
      }

      if (!pickup.arrivedAt) {
        throw new ConflictException(
          'Chưa ghi nhận tài xế đã đến điểm lấy hàng',
        );
      }

      return tx.order.update({
        where: { id: orderId },
        data: {
          status: OrderStatus.LOADING,
        },
        include: {
          stops: { orderBy: { sequence: 'asc' } },
          assignments: true,
        },
      });
    });
  }

  async driverStartTrip(
    orderId: string,
    driverUserId: string,
  ) {
    const now = new Date();

    return this.prisma.$transaction(async (tx) => {
      const { order } =
        await this.getAcceptedDriverOrder(
          tx,
          orderId,
          driverUserId,
        );

      if (order.status !== OrderStatus.LOADING) {
        throw new ConflictException(
          `Không thể bắt đầu chuyến từ trạng thái ${order.status}`,
        );
      }

      const pickup = order.stops.find(
        (stop) => stop.type === 'PICKUP',
      );

      if (!pickup) {
        throw new ConflictException(
          'Đơn hàng không có điểm PICKUP',
        );
      }

      await tx.orderStop.update({
        where: {
          id: pickup.id,
        },
        data: {
          arrivedAt: pickup.arrivedAt ?? now,
          completedAt: now,
        },
      });

      return tx.order.update({
        where: { id: orderId },
        data: {
          status: OrderStatus.IN_TRANSIT,
        },
        include: {
          stops: { orderBy: { sequence: 'asc' } },
          assignments: true,
        },
      });
    });
  }

  async driverArriveStop(
    orderId: string,
    driverUserId: string,
  ) {
    const now = new Date();

    return this.prisma.$transaction(async (tx) => {
      const { order } =
        await this.getAcceptedDriverOrder(
          tx,
          orderId,
          driverUserId,
        );

      if (order.status !== OrderStatus.IN_TRANSIT) {
        throw new ConflictException(
          `Không thể báo đến điểm giao từ trạng thái ${order.status}`,
        );
      }

      const delivery = order.stops.find(
        (stop) => stop.type === 'DELIVERY',
      );

      if (!delivery) {
        throw new ConflictException(
          'Đơn hàng không có điểm DELIVERY',
        );
      }

      await tx.orderStop.update({
        where: {
          id: delivery.id,
        },
        data: {
          arrivedAt: now,
        },
      });

      return tx.order.update({
        where: { id: orderId },
        data: {
          status: OrderStatus.ARRIVED_STOP,
        },
        include: {
          stops: { orderBy: { sequence: 'asc' } },
          assignments: true,
        },
      });
    });
  }

  async driverStartDelivery(
    orderId: string,
    driverUserId: string,
  ) {
    return this.prisma.$transaction(async (tx) => {
      const { order } =
        await this.getAcceptedDriverOrder(
          tx,
          orderId,
          driverUserId,
        );

      if (order.status !== OrderStatus.ARRIVED_STOP) {
        throw new ConflictException(
          `Không thể bắt đầu giao từ trạng thái ${order.status}`,
        );
      }

      const delivery = order.stops.find(
        (stop) => stop.type === 'DELIVERY',
      );

      if (!delivery?.arrivedAt) {
        throw new ConflictException(
          'Chưa ghi nhận tài xế đến điểm giao',
        );
      }

      return tx.order.update({
        where: { id: orderId },
        data: {
          status: OrderStatus.DELIVERING,
        },
        include: {
          stops: { orderBy: { sequence: 'asc' } },
          assignments: true,
        },
      });
    });
  }

  async driverCompleteDelivery(
    orderId: string,
    driverUserId: string,
  ) {
    const now = new Date();

    return this.prisma.$transaction(async (tx) => {
      const { order } =
        await this.getAcceptedDriverOrder(
          tx,
          orderId,
          driverUserId,
        );

      if (order.status !== OrderStatus.DELIVERING) {
        throw new ConflictException(
          `Không thể hoàn tất giao hàng từ trạng thái ${order.status}`,
        );
      }

      const delivery = order.stops.find(
        (stop) => stop.type === 'DELIVERY',
      );

      if (!delivery?.arrivedAt) {
        throw new ConflictException(
          'Chưa ghi nhận tài xế đến điểm giao',
        );
      }

      await tx.orderStop.update({
        where: {
          id: delivery.id,
        },
        data: {
          completedAt: now,
        },
      });

      return tx.order.update({
        where: { id: orderId },
        data: {
          status: OrderStatus.DELIVERED,
        },
        include: {
          stops: { orderBy: { sequence: 'asc' } },
          assignments: true,
        },
      });
    });
  }

}
