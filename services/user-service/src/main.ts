import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { AppModule } from './app.module';
import helmet from 'helmet';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const logger = new Logger('UserService');

  app.use(helmet());
  app.enableCors();
  app.useGlobalPipes(
    new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }),
  );
  app.setGlobalPrefix('api/v1');

  const port = process.env.PORT || process.env.USER_SERVICE_PORT || 3003;
  await app.listen(port);
  logger.log(`User Service running on port ${port}`);
}
bootstrap();
