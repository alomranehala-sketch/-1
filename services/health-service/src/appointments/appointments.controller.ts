import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  Query,
  Headers,
  HttpCode,
  HttpStatus,
  ParseUUIDPipe,
} from '@nestjs/common';
import { AppointmentsService } from './appointments.service';
import { CreateAppointmentDto } from './dto/create-appointment.dto';
import { UpdateAppointmentDto } from './dto/update-appointment.dto';

@Controller('health/appointments')
export class AppointmentsController {
  constructor(private readonly appointmentsService: AppointmentsService) {}

  /**
   * POST /api/v1/health/appointments
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(
    @Headers('x-user-id') userId: string,
    @Headers('x-user-role') userRole: string,
    @Body() dto: CreateAppointmentDto,
  ) {
    const appointment = await this.appointmentsService.create(userId, dto, userRole);
    return {
      success: true,
      data: appointment,
      statusCode: HttpStatus.CREATED,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * GET /api/v1/health/appointments
   */
  @Get()
  async findAll(
    @Headers('x-user-id') userId: string,
    @Headers('x-user-role') userRole: string,
    @Query('page') page = 1,
    @Query('limit') limit = 20,
    @Query('status') status?: string,
  ) {
    const result = await this.appointmentsService.getUserAppointments(
      userId, userRole, page, limit, status,
    );
    return {
      success: true,
      data: result,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * GET /api/v1/health/appointments/upcoming
   */
  @Get('upcoming')
  async upcoming(
    @Headers('x-user-id') userId: string,
    @Headers('x-user-role') userRole: string,
  ) {
    const appointments = await this.appointmentsService.getUpcoming(userId, userRole);
    return {
      success: true,
      data: appointments,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * PATCH /api/v1/health/appointments/:id
   */
  @Patch(':id')
  async update(
    @Headers('x-user-id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateAppointmentDto,
  ) {
    const appointment = await this.appointmentsService.update(id, userId, dto);
    return {
      success: true,
      data: appointment,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }
}
