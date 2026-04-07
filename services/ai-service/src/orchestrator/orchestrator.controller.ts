import {
  Controller,
  Post,
  Body,
  Headers,
  HttpCode,
  HttpStatus,
  Logger,
  BadRequestException,
} from '@nestjs/common';
import { OrchestratorService, OrchestratorRequest } from './orchestrator.service';
import { IsString, MinLength, MaxLength, IsOptional, IsObject, IsNumber, Min, Max } from 'class-validator';

export class OrchestratorRequestDto {
  @IsString()
  @MinLength(1)
  @MaxLength(5000)
  message: string;

  @IsOptional()
  @IsObject()
  context?: {
    governorate?: string;
    age?: number;
    gender?: string;
    chronicConditions?: string[];
    insuranceProvider?: string;
    locationLat?: number;
    locationLng?: number;
    appointmentId?: string;
  };
}

@Controller('orchestrator')
export class OrchestratorController {
  private readonly logger = new Logger(OrchestratorController.name);

  constructor(private readonly orchestratorService: OrchestratorService) {}

  /**
   * POST /api/v1/orchestrator/process
   * Main entry point — routes request through the AI pipeline
   */
  @Post('process')
  @HttpCode(HttpStatus.OK)
  async process(
    @Headers('x-user-id') userId: string,
    @Body() dto: OrchestratorRequestDto,
  ) {
    if (!userId || userId.trim() === '') {
      throw new BadRequestException('x-user-id header is required');
    }
    this.logger.log(`Orchestrator request from user ${userId}: ${dto.message.substring(0, 100)}`);

    const request: OrchestratorRequest = {
      userId,
      message: dto.message,
      context: dto.context,
    };

    const result = await this.orchestratorService.process(request);

    return {
      success: true,
      data: result,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }
}
