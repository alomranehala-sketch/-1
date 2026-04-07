import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { EmergencyContact } from '../entities/emergency-contact.entity';
import { CreateContactDto } from './dto/create-contact.dto';

@Injectable()
export class ContactsService {
  private readonly logger = new Logger(ContactsService.name);

  constructor(
    @InjectRepository(EmergencyContact)
    private readonly contactRepo: Repository<EmergencyContact>,
  ) {}

  async getContacts(userId: string) {
    return this.contactRepo.find({
      where: { userId },
      order: { isPrimary: 'DESC', createdAt: 'ASC' },
    });
  }

  async createContact(userId: string, dto: CreateContactDto) {
    // If setting as primary, unset existing primary
    if (dto.isPrimary) {
      await this.contactRepo.update(
        { userId, isPrimary: true },
        { isPrimary: false },
      );
    }

    const contact = this.contactRepo.create({ userId, ...dto });
    return this.contactRepo.save(contact);
  }

  async deleteContact(userId: string, contactId: string) {
    const contact = await this.contactRepo.findOne({
      where: { id: contactId, userId },
    });
    if (!contact) {
      throw new NotFoundException('Contact not found');
    }
    await this.contactRepo.remove(contact);
    return { message: 'Contact deleted' };
  }
}
