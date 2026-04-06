import {
  Controller,
  Get,
  Post,
  Put,
  Param,
  Body,
  Query,
  Headers,
  ParseUUIDPipe,
  HttpStatus,
} from '@nestjs/common';
import { DoctorsService } from './doctors.service';
import { CreateDoctorProfileDto } from './dto/create-doctor-profile.dto';
import { UpdateDoctorProfileDto } from './dto/update-doctor-profile.dto';

@Controller('doctors')
export class DoctorsController {
  constructor(private readonly doctorsService: DoctorsService) {}

  @Post('profile')
  async createProfile(
    @Headers('x-user-id') userId: string,
    @Body() dto: CreateDoctorProfileDto,
  ) {
    const data = await this.doctorsService.createProfile(userId, dto);
    return {
      success: true,
      data,
      statusCode: HttpStatus.CREATED,
      timestamp: new Date().toISOString(),
    };
  }

  @Get('profile')
  async getMyProfile(@Headers('x-user-id') userId: string) {
    const data = await this.doctorsService.getProfile(userId);
    return {
      success: true,
      data,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  @Put('profile')
  async updateProfile(
    @Headers('x-user-id') userId: string,
    @Body() dto: UpdateDoctorProfileDto,
  ) {
    const data = await this.doctorsService.updateProfile(userId, dto);
    return {
      success: true,
      data,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  @Get('search')
  async searchDoctors(
    @Query('specialization') specialization?: string,
    @Query('name') name?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const result = await this.doctorsService.searchDoctors(
      specialization,
      name,
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
    );
    return {
      success: true,
      data: result.data,
      meta: { total: result.total, page: result.page, limit: result.limit },
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  @Get(':id')
  async getDoctorById(@Param('id', ParseUUIDPipe) id: string) {
    const data = await this.doctorsService.getProfileById(id);
    return {
      success: true,
      data,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  @Put(':id/verify')
  async verifyDoctor(@Param('id', ParseUUIDPipe) id: string) {
    const data = await this.doctorsService.verifyDoctor(id);
    return {
      success: true,
      data,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  @Get()
  async listAll(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const result = await this.doctorsService.listAll(
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
    );
    return {
      success: true,
      data: result.data,
      meta: { total: result.total, page: result.page, limit: result.limit },
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }
}
