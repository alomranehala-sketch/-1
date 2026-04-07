import {
  Controller,
  Get,
  Put,
  Body,
  Param,
  Query,
  Headers,
  HttpStatus,
  ParseUUIDPipe,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  /**
   * GET /api/v1/users/profile
   * Get current user's profile
   */
  @Get('profile')
  async getProfile(@Headers('x-user-id') userId: string) {
    const profile = await this.usersService.getProfile(userId);
    return {
      success: true,
      data: profile,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * PUT /api/v1/users/profile
   * Update current user's profile
   */
  @Put('profile')
  async updateProfile(
    @Headers('x-user-id') userId: string,
    @Body() dto: UpdateProfileDto,
  ) {
    const profile = await this.usersService.updateProfile(userId, dto);
    return {
      success: true,
      data: profile,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * GET /api/v1/users/:id
   * Get user by ID (admin/doctor access)
   */
  @Get(':id')
  async getUserById(
    @Headers('x-user-id') requesterId: string,
    @Headers('x-user-role') requesterRole: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    const user = await this.usersService.getUserById(id, requesterId, requesterRole);
    return {
      success: true,
      data: user,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * GET /api/v1/users/search?q=john&page=1
   * Search users (admin/doctor)
   */
  @Get('search')
  async search(
    @Query('q') query: string,
    @Query('page') page = 1,
    @Query('limit') limit = 20,
  ) {
    const result = await this.usersService.searchUsers(query, page, limit);
    return {
      success: true,
      data: result,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }
}
