import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  Headers,
  HttpCode,
  HttpStatus,
  ParseUUIDPipe,
} from '@nestjs/common';
import { RecordsService } from './records.service';
import { CreateRecordDto } from './dto/create-record.dto';
import { UpdateRecordDto } from './dto/update-record.dto';

@Controller('health/records')
export class RecordsController {
  constructor(private readonly recordsService: RecordsService) {}

  /**
   * POST /api/v1/health/records
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(
    @Headers('x-user-id') userId: string,
    @Headers('x-user-role') userRole: string,
    @Body() dto: CreateRecordDto,
  ) {
    const record = await this.recordsService.createRecord(userId, dto, userRole);
    return {
      success: true,
      data: record,
      statusCode: HttpStatus.CREATED,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * GET /api/v1/health/records
   */
  @Get()
  async findAll(
    @Headers('x-user-id') userId: string,
    @Query('page') page = 1,
    @Query('limit') limit = 20,
    @Query('type') recordType?: string,
  ) {
    const result = await this.recordsService.getUserRecords(userId, page, limit, recordType);
    return {
      success: true,
      data: result,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * GET /api/v1/health/records/:id
   */
  @Get(':id')
  async findOne(
    @Headers('x-user-id') userId: string,
    @Headers('x-user-role') userRole: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    const record = await this.recordsService.getRecord(id, userId, userRole);
    return {
      success: true,
      data: record,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * PUT /api/v1/health/records/:id
   */
  @Put(':id')
  async update(
    @Headers('x-user-id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateRecordDto,
  ) {
    const record = await this.recordsService.updateRecord(id, userId, dto);
    return {
      success: true,
      data: record,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * DELETE /api/v1/health/records/:id
   */
  @Delete(':id')
  async remove(
    @Headers('x-user-id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    const result = await this.recordsService.deleteRecord(id, userId);
    return {
      success: true,
      data: result,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }
}
