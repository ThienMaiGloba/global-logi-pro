import {
  ArrayMinSize,
  IsArray,
  IsEnum,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

enum StopTypeDto {
  PICKUP = 'PICKUP',
  DELIVERY = 'DELIVERY',
  WAYPOINT = 'WAYPOINT',
}

class StopDto {
  @IsInt()
  @Min(0)
  sequence!: number;

  @IsEnum(StopTypeDto)
  type!: StopTypeDto;

  @IsNumber()
  latitude!: number;

  @IsNumber()
  longitude!: number;

  @IsString()
  address!: string;
}

export class CreateOrderDto {
  @IsInt()
  @Min(0)
  price!: number;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsOptional()
  @IsString()
  idempotencyKey?: string;

  @IsArray()
  @ArrayMinSize(2)
  @ValidateNested({ each: true })
  @Type(() => StopDto)
  stops!: StopDto[];
}
