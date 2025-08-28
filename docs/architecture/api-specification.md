# API Specification

## Overview

This document defines all REST API endpoints, request/response formats, and future GraphQL schema for the AFL Data Capture Platform.

## API Standards

### Base URL Structure
```
Production: https://api.afl-predictor.com/v1
Staging: https://staging-api.afl-predictor.com/v1
Development: http://localhost:3001/api/v1
```

### Request Standards

```typescript
// Standard request headers
{
  "Content-Type": "application/json",
  "Accept": "application/json",
  "Authorization": "Bearer {token}",
  "X-Request-ID": "uuid-v4",
  "X-API-Version": "v1"
}

// Standard query parameters
{
  "page": 1,            // Pagination: page number
  "limit": 20,          // Pagination: items per page
  "sort": "field",      // Sorting: field name
  "order": "asc|desc",  // Sorting: direction
  "filter": "query"     // Filtering: search query
}
```

### Response Standards

```typescript
// Success response
{
  "success": true,
  "data": { /* Response data */ },
  "meta": {
    "timestamp": "2025-08-28T10:00:00Z",
    "requestId": "uuid-v4",
    "version": "v1"
  }
}

// Error response
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": { /* Additional error context */ },
    "timestamp": "2025-08-28T10:00:00Z",
    "requestId": "uuid-v4"
  }
}

// Paginated response
{
  "success": true,
  "data": [ /* Array of items */ ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "pages": 5,
    "hasNext": true,
    "hasPrev": false
  },
  "meta": { /* Standard meta */ }
}
```

## Authentication Endpoints

### POST /api/auth/register
Register a new user account.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecureP@ssw0rd!",
  "name": "John Doe",
  "acceptTerms": true
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "John Doe",
      "role": "user",
      "createdAt": "2025-08-28T10:00:00Z"
    },
    "tokens": {
      "accessToken": "jwt-access-token",
      "refreshToken": "jwt-refresh-token",
      "expiresIn": 900
    }
  }
}
```

### POST /api/auth/login
Authenticate user and receive tokens.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecureP@ssw0rd!"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "John Doe",
      "role": "user"
    },
    "tokens": {
      "accessToken": "jwt-access-token",
      "refreshToken": "jwt-refresh-token",
      "expiresIn": 900
    }
  }
}
```

### POST /api/auth/refresh
Refresh access token using refresh token.

**Request:**
```json
{
  "refreshToken": "jwt-refresh-token"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "accessToken": "new-jwt-access-token",
    "expiresIn": 900
  }
}
```

### POST /api/auth/logout
Invalidate refresh token.

**Request:**
```json
{
  "refreshToken": "jwt-refresh-token"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

## Formula Endpoints

### GET /api/formulas
List user's formulas.

**Query Parameters:**
- `page` (number): Page number (default: 1)
- `limit` (number): Items per page (default: 20)
- `sort` (string): Sort field (createdAt, updatedAt, name)
- `order` (string): Sort order (asc, desc)

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "My Formula",
      "description": "Formula description",
      "metrics": [
        {
          "metricId": "uuid",
          "name": "Recent Form",
          "weight": 75
        }
      ],
      "isPublic": false,
      "isTemplate": false,
      "createdAt": "2025-08-28T10:00:00Z",
      "updatedAt": "2025-08-28T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 5,
    "pages": 1
  }
}
```

### POST /api/formulas
Create a new formula.

**Request:**
```json
{
  "name": "My Formula",
  "description": "A balanced formula",
  "metrics": [
    {
      "metricId": "uuid",
      "weight": 75
    },
    {
      "metricId": "uuid",
      "weight": 25
    }
  ],
  "isPublic": false
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "My Formula",
    "description": "A balanced formula",
    "metrics": [ /* ... */ ],
    "isPublic": false,
    "createdAt": "2025-08-28T10:00:00Z"
  }
}
```

### GET /api/formulas/{id}
Get a specific formula.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "My Formula",
    "description": "A balanced formula",
    "metrics": [ /* Full metric details */ ],
    "statistics": {
      "predictionsCount": 50,
      "accuracy": 62.5,
      "lastUsed": "2025-08-28T09:00:00Z"
    }
  }
}
```

### PUT /api/formulas/{id}
Update a formula.

**Request:**
```json
{
  "name": "Updated Formula",
  "description": "Updated description",
  "metrics": [ /* Updated metrics */ ]
}
```

**Response (200):**
```json
{
  "success": true,
  "data": { /* Updated formula */ }
}
```

### DELETE /api/formulas/{id}
Delete a formula.

**Response (204):**
No content

### POST /api/formulas/{id}/duplicate
Clone a formula.

**Request:**
```json
{
  "name": "Cloned Formula"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": { /* New formula */ }
}
```

### GET /api/formulas/templates
Get formula templates.

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Defensive Focus",
      "description": "Emphasizes defensive metrics",
      "metrics": [ /* ... */ ],
      "category": "defensive"
    }
  ]
}
```

## Prediction Endpoints

### POST /api/predictions/generate
Generate predictions for matches.

**Request:**
```json
{
  "formulaId": "uuid",
  "matchIds": ["uuid1", "uuid2"],
  "round": 15
}
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "matchId": "uuid",
      "match": {
        "homeTeam": "Richmond",
        "awayTeam": "Carlton",
        "venue": "MCG",
        "scheduledAt": "2025-08-28T14:00:00Z"
      },
      "predictedWinner": "Richmond",
      "predictedMargin": 15.5,
      "confidence": 72.3,
      "calculationDetails": [
        {
          "metric": "Recent Form",
          "value": 0.8,
          "weight": 75,
          "contribution": 60
        }
      ]
    }
  ]
}
```

### GET /api/predictions
Get user's predictions.

**Query Parameters:**
- `round` (number): Filter by round
- `formulaId` (string): Filter by formula
- `correct` (boolean): Filter by correctness
- `page`, `limit`, `sort`, `order`: Pagination

**Response (200):**
```json
{
  "success": true,
  "data": [ /* Predictions array */ ],
  "pagination": { /* ... */ }
}
```

### GET /api/predictions/{id}
Get specific prediction details.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "formula": { /* Formula details */ },
    "match": { /* Match details */ },
    "predictedWinner": "Richmond",
    "predictedMargin": 15.5,
    "confidence": 72.3,
    "actualWinner": "Richmond",
    "actualMargin": 22,
    "correct": true,
    "points": 4,
    "calculationDetails": [ /* ... */ ]
  }
}
```

### GET /api/predictions/round/{number}
Get predictions for a specific round.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "round": 15,
    "matches": [ /* Matches with predictions */ ],
    "summary": {
      "totalPredictions": 9,
      "averageConfidence": 68.5
    }
  }
}
```

## Backtest Endpoints

### POST /api/backtest/run
Run backtest for a formula.

**Request:**
```json
{
  "formulaId": "uuid",
  "seasons": [2023, 2024],
  "options": {
    "includeFinales": true,
    "minConfidence": 60
  }
}
```

**Response (202):**
```json
{
  "success": true,
  "data": {
    "backtestId": "uuid",
    "status": "processing",
    "estimatedTime": 30
  }
}
```

### GET /api/backtest/{id}
Get backtest results.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "formulaId": "uuid",
    "seasons": [2023, 2024],
    "summary": {
      "totalMatches": 396,
      "correctPredictions": 238,
      "accuracy": 60.1,
      "averageConfidence": 65.3,
      "profitLoss": 125.50
    },
    "seasonBreakdown": [
      {
        "season": 2023,
        "matches": 198,
        "correct": 115,
        "accuracy": 58.1
      }
    ],
    "roundBreakdown": [ /* ... */ ],
    "teamPerformance": [ /* ... */ ]
  }
}
```

## Match Data Endpoints

### GET /api/matches
Get matches list.

**Query Parameters:**
- `round` (number): Filter by round
- `team` (string): Filter by team
- `status` (string): scheduled, completed, live
- `date` (string): Filter by date (YYYY-MM-DD)

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "round": 15,
      "homeTeam": {
        "id": "uuid",
        "name": "Richmond",
        "abbreviation": "RICH"
      },
      "awayTeam": {
        "id": "uuid",
        "name": "Carlton",
        "abbreviation": "CARL"
      },
      "venue": {
        "name": "MCG",
        "city": "Melbourne"
      },
      "scheduledAt": "2025-08-28T14:00:00Z",
      "status": "scheduled"
    }
  ]
}
```

### GET /api/matches/{id}
Get match details with statistics.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "round": 15,
    "homeTeam": { /* Full team details */ },
    "awayTeam": { /* Full team details */ },
    "venue": { /* Venue details */ },
    "scheduledAt": "2025-08-28T14:00:00Z",
    "status": "completed",
    "score": {
      "home": 95,
      "away": 73
    },
    "statistics": {
      "home": {
        "disposals": 385,
        "marks": 95,
        "tackles": 68,
        "inside50s": 52
      },
      "away": { /* ... */ }
    },
    "weather": {
      "temperature": 18,
      "conditions": "clear"
    }
  }
}
```

## Team Endpoints

### GET /api/teams
Get all teams.

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Richmond",
      "abbreviation": "RICH",
      "homeGround": "MCG",
      "state": "VIC",
      "founded": 1885,
      "colors": ["yellow", "black"],
      "logoUrl": "https://..."
    }
  ]
}
```

### GET /api/teams/{id}/stats
Get team statistics.

**Query Parameters:**
- `season` (number): Season year (default: current)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "team": { /* Team details */ },
    "season": 2025,
    "statistics": {
      "wins": 12,
      "losses": 6,
      "draws": 0,
      "percentage": 115.5,
      "averageScore": 85.3,
      "averageAgainst": 73.8,
      "form": "WWLWW"
    },
    "rankings": {
      "ladder": 4,
      "offense": 6,
      "defense": 3
    }
  }
}
```

## User Endpoints

### GET /api/users/profile
Get current user profile.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "John Doe",
    "role": "premium",
    "statistics": {
      "formulasCount": 5,
      "predictionsCount": 150,
      "accuracy": 58.5,
      "ranking": 234
    },
    "preferences": {
      "favoriteTeam": "Richmond",
      "emailNotifications": true
    },
    "createdAt": "2025-01-01T00:00:00Z"
  }
}
```

### PUT /api/users/profile
Update user profile.

**Request:**
```json
{
  "name": "John Smith",
  "preferences": {
    "favoriteTeam": "Carlton",
    "emailNotifications": false
  }
}
```

**Response (200):**
```json
{
  "success": true,
  "data": { /* Updated profile */ }
}
```

## WebSocket Events

### Connection
```javascript
const ws = new WebSocket('wss://api.afl-predictor.com/ws');

ws.on('connect', () => {
  // Authenticate
  ws.send(JSON.stringify({
    type: 'auth',
    token: 'jwt-token'
  }));
  
  // Subscribe to events
  ws.send(JSON.stringify({
    type: 'subscribe',
    channels: ['matches', 'predictions']
  }));
});
```

### Event Types

```typescript
// Match update
{
  "type": "match.update",
  "data": {
    "matchId": "uuid",
    "status": "live",
    "score": {
      "home": 45,
      "away": 38
    }
  }
}

// Prediction result
{
  "type": "prediction.result",
  "data": {
    "predictionId": "uuid",
    "correct": true,
    "points": 4
  }
}

// System notification
{
  "type": "system.notification",
  "data": {
    "message": "Round 15 matches are now available",
    "priority": "info"
  }
}
```

## Error Codes

| Code | Description | HTTP Status |
|------|-------------|-------------|
| `AUTH_REQUIRED` | Authentication required | 401 |
| `AUTH_INVALID` | Invalid credentials | 401 |
| `TOKEN_EXPIRED` | JWT token expired | 401 |
| `FORBIDDEN` | Insufficient permissions | 403 |
| `NOT_FOUND` | Resource not found | 404 |
| `VALIDATION_ERROR` | Input validation failed | 400 |
| `RATE_LIMIT` | Rate limit exceeded | 429 |
| `SERVER_ERROR` | Internal server error | 500 |
| `SERVICE_UNAVAILABLE` | Service temporarily unavailable | 503 |

## Rate Limits

| Endpoint | Limit | Window |
|----------|-------|--------|
| Authentication | 5 requests | 15 minutes |
| API (Free) | 60 requests | 1 minute |
| API (Premium) | 200 requests | 1 minute |
| Predictions | 100 requests | 1 hour |
| Backtest | 10 requests | 1 hour |

## GraphQL Schema (Future)

```graphql
type Query {
  # User queries
  me: User
  user(id: ID!): User
  
  # Formula queries
  formula(id: ID!): Formula
  formulas(filter: FormulaFilter, pagination: PaginationInput): FormulaConnection
  formulaTemplates: [Formula!]!
  
  # Prediction queries
  prediction(id: ID!): Prediction
  predictions(filter: PredictionFilter, pagination: PaginationInput): PredictionConnection
  
  # Match queries
  match(id: ID!): Match
  matches(round: Int, team: ID, status: MatchStatus): [Match!]!
  
  # Team queries
  team(id: ID!): Team
  teams: [Team!]!
  teamStats(teamId: ID!, season: Int): TeamStatistics
}

type Mutation {
  # Auth mutations
  register(input: RegisterInput!): AuthPayload!
  login(input: LoginInput!): AuthPayload!
  refresh(refreshToken: String!): TokenPayload!
  logout(refreshToken: String!): Boolean!
  
  # Formula mutations
  createFormula(input: FormulaInput!): Formula!
  updateFormula(id: ID!, input: FormulaInput!): Formula!
  deleteFormula(id: ID!): Boolean!
  duplicateFormula(id: ID!, name: String!): Formula!
  
  # Prediction mutations
  generatePredictions(input: GeneratePredictionsInput!): [Prediction!]!
  
  # Backtest mutations
  runBacktest(input: BacktestInput!): BacktestJob!
}

type Subscription {
  # Live match updates
  matchUpdate(matchId: ID!): MatchUpdate!
  
  # Prediction results
  predictionResult(userId: ID!): PredictionResult!
  
  # System notifications
  systemNotification: Notification!
}
```

---

*API Specification Version 1.0 - Created 2025-08-28*