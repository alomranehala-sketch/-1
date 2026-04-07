import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { AppModule } from './app.module';
import helmet from 'helmet';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const logger = new Logger('EmergencyService');

  app.use(helmet());
  app.enableCors({
    origin: '*', // Allow WebSocket connections from any origin
    credentials: true,
  });
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
  app.setGlobalPrefix('api/v1');

  const port = process.env.PORT || process.env.EMERGENCY_SERVICE_PORT || 3002;
  await app.listen(port);
  logger.log(`Emergency Service running on port ${port}`);
}
bootstrap();
