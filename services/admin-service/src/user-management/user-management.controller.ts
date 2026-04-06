import {
  Controller,
  Get,
  Put,
  Delete,
  Param,
  Body,
  Query,
  Headers,
  ParseUUIDPipe,
  HttpStatus,
  HttpCode,
} from '@nestjs/common';
import { UserManagementService } from './user-management.service';
import { UpdateUserStatusDto } from './dto/update-user-status.dto';

@Controller('admin/users')
export class UserManagementController {
  constructor(private readonly userManagementService: UserManagementService) {}

  @Get()
  async listUsers(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('role') role?: string,
    @Query('search') search?: string,
    @Query('isActive') isActive?: string,
  ) {
    const result = await this.userManagementService.listUsers(
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
      role,
      search,
      isActive !== undefined ? isActive === 'true' : undefined,
    );
    return {
      success: true,
      data: result.data,
      meta: { total: result.total, page: result.page, limit: result.limit },
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  @Get('doctors/unverified')
  async listUnverifiedDoctors(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const result = await this.userManagementService.listUnverifiedDoctors(
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
  async getUserDetail(@Param('id', ParseUUIDPipe) id: string) {
    const data = await this.userManagementService.getUserDetail(id);
    return {
      success: true,
      data,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  @Put(':id/status')
  async updateUserStatus(
    @Param('id', ParseUUIDPipe) id: string,
    @Headers('x-user-id') adminId: string,
    @Body() dto: UpdateUserStatusDto,
  ) {
    const data = await this.userManagementService.updateUserStatus(id, dto, adminId);
    return {
      success: true,
      data,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async deleteUser(
    @Param('id', ParseUUIDPipe) id: string,
    @Headers('x-user-id') adminId: string,
  ) {
    await this.userManagementService.deleteUser(id, adminId);
    return {
      success: true,
      data: { message: 'User deactivated successfully' },
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  @Put('doctors/:id/verify')
  async verifyDoctor(
    @Param('id', ParseUUIDPipe) id: string,
    @Headers('x-user-id') adminId: string,
  ) {
    const data = await this.userManagementService.verifyDoctor(id, adminId);
    return {
      success: true,
      data,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }
}
