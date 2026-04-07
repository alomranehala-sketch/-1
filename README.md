# Healthcare AI Platform - Backend

## Architecture

This is a microservices-based healthcare platform built with NestJS, PostgreSQL, Redis, and Docker.

### Services

| Service | Port | Description |
|---------|------|-------------|
| API Gateway | 3000 | Routes requests, rate limiting, auth verification |
| Auth Service | 3001 | JWT/OAuth authentication, role management |
| User Service | 3002 | User profiles, doctor profiles |
| Health Data Service | 3003 | Health records, daily tracking, appointments |
| AI Service | 3004 | LLM-powered health insights, conversation history |
| Notification Service | 3005 | Email, SMS, push notifications |
| Emergency Service | 3006 | Real-time alerts via WebSocket |
| Admin Service | 3007 | Dashboard, analytics, system management |

### Quick Start

```bash
# Clone and setup
cp .env.example .env
# Edit .env with your actual values

# Start all services with Docker
docker-compose up -d

# Run database migrations
docker-compose exec auth-service npm run migration:run
```

### Tech Stack

- **Runtime**: Node.js 20+ with NestJS
- **Database**: PostgreSQL 16
- **Cache**: Redis 7
- **Queue**: BullMQ (Redis-backed)
- **Realtime**: Socket.IO
- **Storage**: AWS S3
- **Containers**: Docker + Docker Compose
- **CI/CD**: GitHub Actions

### API Documentation

All APIs are versioned under `/api/v1/`. See individual service READMEs for endpoint details.
