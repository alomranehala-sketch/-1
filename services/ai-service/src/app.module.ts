import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BullModule } from '@nestjs/bullmq';
import { ConversationModule } from './conversation/conversation.module';
import { LlmModule } from './llm/llm.module';
import { Conversation } from './entities/conversation.entity';
import { Message } from './entities/message.entity';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '../../.env',
    }),

    // Database
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
        entities: [Conversation, Message],
        synchronize: false,
        logging: configService.get('NODE_ENV') === 'development',
      }),
    }),

    // BullMQ for async AI processing
    BullModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        connection: {
          host: configService.get('REDIS_HOST', 'localhost'),
          port: configService.get<number>('REDIS_PORT', 6379),
          password: configService.get('REDIS_PASSWORD', undefined),
        },
      }),
    }),

    ConversationModule,
    LlmModule,
  ],
})
export class AppModule {}
