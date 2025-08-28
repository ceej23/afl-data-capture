# User-Driven Sports Prediction Platform Product Requirements Document (PRD)

## Goals and Background Context

### Goals

- **Enable users to create custom prediction formulas** through visual drag-and-drop interface without coding knowledge
- **Achieve 55%+ average prediction accuracy** demonstrating formulas beat random selection (50% baseline)  
- **Launch MVP with 1,000 users in 60 days** validating market demand for user-controlled predictions
- **Establish formula creation as core differentiator** before competitors recognize the opportunity
- **Prove technical feasibility** of formula builder that scales to 10,000 concurrent users
- **Generate first revenue** through freemium conversions at 15-20% rate
- **Build foundation for formula marketplace** enabling network effects in Phase 2

### Background Context

The sports prediction market is ripe for disruption. While millions participate in tipping competitions and the AI sports analytics market grows at 29.8% CAGR, users are trapped between black-box algorithms they don't trust and manual guessing without validation tools. Our research reveals zero competitors offering visual formula builders with marketplace capabilities - we're creating an entirely new category: "Democratized Prediction Formula Building."

This PRD focuses on proving the core hypothesis that users want to build, test, and control their own prediction logic. By starting with AFL (1M+ FootyTips users) and free data sources, we can validate demand with minimal investment before scaling to multiple sports and premium features. The MVP deliberately excludes the marketplace to focus on proving that user-built formulas can deliver value, setting the foundation for network effects once we have critical mass.

### Change Log

| Date | Version | Description | Author |
|------|---------|-------------|---------|
| 2025-08-28 | 1.0 | Initial PRD created from Project Brief | John (PM) |
| 2025-08-28 | 2.0 | Major restructuring to consolidate scattered requirements | Chris |

## Requirements

### Functional Requirements (FR)

| ID | Requirement | Priority |
|----|-------------|----------|
| FR1 | Visual drag-and-drop interface for building prediction formulas | P0 |
| FR2 | Select from 20+ AFL metrics (form, H2H, home advantage, weather, etc.) | P0 |
| FR3 | Define metric relationships through visual sliders (0-100% influence) | P0 |
| FR4 | Save up to 5 custom formulas per user (consistent limit) | P0 |
| FR5 | Generate predictions for all games in upcoming AFL round | P0 |
| FR6 | Backtest formulas against minimum 2 seasons historical data | P0 |
| FR7 | Display results within 2 seconds (cached) / 5 seconds (uncached) | P1 |
| FR8 | First predictions within 10 minutes without registration | P0 |
| FR9 | Integrate with Squiggle API for real-time AFL data | P0 |
| FR10 | Scrape AFL Tables for historical statistics | P0 |
| FR11 | Detailed calculation explanations for each prediction | P1 |
| FR12 | Compare predictions against actual results post-game | P1 |
| FR13 | Provide 3-5 formula templates (Defense Wins, Home Advantage, etc.) | P1 |
| FR14 | Formula validation with helpful error messages | P0 |
| FR15 | Temporary session storage for unregistered users | P0 |

### Non-Functional Requirements (NFR)

| ID | Category | Requirement | Target |
|----|----------|-------------|--------|
| NFR1 | Usability | Mobile-responsive on all devices | 100% responsive |
| NFR2 | Performance | Formula calculations | <100ms |
| NFR3 | Performance | API response time (p95) | <500ms |
| NFR4 | Performance | Backtesting 2 seasons | <5 seconds |
| NFR5 | Performance | Page load on 4G | <3 seconds |
| NFR6 | Performance | Database queries | <50ms p95 |
| NFR7 | Scalability | Concurrent users at launch | 10,000 |
| NFR8 | Scalability | Azure hosting cost limit | <$500/month |
| NFR9 | Reliability | System availability (Thu-Sun) | 99.9% |
| NFR10 | Security | All data transmissions | HTTPS/TLS 1.3 |
| NFR11 | Security | API rate limiting | Required |
| NFR12 | Security | Authentication | JWT tokens |
| NFR13 | Data | User data persistence | Required |
| NFR14 | Data | Cache strategy | Redis with TTL |
| NFR15 | Compliance | Accessibility standard | WCAG AA |
| NFR16 | Compliance | Data privacy | GDPR compliant |

## User Journey Map

### Primary User Flow (First-Time User)

1. **Discovery** → Landing page with value proposition
2. **Exploration** → Try formula builder without registration (FR8)
3. **Creation** → Build first formula using drag-and-drop (FR1, FR2, FR3)
4. **Testing** → Generate predictions for upcoming round (FR5)
5. **Validation** → Backtest formula against history (FR6)
6. **Conversion** → Register to save formula (FR4)
7. **Retention** → Return weekly to generate tips

### Key User Segments

1. **Casual Tippers** - Want quick, better-than-random predictions
2. **Data Enthusiasts** - Want to test theories and optimize formulas
3. **Competition Players** - Need consistent, reliable predictions weekly

## Performance Requirements Matrix

| Operation | Target | Degraded | Unacceptable |
|-----------|--------|----------|--------------|
| Initial page load | <2s | 2-3s | >3s |
| Formula calculation | <100ms | 100-500ms | >500ms |
| Single prediction | <2s cached | 2-5s | >5s |
| Round predictions (9 games) | <3s | 3-7s | >7s |
| 2-season backtest | <5s | 5-10s | >10s |
| API response (p95) | <500ms | 500ms-1s | >1s |
| Database query (p95) | <50ms | 50-100ms | >100ms |

## Security Requirements

### Authentication & Authorization
- JWT-based authentication with secure token storage
- OAuth 2.0 preparation for social logins (Google, Facebook)
- Session management with 30-day refresh tokens
- Rate limiting per IP (100 req/min) and per user (500 req/min)

### Data Protection
- TLS 1.3 for all data in transit
- AES-256 encryption for sensitive data at rest
- Input sanitization for all user inputs (formula definitions)
- SQL injection prevention via parameterized queries
- XSS protection via Content Security Policy

### Security Monitoring
- Failed login attempt tracking and temporary lockouts
- Anomaly detection for unusual formula patterns
- API abuse monitoring with automatic blocking
- Regular security audit logging

### Compliance
- GDPR compliance with data export/deletion capabilities
- Privacy policy and terms of service enforcement
- Cookie consent management
- Age verification (13+ requirement)

## Testing Strategy

### Testing Pyramid

```
         /\
        /E2E\       (5%) - Critical user journeys only
       /-----\
      /  INT  \     (25%) - API & data pipeline tests  
     /---------\
    /   UNIT    \   (70%) - Formula engine, calculations
   /-------------\
```

### Test Coverage Requirements

| Component | Coverage Target | Test Types |
|-----------|----------------|------------|
| Formula Engine | 95% | Unit tests for all calculation scenarios |
| API Endpoints | 90% | Integration tests with mocked data |
| Data Pipeline | 85% | Integration tests for scraping/transformation |
| UI Components | 80% | Unit tests for critical components |
| User Flows | Manual | Manual testing for MVP, automated post-launch |

### Testing Environments

1. **Local** - Docker-based, runs on developer machines
2. **CI** - Automated tests on every PR
3. **Staging** - Pre-production testing with real data subset
4. **Production** - Smoke tests post-deployment

### Quality Gates (CI/CD)

- No merge without passing all tests
- Code coverage must not decrease
- Performance benchmarks must pass
- Security scan must show no high/critical issues
- Accessibility audit must pass WCAG AA

## Monitoring & Observability

### Application Monitoring

**Metrics to Track:**
- Formula creation rate (target: 10+ per hour)
- Prediction generation rate (target: 100+ per hour)
- Backtest completion rate (target: 95%+)
- User registration conversion (target: 20%)
- API response times (p50, p95, p99)
- Error rates by endpoint (<1% target)

**Tools:**
- Azure Application Insights for APM
- Custom dashboards in Azure Monitor
- Real User Monitoring (RUM) for frontend

### Data Pipeline Monitoring

**Health Checks:**
- Squiggle API availability (check every 5 min)
- AFL Tables scraping success rate (>95%)
- Data freshness (<48 hours for all sources)
- Data completeness (>90% matches with full stats)

**Alerting Thresholds:**
- API failure rate >1% → Page team
- Data staleness >48hrs → Email notification
- Scraping failure 2x consecutive → Slack alert
- Performance degradation >20% → Investigate

### Business Metrics Dashboard

- Daily Active Users (DAU)
- Formula creation funnel conversion
- Average predictions per user
- Formula accuracy distribution
- User retention (D1, D7, D30)

## Data Privacy & Compliance

### Data Collection & Usage

**Personal Data Collected:**
- Email address (for authentication)
- IP address (for rate limiting)
- Formula definitions (user-generated content)
- Prediction history
- Usage analytics (anonymized)

**Data Retention:**
- Active user data: Retained while account active
- Inactive accounts: Archived after 12 months
- Deleted accounts: Purged within 30 days
- Analytics data: Aggregated after 90 days

### User Rights (GDPR)

- **Right to Access:** Export all personal data via settings
- **Right to Rectification:** Edit profile and formulas
- **Right to Erasure:** Delete account and all associated data
- **Right to Portability:** Export formulas as JSON
- **Right to Object:** Opt-out of marketing communications

### Compliance Requirements

- Privacy policy must be accepted before registration
- Cookie consent banner for EU users
- Age verification (13+ due to COPPA)
- Terms of service acceptance required
- Data processing agreement with third parties

## Operations & Support Plan

### Support Channels

1. **Self-Service** (Primary)
   - Comprehensive FAQ section
   - Video tutorials for formula building
   - Interactive onboarding flow
   
2. **Community** (Secondary)
   - User forum for formula discussions
   - Tips and strategies shared by users
   
3. **Direct Support** (Tertiary)
   - Email support (24-48hr response)
   - Critical bug reporting via in-app

### Operational Runbooks

**Common Issues:**
1. Data source failure → Fallback to cache → Manual refresh
2. High load → Auto-scaling → Load shedding if needed
3. Formula calculation errors → Retry → Fallback to simple formula
4. Authentication issues → Token refresh → Force re-login

### Maintenance Windows

- Scheduled: Tuesday 2-4 AM AEST (lowest traffic)
- Emergency: Maximum 30 minutes with status page update
- Database maintenance: Monthly during scheduled window

## Disaster Recovery Plan

### Backup Strategy

| Data Type | Backup Frequency | Retention | Recovery Time |
|-----------|-----------------|-----------|---------------|
| User Data | Every 6 hours | 30 days | <2 hours |
| Formulas | Real-time replication | 90 days | <30 minutes |
| Predictions | Daily | 7 days | <4 hours |
| Application | On deployment | Last 10 versions | <15 minutes |

### Failure Scenarios

1. **Database Failure**
   - Automatic failover to replica (RTO: 5 min)
   - Point-in-time recovery available (RPO: 1 hour)

2. **API Service Failure**
   - Fallback to cached data (<24hrs old)
   - Degraded mode with limited features

3. **Complete Region Failure**
   - Cross-region backup activation (RTO: 1 hour)
   - DNS failover to backup region

### Recovery Testing

- Monthly backup restoration test
- Quarterly failover simulation
- Annual full disaster recovery drill

## Launch Strategy

### Phased Rollout Plan

**Week 1-2: Closed Beta**
- 50 invited users (AFL enthusiasts)
- Full feature access with feedback surveys
- Daily monitoring and bug fixes

**Week 3-4: Open Beta**
- 500 users with registration
- Feature flags for gradual feature release
- A/B testing for conversion optimization

**Week 5-6: Public Launch**
- Full public access
- Marketing campaign activation
- Press release and social media

### Launch Success Metrics

- 1,000 users registered within 60 days
- 55%+ average prediction accuracy
- 20% free-to-paid conversion rate
- <3% week-1 churn rate
- 4+ app store rating

### Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Server overload | Medium | High | Auto-scaling, CDN, rate limiting |
| Data source fails | Low | High | Multiple sources, caching, manual fallback |
| Poor predictions | Medium | Medium | Templates, education, continuous improvement |
| Security breach | Low | Critical | Security audit, penetration testing, monitoring |

## Technical Architecture Summary

### System Architecture

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│   Frontend  │────▶│   API Layer  │────▶│   Database   │
│  (Next.js)  │     │  (Node.js)   │     │ (PostgreSQL) │
└─────────────┘     └──────────────┘     └──────────────┘
                            │                      │
                    ┌───────▼────────┐    ┌───────▼────────┐
                    │ Formula Engine │    │     Redis      │
                    │   (Module)     │    │    (Cache)     │
                    └────────────────┘    └────────────────┘
                            │
                    ┌───────▼────────────────────┐
                    │   External Data Sources    │
                    │ (Squiggle API, AFL Tables) │
                    └─────────────────────────────┘
```

### Technology Stack

**Frontend:**
- Next.js 14+ with TypeScript
- React DnD for drag-and-drop
- Tailwind CSS for styling
- PWA configuration

**Backend:**
- Node.js with Express/Fastify
- TypeScript for type safety
- Bull for job queues
- JWT for authentication

**Infrastructure:**
- Azure App Service (web hosting)
- Azure Database for PostgreSQL
- Azure Cache for Redis
- Azure Blob Storage (static assets)
- Azure Application Insights (monitoring)

## Epic Summary with Cross-References

### Epic 1: Foundation & Core Formula Engine
**Requirements:** FR1, FR2, FR3, NFR14
**Key Deliverable:** Working formula builder with drag-and-drop

### Epic 2: Data Pipeline & Integration  
**Requirements:** FR9, FR10, NFR13, NFR14
**Key Deliverable:** Real AFL data flowing into predictions

### Epic 3: Predictions & Backtesting
**Requirements:** FR5, FR6, FR7, FR11, FR12
**Key Deliverable:** Accurate predictions with historical validation

### Epic 4: User Accounts & Persistence
**Requirements:** FR4, FR15, NFR11, NFR12
**Key Deliverable:** Saved formulas and prediction history

### Epic 5: Polish & Launch Readiness
**Requirements:** NFR1-NFR16, FR13, FR14
**Key Deliverable:** Production-ready platform

## User Stories (Referencing Requirements)

> **Note:** Each story references specific requirements (FRx/NFRx) rather than restating them. Refer to the Requirements section for detailed specifications.

### Epic 1: Foundation & Core Formula Engine

#### Story 1.1: Project Foundation Setup
**As a** developer  
**I want** a fully configured development environment with CI/CD pipeline  
**So that** the team can build and deploy features consistently

**References:** Technical Architecture, Testing Strategy, NFR7, NFR8
- Implement monorepo structure per Technical Architecture
- Configure CI/CD per Testing Strategy quality gates
- Set up Azure infrastructure within NFR8 cost limits

#### Story 1.2: Basic App Shell and Navigation  
**References:** NFR1, NFR5, NFR15
- Responsive design meeting NFR1 requirements
- Page load performance per NFR5 (<3s on 4G)
- Accessibility per NFR15 (WCAG AA)

#### Story 1.3: Metrics Library Component
**References:** FR2
- Implement all 20+ metrics defined in FR2
- Touch-friendly interface per NFR1

#### Story 1.4: Drag-and-Drop Formula Builder
**References:** FR1, FR3
- Visual builder per FR1 specifications
- Weighting sliders per FR3 (0-100% influence)
- Maximum metrics enforced per formula limits

#### Story 1.5: Formula Calculation Engine
**References:** NFR2, Testing Strategy
- Meet NFR2 performance target (<100ms)
- 95% test coverage per Testing Strategy

#### Story 1.6: Metric Weighting Controls
**References:** FR3
- Slider controls for 0-100% influence per FR3
- Visual weight indicators
- Normalize weights option

#### Story 1.7: Sample Data and Preview
**References:** FR7, FR11
- Sample dataset with 5 representative matches
- Instant preview updates per FR7 performance
- Detailed calculation breakdown per FR11

### Epic 2: Data Pipeline & Integration

#### Story 2.1: Squiggle API Integration
**References:** FR9, Data Privacy & Compliance, Appendix B
- Implement per API specifications in Appendix B
- Caching strategy per NFR14
- Error handling per Monitoring & Observability

#### Story 2.2: AFL Tables Data Scraping
**References:** FR10, Monitoring & Observability
- Rate limiting per Security Requirements
- Data quality per Monitoring thresholds
- Fallback strategy per Disaster Recovery Plan

#### Story 2.3: Data Transformation Layer
**References:** NFR14, Data Model (Appendix C)
- Unified data model implementation
- Caching strategy per NFR14
- Missing data handling with defaults

#### Story 2.4: Real-Time Predictions Generator
**References:** FR5, FR7, Performance Matrix
- Generate all games per round (FR5)
- Meet performance targets in matrix
- Export/sharing capabilities

#### Story 2.5: Current Season Statistics
**References:** FR2, Data Pipeline Monitoring
- Update after each round
- Form calculations (last 5 games)
- Data freshness per monitoring specs

#### Story 2.6: Data Quality Monitoring
**References:** Monitoring & Observability
- Dashboard implementation per monitoring specs
- Alert thresholds as defined
- Manual refresh capability

### Epic 3: Predictions & Backtesting

#### Story 3.1: Historical Backtesting Engine
**References:** FR6, NFR4
- 2-season minimum per FR6
- Performance per NFR4 (<5 seconds)
- Caching per NFR14

#### Story 3.2: Backtesting Results Visualization
**References:** FR11, User Journey Map
- Results by season, round, team
- Accuracy trend graphs
- Comparison to 50% baseline

#### Story 3.3: Formula Performance Metrics
**References:** FR11, FR12
- Detailed metrics (accuracy, precision, upset detection)
- Team-specific performance analysis
- Statistical significance indicators

#### Story 3.4: Round-by-Round Results Tracking
**References:** FR12, Monitoring Metrics
- Automatic results fetching
- Predictions vs actual comparison per FR12
- Running accuracy tracking

#### Story 3.5: Formula Comparison Tool
**References:** FR11, User Journey (Data Enthusiasts)
- Compare 2-3 formulas side-by-side
- Head-to-head accuracy metrics
- Agreement/disagreement analysis

#### Story 3.6: Confidence Scoring System
**References:** FR11, Performance Matrix
- Confidence percentage per prediction
- Historical accuracy-based confidence
- Visual confidence indicators

#### Story 3.7: Formula Templates Library
**References:** FR13
- 5 templates per FR13 specification
- One-click copy to personal formulas
- Template performance tracking

### Epic 4: User Accounts & Persistence

#### Story 4.1: User Registration and Authentication
**References:** Security Requirements, NFR10, NFR11, NFR12
- JWT implementation per NFR12
- Security measures per Security Requirements
- HTTPS per NFR10

#### Story 4.2: Formula Persistence
**References:** FR4, FR15, NFR13
- 5 formula limit per FR4
- Session storage per FR15
- Data persistence per NFR13

#### Story 4.3: User Dashboard
**References:** User Journey Map, Monitoring Metrics
- Implements primary user flow
- Tracks business metrics defined in Monitoring

#### Story 4.4: Prediction History Archive
**References:** NFR13, Data Privacy
- Full prediction history storage
- Filtering and search capabilities
- Export as CSV for analysis

#### Story 4.5: User Profile and Settings
**References:** Data Privacy & Compliance, NFR16
- Profile management
- Notification preferences
- GDPR compliance features per NFR16

#### Story 4.6: Session Migration Flow
**References:** FR15, FR8, User Journey
- Session storage per FR15
- Migration to account on registration
- 7-day browser storage retention

#### Story 4.7: Multi-Device Synchronization
**References:** NFR13, User Journey
- Real-time sync across devices
- Conflict resolution (newest wins)
- Offline capability with sync

### Epic 5: Polish & Launch

#### Story 5.1: Performance Optimization
**References:** Performance Requirements Matrix, NFR2-NFR6
- Meet all targets in Performance Matrix
- Implement caching per NFR14

#### Story 5.2: Mobile Experience Enhancement
**References:** NFR1, User Journey (Mobile-first)
- Touch gestures optimization
- Bottom sheet navigation
- Native sharing integration

#### Story 5.3: Analytics and Monitoring Implementation
**References:** Monitoring & Observability, Business Metrics
- Analytics implementation per monitoring specs
- Custom events tracking
- Real-time alerts configuration

#### Story 5.4: Onboarding and Help System
**References:** FR8, User Journey Map
- Interactive tutorial for first-time users
- Tooltips and contextual help
- FAQ and video walkthroughs

#### Story 5.5: Error Handling and Recovery
**References:** Disaster Recovery Plan, Operations
- User-friendly error messages
- Automatic retry logic
- Formula auto-recovery from crashes

#### Story 5.6: Pre-Launch Testing Suite
**References:** Testing Strategy, NFR7
- Load testing for 10,000 users (NFR7)
- Cross-browser testing
- Security penetration testing

#### Story 5.7: Launch Preparation Package
**References:** Launch Strategy, Operations & Support Plan
- Production environment setup
- Launch materials per Launch Strategy
- Status page configuration

#### Story 5.8: Feature Flags and Rollout Control
**References:** Launch Strategy (Phased Rollout)
- Feature flag implementation
- Percentage-based rollout
- Kill switches for features

## Appendices

### A. Metric Definitions

The 20+ AFL metrics available for formula building:
1. Recent Form (last 5 games win %)
2. Head-to-Head Record (last 10 meetings)
3. Home Advantage (home win % for team)
4. Weather Conditions (wet/dry impact)
5. Tackles (average per game)
6. Hit-outs (ruck dominance)
7. Clearances (center and stoppage)
8. Contested Possessions (hardness at the ball)
9. Inside 50s (forward entries)
10. Disposal Efficiency (skill execution %)
11. Goal Accuracy (goals/scoring shots %)
12. Marks (possession retention)
13. Turnovers (ball security)
14. Metres Gained (territory dominance)
15. Pressure Acts (defensive intensity)
16. Scoring Shots (total opportunities)
17. Time in Forward Half (field position %)
18. Ruck Contests (hit-out to advantage %)
19. Intercepts (defensive reads)
20. Team Height Advantage (average height differential)
21. Days Rest (recovery between games)
22. Travel Distance (km from home base)
23. Ground Dimensions (venue-specific adjustments)
24. Injury List Impact (key players missing)

### B. API Specifications

**Squiggle API Endpoints:**
- Fixtures: `GET /api/?q=games&year={year}`
- Standings: `GET /api/?q=standings&year={year}`
- Tips: `GET /api/?q=tips&year={year}&round={round}`

**Headers Required:**
- User-Agent: "AFL Predictor Platform - dev@aflpredictor.com"

### C. Data Model Entities

**User Domain:**
- `users` table: id, email, password_hash, created_at, last_login
- `formulas` table: id, user_id, name, definition (JSON), created_at, modified_at
- `formula_metrics` table: id, formula_id, metric_id, weight (0-100)
- `predictions` table: id, formula_id, match_id, predicted_winner, confidence, created_at
- `prediction_results` table: id, prediction_id, actual_winner, correct (boolean)

**AFL Data Domain:**
- `teams` table: id, name, abbreviation, home_ground, state
- `players` table: id, name_dob_hash, current_team_id, position
- `matches` table: id, round_id, home_team_id, away_team_id, venue_id, date_time, home_score, away_score
- `rounds` table: id, season_id, round_number, start_date
- `seasons` table: id, year, start_date, end_date
- `match_stats` table: match_id, team_id, disposals, marks, tackles, goals, behinds, etc.
- `player_match_stats` table: match_id, player_id, disposals, marks, tackles, goals, etc.
- `venues` table: id, name, city, capacity, surface_type

**Formula & Prediction Domain:**
- `metrics` table: id, name, description, calculation_type, data_source
- `backtest_results` table: id, formula_id, season_id, total_games, correct_predictions, accuracy

**Data Pipeline Domain:**
- `data_sources` table: id, name, type (API/scraper), base_url
- `data_sync_logs` table: id, source_id, sync_time, status, records_processed, error_message
- `cache_entries` table: key, value (JSON), expires_at, created_at

---

*PRD Version 2.0 - Restructured 2025-08-28*
*Major changes: Consolidated testing, security, monitoring into dedicated sections. Added missing operational sections. Removed duplication throughout.*