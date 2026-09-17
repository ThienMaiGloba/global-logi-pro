import { IsNotEmpty, IsString } from 'class-validator';

export class OfferOrderDto {
  @IsString()
  @IsNotEmpty()
  driverProfileId!: string;
}
