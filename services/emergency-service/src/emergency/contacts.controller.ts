import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  Headers,
  HttpCode,
  HttpStatus,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ContactsService } from './contacts.service';
import { CreateContactDto } from './dto/create-contact.dto';

@Controller('emergency/contacts')
export class ContactsController {
  constructor(private readonly contactsService: ContactsService) {}

  @Get()
  async getContacts(@Headers('x-user-id') userId: string) {
    const contacts = await this.contactsService.getContacts(userId);
    return {
      success: true,
      data: contacts,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async createContact(
    @Headers('x-user-id') userId: string,
    @Body() dto: CreateContactDto,
  ) {
    const contact = await this.contactsService.createContact(userId, dto);
    return {
      success: true,
      data: contact,
      statusCode: HttpStatus.CREATED,
      timestamp: new Date().toISOString(),
    };
  }

  @Delete(':id')
  async deleteContact(
    @Headers('x-user-id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    const result = await this.contactsService.deleteContact(userId, id);
    return {
      success: true,
      data: result,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }
}
