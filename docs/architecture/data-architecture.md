# Data Architecture

## Overview

The data architecture implements a multi-layer strategy with PostgreSQL for transactional data, Redis for caching, and Azure Blob Storage for archival. The design emphasizes performance, scalability, and data integrity.

## Database Schema

### Core Domain Tables

```sql
-- Users and Authentication
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'user',
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_login_at TIMESTAMPTZ
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role) WHERE is_active = true;

-- Formulas
CREATE TABLE formulas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    definition JSONB NOT NULL,
    is_template BOOLEAN DEFAULT FALSE,
    is_public BOOLEAN DEFAULT FALSE,
    version INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_user_formula_name UNIQUE(user_id, name)
);

CREATE INDEX idx_formulas_user_id ON formulas(user_id);
CREATE INDEX idx_formulas_is_template ON formulas(is_template) WHERE is_template = true;
CREATE INDEX idx_formulas_is_public ON formulas(is_public) WHERE is_public = true;

-- Formula Metrics (denormalized for performance)
CREATE TABLE formula_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    formula_id UUID REFERENCES formulas(id) ON DELETE CASCADE,
    metric_id UUID REFERENCES metrics(id),
    weight DECIMAL(5,2) CHECK (weight >= 0 AND weight <= 100),
    parameters JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_formula_metrics_formula ON formula_metrics(formula_id);
```

### AFL Data Tables

```sql
-- Teams
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    abbreviation VARCHAR(4) NOT NULL UNIQUE,
    home_ground VARCHAR(100),
    state VARCHAR(3),
    founded_year INTEGER,
    colors JSONB,
    logo_url VARCHAR(500),
    is_active BOOLEAN DEFAULT true
);

-- Venues
CREATE TABLE venues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    state VARCHAR(3),
    capacity INTEGER,
    surface_type VARCHAR(20),
    dimensions JSONB,
    timezone VARCHAR(50)
);

-- Seasons
CREATE TABLE seasons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    rounds_count INTEGER,
    is_current BOOLEAN DEFAULT false
);

-- Rounds
CREATE TABLE rounds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    season_id UUID REFERENCES seasons(id),
    round_number INTEGER NOT NULL,
    name VARCHAR(50),
    start_date DATE,
    end_date DATE,
    is_finals BOOLEAN DEFAULT false,
    CONSTRAINT unique_season_round UNIQUE(season_id, round_number)
);

-- Matches
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    round_id UUID REFERENCES rounds(id),
    home_team_id UUID REFERENCES teams(id),
    away_team_id UUID REFERENCES teams(id),
    venue_id UUID REFERENCES venues(id),
    scheduled_at TIMESTAMPTZ NOT NULL,
    actual_start_at TIMESTAMPTZ,
    home_score INTEGER,
    away_score INTEGER,
    home_goals INTEGER,
    home_behinds INTEGER,
    away_goals INTEGER,
    away_behinds INTEGER,
    status VARCHAR(20) DEFAULT 'scheduled',
    weather_conditions JSONB,
    attendance INTEGER,
    broadcast_info JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT check_different_teams CHECK (home_team_id != away_team_id)
);

CREATE INDEX idx_matches_scheduled ON matches(scheduled_at);
CREATE INDEX idx_matches_round ON matches(round_id);
CREATE INDEX idx_matches_teams ON matches(home_team_id, away_team_id);
CREATE INDEX idx_matches_status ON matches(status);
```

### Statistics Tables

```sql
-- Match Statistics
CREATE TABLE match_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id),
    disposals INTEGER,
    marks INTEGER,
    tackles INTEGER,
    hitouts INTEGER,
    clearances INTEGER,
    contested_possessions INTEGER,
    uncontested_possessions INTEGER,
    inside_50s INTEGER,
    rebound_50s INTEGER,
    turnovers INTEGER,
    intercepts INTEGER,
    pressure_acts INTEGER,
    metres_gained INTEGER,
    accuracy_percentage DECIMAL(5,2),
    time_in_forward_half DECIMAL(5,2),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_match_team_stats UNIQUE(match_id, team_id)
);

CREATE INDEX idx_match_stats_match ON match_stats(match_id);
CREATE INDEX idx_match_stats_team ON match_stats(team_id);

-- Aggregated Team Statistics (materialized view)
CREATE MATERIALIZED VIEW team_season_stats AS
SELECT 
    t.id as team_id,
    s.id as season_id,
    COUNT(DISTINCT m.id) as matches_played,
    SUM(CASE 
        WHEN (m.home_team_id = t.id AND m.home_score > m.away_score) 
          OR (m.away_team_id = t.id AND m.away_score > m.home_score) 
        THEN 1 ELSE 0 
    END) as wins,
    AVG(ms.disposals) as avg_disposals,
    AVG(ms.marks) as avg_marks,
    AVG(ms.tackles) as avg_tackles,
    AVG(ms.inside_50s) as avg_inside_50s,
    AVG(ms.accuracy_percentage) as avg_accuracy
FROM teams t
JOIN match_stats ms ON ms.team_id = t.id
JOIN matches m ON ms.match_id = m.id
JOIN rounds r ON m.round_id = r.id
JOIN seasons s ON r.season_id = s.id
GROUP BY t.id, s.id;

CREATE INDEX idx_team_season_stats ON team_season_stats(team_id, season_id);
```

### Prediction Tables

```sql
-- Predictions
CREATE TABLE predictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    formula_id UUID REFERENCES formulas(id) ON DELETE CASCADE,
    match_id UUID REFERENCES matches(id),
    user_id UUID REFERENCES users(id),
    predicted_winner_id UUID REFERENCES teams(id),
    predicted_margin DECIMAL(5,1),
    confidence DECIMAL(5,2) CHECK (confidence >= 0 AND confidence <= 100),
    calculation_details JSONB,
    is_correct BOOLEAN,
    points_earned DECIMAL(5,2),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_predictions_formula_match ON predictions(formula_id, match_id);
CREATE INDEX idx_predictions_user ON predictions(user_id);
CREATE INDEX idx_predictions_created ON predictions(created_at DESC);

-- Backtest Results
CREATE TABLE backtest_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    formula_id UUID REFERENCES formulas(id) ON DELETE CASCADE,
    season_id UUID REFERENCES seasons(id),
    total_matches INTEGER,
    correct_predictions INTEGER,
    accuracy_percentage DECIMAL(5,2),
    average_confidence DECIMAL(5,2),
    profit_loss DECIMAL(10,2),
    detailed_results JSONB,
    execution_time_ms INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_backtest_formula ON backtest_results(formula_id);
CREATE INDEX idx_backtest_season ON backtest_results(season_id);
```

## Caching Strategy

### Cache Layers

```typescript
// Multi-layer caching configuration
const cacheConfig = {
  layers: [
    {
      name: 'L1-Memory',
      type: 'LRU',
      maxSize: '100MB',
      ttl: 60, // seconds
      targets: ['formulas', 'user-session']
    },
    {
      name: 'L2-Redis',
      type: 'Redis',
      ttl: 3600, // 1 hour
      targets: ['predictions', 'calculations', 'api-responses']
    },
    {
      name: 'L3-CDN',
      type: 'Azure-FrontDoor',
      ttl: 86400, // 24 hours
      targets: ['static-assets', 'team-data', 'historical-stats']
    }
  ],
  
  invalidation: {
    strategies: [
      'time-based',      // TTL expiration
      'event-driven',    // On data updates
      'manual-purge'     // Admin triggered
    ]
  }
};
```

### Redis Cache Structure

```typescript
// Cache key patterns
const cacheKeys = {
  // User-specific caches
  userFormulas: (userId: string) => 
    `user:${userId}:formulas`,
  userPredictions: (userId: string, round?: number) => 
    `user:${userId}:predictions${round ? `:round:${round}` : ''}`,
  
  // Formula caches
  formula: (id: string) => 
    `formula:${id}`,
  formulaTemplates: () => 
    'formulas:templates',
  
  // Match and team data
  match: (id: string) => 
    `match:${id}`,
  teamStats: (teamId: string, season: number) => 
    `team:${teamId}:stats:${season}`,
  roundMatches: (round: number) => 
    `round:${round}:matches`,
  
  // Calculations
  predictionCalc: (formulaId: string, matchId: string) => 
    `calc:${formulaId}:${matchId}`,
  backtestResult: (formulaId: string, season: number) => 
    `backtest:${formulaId}:${season}`,
  
  // Session data
  session: (sessionId: string) => 
    `session:${sessionId}`,
  
  // Rate limiting
  rateLimit: (ip: string, endpoint: string) => 
    `rate:${ip}:${endpoint}`
};

// Cache TTL configuration (seconds)
const cacheTTL = {
  userFormulas: 300,      // 5 minutes
  formula: 3600,          // 1 hour
  teamStats: 86400,       // 24 hours
  match: 300,             // 5 minutes (live)
  matchCompleted: 604800, // 7 days (completed)
  predictions: 60,        // 1 minute
  backtest: 3600,         // 1 hour
  session: 900,           // 15 minutes
  rateLimit: 60           // 1 minute
};
```

## Data Pipeline

### Ingestion Pipeline

```yaml
Data Sources:
  Squiggle API:
    schedule: "*/5 * * * *"  # Every 5 minutes during matches
    endpoints:
      - /games
      - /standings
      - /tips
    rate_limit: 100/minute
    
  AFL Tables:
    schedule: "0 */6 * * *"  # Every 6 hours
    pages:
      - /stats/teams
      - /stats/players
      - /ladder
    rate_limit: 10/minute
    
Data Flow:
  1. Fetch:
     - HTTP requests with retry
     - Rate limiting
     - Error handling
     
  2. Validate:
     - Schema validation (Zod)
     - Data completeness checks
     - Anomaly detection
     
  3. Transform:
     - Normalize team names
     - Calculate derived metrics
     - Aggregate statistics
     
  4. Load:
     - Upsert to PostgreSQL
     - Update Redis cache
     - Publish events
```

### ETL Process

```typescript
class DataPipeline {
  async process(): Promise<void> {
    // Extract
    const rawData = await this.extract();
    
    // Transform
    const transformedData = await this.transform(rawData);
    
    // Load
    await this.load(transformedData);
    
    // Post-processing
    await this.postProcess();
  }
  
  private async extract(): Promise<RawData[]> {
    const sources = [
      this.fetchSquiggleData(),
      this.scrapeAFLTables()
    ];
    
    return Promise.all(sources);
  }
  
  private async transform(data: RawData[]): Promise<TransformedData> {
    return {
      matches: this.transformMatches(data),
      stats: this.calculateStats(data),
      metrics: this.deriveMetrics(data)
    };
  }
  
  private async load(data: TransformedData): Promise<void> {
    await this.db.transaction(async (tx) => {
      await tx.matches.upsert(data.matches);
      await tx.stats.upsert(data.stats);
      await tx.metrics.upsert(data.metrics);
    });
    
    // Invalidate affected caches
    await this.cache.invalidate('match:*');
    await this.cache.invalidate('team:*:stats:*');
  }
}
```

## Data Storage Tiers

```yaml
Hot Storage (Redis):
  - Current round matches
  - Live predictions
  - Active user sessions
  - Real-time calculations
  Retention: 24-48 hours
  Size: ~5GB
  
Warm Storage (PostgreSQL):
  - Current season data
  - Last 2 seasons history
  - User data and formulas
  - Recent predictions
  Retention: 2 years
  Size: ~50GB
  
Cold Storage (Blob Storage):
  - Historical seasons (3+ years)
  - Archived predictions
  - Backtest results
  - Audit logs
  Retention: Indefinite
  Size: ~500GB
  Compression: gzip
```

## Data Integrity

### Constraints and Validations

```sql
-- Check constraints
ALTER TABLE formulas 
  ADD CONSTRAINT check_metric_count 
  CHECK (jsonb_array_length(definition->'metrics') <= 10);

ALTER TABLE predictions
  ADD CONSTRAINT check_confidence_range
  CHECK (confidence >= 0 AND confidence <= 100);

-- Triggers for data integrity
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_formulas_updated_at
  BEFORE UPDATE ON formulas
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Audit trail
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name VARCHAR(50),
  operation VARCHAR(10),
  user_id UUID,
  old_data JSONB,
  new_data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_log (table_name, operation, user_id, old_data, new_data)
  VALUES (
    TG_TABLE_NAME,
    TG_OP,
    current_setting('app.user_id', true)::UUID,
    to_jsonb(OLD),
    to_jsonb(NEW)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## Query Optimization

### Indexing Strategy

```sql
-- Composite indexes for common queries
CREATE INDEX idx_predictions_user_round 
  ON predictions(user_id, created_at DESC) 
  WHERE is_correct IS NOT NULL;

CREATE INDEX idx_matches_upcoming 
  ON matches(scheduled_at) 
  WHERE status = 'scheduled';

CREATE INDEX idx_formulas_popular 
  ON formulas(is_public, created_at DESC) 
  WHERE is_public = true;

-- Partial indexes for performance
CREATE INDEX idx_active_users 
  ON users(email) 
  WHERE is_active = true;

-- JSONB indexes
CREATE INDEX idx_formula_metrics 
  ON formulas USING gin (definition->'metrics');

CREATE INDEX idx_match_weather 
  ON matches USING gin (weather_conditions);
```

### Query Performance

```typescript
// Optimized queries examples
class OptimizedQueries {
  // Use prepared statements
  async getUserFormulas(userId: string) {
    return this.db.$queryRaw`
      SELECT f.*, 
             COUNT(p.id) as prediction_count,
             AVG(p.confidence) as avg_confidence
      FROM formulas f
      LEFT JOIN predictions p ON p.formula_id = f.id
      WHERE f.user_id = ${userId}
      GROUP BY f.id
      ORDER BY f.updated_at DESC
      LIMIT 20
    `;
  }
  
  // Batch operations
  async batchInsertPredictions(predictions: Prediction[]) {
    return this.db.$transaction(
      predictions.map(p => 
        this.db.predictions.create({ data: p })
      )
    );
  }
  
  // Use materialized views
  async getTeamStats(teamId: string, season: number) {
    return this.db.$queryRaw`
      SELECT * FROM team_season_stats
      WHERE team_id = ${teamId} 
        AND season_id = ${season}
    `;
  }
}
```

## Data Migration Strategy

```yaml
Migration Approach:
  1. Schema Migrations:
     Tool: Prisma Migrate
     Strategy: Forward-only migrations
     Rollback: New migration to revert
     
  2. Data Migrations:
     Tool: Custom scripts
     Strategy: Idempotent operations
     Testing: Dry-run on staging
     
  3. Zero-Downtime Migrations:
     - Add new column (nullable)
     - Backfill data
     - Update application code
     - Make column required
     - Remove old column
```

## Backup and Recovery

```yaml
Backup Strategy:
  PostgreSQL:
    Type: Continuous replication
    Frequency: Real-time
    Retention: 30 days
    Point-in-time: 7 days
    
  Redis:
    Type: RDB snapshots
    Frequency: Every 6 hours
    Retention: 7 days
    
  Blob Storage:
    Type: Geo-redundant storage
    Replication: 3 copies
    Durability: 99.999999999%

Recovery Procedures:
  RTO: 1 hour
  RPO: 5 minutes
  
  Steps:
    1. Identify failure point
    2. Stop application traffic
    3. Restore from backup
    4. Validate data integrity
    5. Resume traffic
    6. Monitor for issues
```

---

*Data Architecture Version 1.0 - Created 2025-08-28*