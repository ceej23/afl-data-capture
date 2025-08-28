# Epic 2: Data Pipeline & Integration

## Epic Overview
**Goal:** Build robust data ingestion pipeline integrating Squiggle API and AFL Tables to provide real-time AFL data for predictions.

**Key Deliverable:** Real AFL data flowing into the platform with automatic updates after each round.

**Requirements Coverage:** FR9, FR10, NFR13, NFR14, Data Privacy & Compliance, Monitoring & Observability

**Dependencies:** Epic 1 (requires formula engine to process data)

**Estimated Duration:** 2 weeks

## Success Criteria
- [ ] Squiggle API integration functioning with rate limiting
- [ ] AFL Tables scraper operational with >95% success rate
- [ ] Data transformation layer unifying both sources
- [ ] Real-time predictions using current season data
- [ ] Data freshness <48 hours for all sources
- [ ] Monitoring dashboard showing data pipeline health

## Story Breakdown

### Story 2.1: Squiggle API Integration
**Priority:** P0  
**Points:** 5  
**Dependencies:** Epic 1 completion

**As a** system  
**I want** to fetch real-time AFL data from Squiggle API  
**So that** predictions use current and accurate information

#### Acceptance Criteria
- [ ] Implement Squiggle API client with TypeScript types
- [ ] Configure API authentication with proper User-Agent header
- [ ] Fetch fixtures data: `/api/?q=games&year={year}`
- [ ] Fetch standings data: `/api/?q=standings&year={year}`
- [ ] Fetch tips data: `/api/?q=tips&year={year}&round={round}`
- [ ] Implement rate limiting (100 requests per minute)
- [ ] Set up retry logic with exponential backoff
- [ ] Cache responses in Redis with 1-hour TTL
- [ ] Handle API errors gracefully with fallback to cache
- [ ] Log all API interactions for monitoring
- [ ] Create health check endpoint for API status
- [ ] Document API response schemas

#### Technical Notes
- Use Axios with interceptors for common headers
- Implement circuit breaker pattern for failures
- Store API responses in normalized format
- Use Bull MQ for scheduled data fetching

---

### Story 2.2: AFL Tables Data Scraping
**Priority:** P0  
**Points:** 5  
**Dependencies:** Epic 1 completion

**As a** system  
**I want** to scrape historical statistics from AFL Tables  
**So that** backtesting has comprehensive historical data

#### Acceptance Criteria
- [ ] Build scraper using Puppeteer/Playwright
- [ ] Extract team statistics for last 5 seasons
- [ ] Extract player statistics (anonymized)
- [ ] Parse match results and scores
- [ ] Implement polite scraping (2-second delays)
- [ ] Handle pagination and dynamic content
- [ ] Detect and handle anti-scraping measures
- [ ] Store raw HTML for audit trail
- [ ] Transform scraped data to standard format
- [ ] Success rate monitoring (target >95%)
- [ ] Implement manual trigger for failed scrapes
- [ ] Create data quality validation rules

#### Technical Notes
- Use Playwright for reliable scraping
- Implement checksum validation for data integrity
- Store screenshots on scraping failures
- Run scraper on schedule via cron jobs

---

### Story 2.3: Data Transformation Layer
**Priority:** P0  
**Points:** 3  
**Dependencies:** Stories 2.1, 2.2

**As a** system  
**I want** to unify data from multiple sources  
**So that** the application has consistent data format

#### Acceptance Criteria
- [ ] Create unified data model for all sources
- [ ] Map Squiggle API fields to standard schema
- [ ] Map AFL Tables fields to standard schema
- [ ] Handle missing data with sensible defaults
- [ ] Implement data validation rules
- [ ] Create data quality scoring system
- [ ] Log transformation errors and anomalies
- [ ] Support incremental updates
- [ ] Implement conflict resolution for conflicting data
- [ ] Create data lineage tracking
- [ ] Document transformation rules

#### Technical Notes
- Use Zod for schema validation
- Implement ETL pipeline with clear stages
- Store transformation logs for debugging
- Create data dictionary documentation

---

### Story 2.4: Real-Time Predictions Generator
**Priority:** P0  
**Points:** 5  
**Dependencies:** Story 2.3

**As a** user  
**I want** to generate predictions for the upcoming round  
**So that** I can use them in tipping competitions

#### Acceptance Criteria
- [ ] Fetch current round fixtures automatically
- [ ] Generate predictions for all matches in round
- [ ] Complete generation in <3s for 9 games
- [ ] Display team logos and venue information
- [ ] Show match date/time in user's timezone
- [ ] Calculate and display confidence scores
- [ ] Support CSV export of predictions
- [ ] Enable sharing via URL or image
- [ ] Handle postponed/cancelled matches
- [ ] Update when fixture changes occur
- [ ] Cache predictions with smart invalidation

#### Technical Notes
- Use server-side generation for performance
- Implement optimistic UI updates
- Create shareable prediction images
- Use React Query for data fetching

---

### Story 2.5: Current Season Statistics
**Priority:** P1  
**Points:** 3  
**Dependencies:** Stories 2.1, 2.2

**As a** formula builder  
**I want** access to current season statistics  
**So that** my formulas use up-to-date performance data

#### Acceptance Criteria
- [ ] Calculate form (last 5 games) after each round
- [ ] Update head-to-head records
- [ ] Calculate home/away performance stats
- [ ] Track injury list impacts
- [ ] Monitor travel distances
- [ ] Calculate rolling averages for all metrics
- [ ] Update within 24 hours of match completion
- [ ] Show data freshness indicators
- [ ] Highlight significant changes
- [ ] Create season progression visualizations

#### Technical Notes
- Use materialized views for performance
- Implement incremental calculation updates
- Cache calculated statistics aggressively
- Create background jobs for updates

---

### Story 2.6: Data Quality Monitoring
**Priority:** P1  
**Points:** 3  
**Dependencies:** Stories 2.1-2.5

**As a** system administrator  
**I want** to monitor data pipeline health  
**So that** data issues are detected and resolved quickly

#### Acceptance Criteria
- [ ] Create monitoring dashboard with key metrics
- [ ] Track API success rates and latencies
- [ ] Monitor scraper success rates
- [ ] Alert on data staleness (>48 hours)
- [ ] Detect anomalous data values
- [ ] Track data completeness percentages
- [ ] Log all data pipeline events
- [ ] Implement automated data quality tests
- [ ] Create manual data refresh triggers
- [ ] Generate daily quality reports
- [ ] Set up PagerDuty integration for critical alerts

#### Technical Notes
- Use Application Insights for monitoring
- Create Grafana dashboards for visualization
- Implement health check endpoints
- Use structured logging for analysis

## Testing Requirements

### Unit Tests
- API client methods
- Data transformation functions
- Validation rules
- Cache operations

### Integration Tests
- End-to-end data pipeline flow
- API integration with mocked responses
- Scraper with test HTML fixtures
- Database operations

### E2E Tests
- Complete data refresh cycle
- Prediction generation with real data
- Export functionality
- Error recovery scenarios

## Documentation Deliverables
- [ ] API integration guide
- [ ] Data model documentation
- [ ] Transformation rules catalog
- [ ] Monitoring runbook
- [ ] Data quality standards

## Risk Mitigation
- **Risk:** Squiggle API becomes unavailable
  - **Mitigation:** Implement comprehensive caching and fallback data
- **Risk:** AFL Tables blocks scraping
  - **Mitigation:** Implement multiple scraping strategies and manual fallback
- **Risk:** Data inconsistencies between sources
  - **Mitigation:** Define clear precedence rules and validation

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Test coverage >85% for data pipeline
- [ ] Data quality metrics meeting targets
- [ ] Monitoring dashboard operational
- [ ] Documentation complete
- [ ] Performance benchmarks met
- [ ] Security review passed
- [ ] Product owner sign-off received