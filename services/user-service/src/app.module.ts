import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersModule } from './users/users.module';
import { DoctorsModule } from './doctors/doctors.module';
import { User } from './entities/user.entity';
import { DoctorProfile } from './entities/doctor-profile.entity';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, envFilePath: '../../.env' }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (c: ConfigService) => ({
        type: 'postgres',
        host: c.get('DB_HOST', 'localhost'),
        port: c.get<number>('DB_PORT', 5432),
        username: c.get('DB_USERNAME', 'healthcare_user'),
        password: c.get('DB_PASSWORD', 'healthcare_password'),
        database: c.get('DB_NAME', 'healthcare_db'),
        entities: [User, DoctorProfile],
        synchronize: false,
      }),
    }),
    UsersModule,
    DoctorsModule,
  ],
})
export class AppModule {}
