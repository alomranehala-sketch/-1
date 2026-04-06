import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EmergencyModule } from './emergency/emergency.module';
import { EmergencyAlert } from './entities/emergency-alert.entity';
import { EmergencyContact } from './entities/emergency-contact.entity';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '../../.env',
    }),

    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DB_HOST', 'localhost'),
        port: configService.get<number>('DB_PORT', 5432),
        username: configService.get('DB_USERNAME', 'healthcare_user'),
        password: configService.get('DB_PASSWORD', 'healthcare_password'),
        database: configService.get('DB_NAME', 'healthcare_db'),
        entities: [EmergencyAlert, EmergencyContact],
        synchronize: false,
        logging: configService.get('NODE_ENV') === 'development',
      }),
    }),

    EmergencyModule,
  ],
})
export class AppModule {}
