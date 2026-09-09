import { Injectable } from '@nestjs/common';

@Injectable()
export class AdminService {
  async getSystemStats() {
    return {
      totalOrders: 142,
      totalRevenue: 18500000,
      activeDrivers: 15,
      completedOrders: 130,
      systemStatus: 'Healthy'
    };
  }
}
