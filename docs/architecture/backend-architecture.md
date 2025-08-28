# Backend Architecture

## Overview

The backend follows a microservices architecture with domain-driven design principles. Each service is autonomous, owns its data, and communicates through well-defined APIs and events.

## Microservice Structure

```typescript
// Standard microservice structure
src/
├── api/
│   ├── routes/          # HTTP endpoints
│   ├── controllers/     # Request handlers
│   └── middleware/      # Auth, validation, etc.
├── domain/
│   ├── entities/        # Domain models
│   ├── services/        # Business logic
│   └── repositories/    # Data access
├── infrastructure/
│   ├── database/        # DB connections
│   ├── cache/          # Redis client
│   └── messaging/      # Event bus
├── application/
│   ├── commands/       # Write operations
│   ├── queries/        # Read operations
│   └── events/         # Domain events
└── shared/
    ├── errors/         # Custom errors
    └── utils/          # Utilities
```

## Service Definitions

### Formula Service

**Responsibilities:**
- Formula CRUD operations
- Formula validation and syntax checking
- Weight calculations and normalization
- Template management

**API Endpoints:**
```typescript
// Formula Service Routes
POST   /api/formulas                 // Create formula
GET    /api/formulas                 // List user formulas
GET    /api/formulas/{id}            // Get specific formula
PUT    /api/formulas/{id}            // Update formula
DELETE /api/formulas/{id}            // Delete formula
POST   /api/formulas/{id}/duplicate  // Clone formula
GET    /api/formulas/templates       // Get templates
POST   /api/formulas/validate        // Validate formula
```

**Domain Model:**
```typescript
interface Formula {
  id: string;
  userId: string;
  name: string;
  description?: string;
  metrics: FormulaMetric[];
  isTemplate: boolean;
  isPublic: boolean;
  createdAt: Date;
  updatedAt: Date;
}

interface FormulaMetric {
  metricId: string;
  weight: number; // 0-100
  parameters?: Record<string, any>;
}
```

### Prediction Service

**Responsibilities:**
- Generate predictions using formulas
- Apply real-time data to calculations
- Manage prediction history
- Calculate confidence scores

**API Endpoints:**
```typescript
POST   /api/predictions/generate     // Generate predictions
GET    /api/predictions              // Get user predictions
GET    /api/predictions/{id}         // Get specific prediction
GET    /api/predictions/round/{num}  // Get round predictions
POST   /api/predictions/{id}/compare // Compare with actual
GET    /api/predictions/accuracy     // Get accuracy metrics
```

**Domain Model:**
```typescript
interface Prediction {
  id: string;
  formulaId: string;
  matchId: string;
  predictedWinnerId: string;
  confidence: number; // 0-100
  calculationDetails: CalculationDetail[];
  actualWinnerId?: string;
  correct?: boolean;
  createdAt: Date;
}

interface CalculationDetail {
  metricId: string;
  metricValue: number;
  weight: number;
  contribution: number;
}
```

### Backtest Service

**Responsibilities:**
- Run historical simulations
- Calculate accuracy metrics
- Manage backtest cache
- Provide performance analytics

**API Endpoints:**
```typescript
POST   /api/backtest/run            // Run backtest
GET    /api/backtest/{id}           // Get results
GET    /api/backtest/history        // Get history
DELETE /api/backtest/{id}/cache     // Clear cache
POST   /api/backtest/compare        // Compare formulas
```

### User Service

**Responsibilities:**
- Authentication and authorization
- User profile management
- Preference tracking
- Account operations

**API Endpoints:**
```typescript
POST   /api/auth/register           // User registration
POST   /api/auth/login              // User login
POST   /api/auth/refresh            // Refresh token
POST   /api/auth/logout             // User logout
GET    /api/users/profile           // Get profile
PUT    /api/users/profile           // Update profile
DELETE /api/users/account           // Delete account
```

## API Gateway

```typescript
// API Gateway configuration
class APIGateway {
  private routes = {
    '/api/formulas*': 'http://formula-service:3001',
    '/api/predictions*': 'http://prediction-service:3002',
    '/api/backtest*': 'http://backtest-service:3003',
    '/api/auth*': 'http://user-service:3004',
    '/api/users*': 'http://user-service:3004'
  };
  
  middleware = [
    rateLimiting(),
    authentication(),
    authorization(),
    logging(),
    caching(),
    errorHandling()
  ];
  
  async route(req: Request): Promise<Response> {
    const service = this.findService(req.path);
    
    // Add correlation ID
    req.headers['x-correlation-id'] = generateId();
    
    // Circuit breaker
    return await circuitBreaker.execute(() => 
      proxy(service, req)
    );
  }
}
```

## Authentication & Authorization

### JWT Token Strategy

```typescript
// Token configuration
const tokenConfig = {
  access: {
    secret: process.env.JWT_ACCESS_SECRET,
    expiresIn: '15m',
    algorithm: 'RS256'
  },
  refresh: {
    secret: process.env.JWT_REFRESH_SECRET,
    expiresIn: '30d',
    algorithm: 'RS256'
  }
};

// Token payload
interface TokenPayload {
  sub: string;      // User ID
  email: string;
  roles: string[];
  iat: number;
  exp: number;
}

// Authentication middleware
export const authenticate = async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  try {
    const payload = jwt.verify(token, tokenConfig.access.secret);
    req.user = payload;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired' });
    }
    return res.status(403).json({ error: 'Invalid token' });
  }
};
```

### Authorization Patterns

```typescript
// Role-based access control
enum Role {
  USER = 'user',
  PREMIUM = 'premium',
  ADMIN = 'admin'
}

// Permission middleware
export const authorize = (...roles: Role[]) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    const hasRole = roles.some(role => 
      req.user.roles.includes(role)
    );
    
    if (!hasRole) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    
    next();
  };
};

// Resource-based authorization
export const authorizeResource = async (req, res, next) => {
  const resource = await getResource(req.params.id);
  
  if (resource.userId !== req.user.sub) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  
  next();
};
```

## Data Access Layer

### Repository Pattern

```typescript
// Base repository
abstract class BaseRepository<T> {
  constructor(protected prisma: PrismaClient) {}
  
  async findById(id: string): Promise<T | null> {
    return this.prisma[this.model].findUnique({
      where: { id }
    });
  }
  
  async findAll(filter?: any): Promise<T[]> {
    return this.prisma[this.model].findMany({
      where: filter
    });
  }
  
  async create(data: Partial<T>): Promise<T> {
    return this.prisma[this.model].create({
      data
    });
  }
  
  async update(id: string, data: Partial<T>): Promise<T> {
    return this.prisma[this.model].update({
      where: { id },
      data
    });
  }
  
  async delete(id: string): Promise<void> {
    await this.prisma[this.model].delete({
      where: { id }
    });
  }
}

// Formula repository
class FormulaRepository extends BaseRepository<Formula> {
  model = 'formula';
  
  async findByUserId(userId: string): Promise<Formula[]> {
    return this.prisma.formula.findMany({
      where: { userId },
      orderBy: { updatedAt: 'desc' }
    });
  }
  
  async findTemplates(): Promise<Formula[]> {
    return this.prisma.formula.findMany({
      where: { isTemplate: true }
    });
  }
}
```

## Event-Driven Architecture

### Event Bus Configuration

```typescript
// Event types
enum EventType {
  FORMULA_CREATED = 'formula.created',
  FORMULA_UPDATED = 'formula.updated',
  PREDICTION_GENERATED = 'prediction.generated',
  USER_REGISTERED = 'user.registered',
  DATA_UPDATED = 'data.updated'
}

// Event interface
interface DomainEvent {
  id: string;
  type: EventType;
  aggregateId: string;
  payload: any;
  metadata: {
    userId?: string;
    correlationId: string;
    timestamp: Date;
  };
}

// Event publisher
class EventPublisher {
  constructor(private serviceBus: ServiceBusClient) {}
  
  async publish(event: DomainEvent): Promise<void> {
    const sender = this.serviceBus.createSender('events');
    
    await sender.sendMessages({
      body: event,
      contentType: 'application/json',
      correlationId: event.metadata.correlationId
    });
    
    await sender.close();
  }
}

// Event handler
abstract class EventHandler<T extends DomainEvent> {
  abstract eventType: EventType;
  
  abstract handle(event: T): Promise<void>;
  
  async process(message: ServiceBusMessage): Promise<void> {
    const event = message.body as T;
    
    try {
      await this.handle(event);
      await message.complete();
    } catch (error) {
      await message.abandon();
      throw error;
    }
  }
}
```

## Caching Strategy

```typescript
// Cache configuration
class CacheService {
  private redis: Redis;
  
  constructor() {
    this.redis = new Redis({
      host: process.env.REDIS_HOST,
      port: process.env.REDIS_PORT,
      password: process.env.REDIS_PASSWORD,
      keyPrefix: 'afl:'
    });
  }
  
  // Cache patterns
  async cacheAside<T>(
    key: string,
    fetcher: () => Promise<T>,
    ttl = 3600
  ): Promise<T> {
    // Try to get from cache
    const cached = await this.redis.get(key);
    if (cached) {
      return JSON.parse(cached);
    }
    
    // Fetch from source
    const data = await fetcher();
    
    // Store in cache
    await this.redis.setex(
      key,
      ttl,
      JSON.stringify(data)
    );
    
    return data;
  }
  
  // Write-through cache
  async writeThrough<T>(
    key: string,
    data: T,
    writer: () => Promise<void>,
    ttl = 3600
  ): Promise<void> {
    // Write to database
    await writer();
    
    // Update cache
    await this.redis.setex(
      key,
      ttl,
      JSON.stringify(data)
    );
  }
  
  // Cache invalidation
  async invalidate(pattern: string): Promise<void> {
    const keys = await this.redis.keys(pattern);
    if (keys.length > 0) {
      await this.redis.del(...keys);
    }
  }
}

// Cache keys
const cacheKeys = {
  formula: (id: string) => `formula:${id}`,
  userFormulas: (userId: string) => `user:${userId}:formulas`,
  predictions: (round: number) => `predictions:round:${round}`,
  backtest: (formulaId: string, season: number) => 
    `backtest:${formulaId}:${season}`
};
```

## Error Handling

```typescript
// Custom error classes
class DomainError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 400
  ) {
    super(message);
    this.name = 'DomainError';
  }
}

class ValidationError extends DomainError {
  constructor(message: string, public errors: any[]) {
    super(message, 'VALIDATION_ERROR', 400);
  }
}

class NotFoundError extends DomainError {
  constructor(resource: string) {
    super(`${resource} not found`, 'NOT_FOUND', 404);
  }
}

class UnauthorizedError extends DomainError {
  constructor(message = 'Unauthorized') {
    super(message, 'UNAUTHORIZED', 401);
  }
}

// Global error handler
export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (err instanceof DomainError) {
    return res.status(err.statusCode).json({
      error: {
        code: err.code,
        message: err.message,
        ...(err instanceof ValidationError && {
          errors: err.errors
        })
      }
    });
  }
  
  // Log unexpected errors
  logger.error('Unexpected error', {
    error: err,
    request: {
      method: req.method,
      path: req.path,
      body: req.body
    }
  });
  
  res.status(500).json({
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred'
    }
  });
};
```

## API Versioning

```typescript
// Version middleware
export const apiVersion = (version: string) => {
  return (req, res, next) => {
    const requestedVersion = 
      req.headers['api-version'] || 
      req.query.v ||
      'v1';
    
    if (requestedVersion !== version) {
      return res.status(400).json({
        error: 'Unsupported API version'
      });
    }
    
    next();
  };
};

// Versioned routes
app.use('/api/v1', apiVersion('v1'), v1Routes);
app.use('/api/v2', apiVersion('v2'), v2Routes);
```

## Rate Limiting

```typescript
// Rate limiting configuration
const rateLimits = {
  global: {
    windowMs: 60 * 1000,  // 1 minute
    max: 100               // 100 requests
  },
  auth: {
    windowMs: 15 * 60 * 1000,  // 15 minutes
    max: 5                      // 5 attempts
  },
  api: {
    windowMs: 60 * 1000,  // 1 minute
    max: 60               // 60 requests
  }
};

// Rate limiter middleware
export const rateLimiter = (type: keyof typeof rateLimits) => {
  return rateLimit({
    ...rateLimits[type],
    standardHeaders: true,
    legacyHeaders: false,
    handler: (req, res) => {
      res.status(429).json({
        error: 'Too many requests'
      });
    }
  });
};
```

## Health Checks

```typescript
// Health check endpoints
app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.get('/health/live', (req, res) => {
  res.json({ status: 'alive' });
});

app.get('/health/ready', async (req, res) => {
  const checks = await Promise.all([
    checkDatabase(),
    checkRedis(),
    checkMessageBus()
  ]);
  
  const ready = checks.every(c => c);
  
  res.status(ready ? 200 : 503).json({
    status: ready ? 'ready' : 'not ready',
    checks: {
      database: checks[0],
      redis: checks[1],
      messageBus: checks[2]
    }
  });
});
```

---

*Backend Architecture Version 1.0 - Created 2025-08-28*