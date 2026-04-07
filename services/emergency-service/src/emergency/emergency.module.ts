import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EmergencyAlert } from '../entities/emergency-alert.entity';
import { EmergencyContact } from '../entities/emergency-contact.entity';
import { EmergencyController } from './emergency.controller';
import { EmergencyService } from './emergency.service';
import { EmergencyGateway } from './emergency.gateway';
import { ContactsController } from './contacts.controller';
import { ContactsService } from './contacts.service';

@Module({
  imports: [TypeOrmModule.forFeature([EmergencyAlert, EmergencyContact])],
  controllers: [EmergencyController, ContactsController],
  providers: [EmergencyService, EmergencyGateway, ContactsService],
  exports: [EmergencyService],
})
export class EmergencyModule {}
