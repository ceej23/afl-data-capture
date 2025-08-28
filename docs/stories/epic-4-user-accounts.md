# Epic 4: User Accounts & Persistence

## Epic Overview
**Goal:** Implement user authentication, account management, and data persistence to enable users to save formulas and track prediction history across sessions.

**Key Deliverable:** Secure user accounts with saved formulas, prediction history, and multi-device synchronization.

**Requirements Coverage:** FR4, FR15, NFR10, NFR11, NFR12, NFR13, Security Requirements, Data Privacy & Compliance

**Dependencies:** Epics 1-3 (need working formulas and predictions to persist)

**Estimated Duration:** 1.5 weeks

## Success Criteria
- [ ] Users can register and login securely
- [ ] Each user can save up to 5 custom formulas
- [ ] Prediction history persists across sessions
- [ ] Session data migrates to account on registration
- [ ] Multi-device synchronization works seamlessly
- [ ] GDPR compliance implemented
- [ ] JWT authentication with proper security

## Story Breakdown

### Story 4.1: User Registration and Authentication
**Priority:** P0  
**Points:** 5  
**Dependencies:** Epic 1 complete

**As a** user  
**I want** to create an account and login securely  
**So that** I can save my formulas and access them anywhere

#### Acceptance Criteria
- [ ] Implement registration with email and password
- [ ] Validate email format and password strength
- [ ] Send email verification (can be simulated for MVP)
- [ ] Implement JWT-based authentication (NFR12)
- [ ] Set up refresh token rotation (30-day expiry)
- [ ] Create login page with remember me option
- [ ] Implement password reset flow
- [ ] Add rate limiting for auth endpoints
- [ ] Implement account lockout after failed attempts
- [ ] Set up OAuth 2.0 preparation for future social login
- [ ] Create user profile in database on registration
- [ ] Implement HTTPS/TLS 1.3 for all auth traffic (NFR10)
- [ ] Add CSRF protection
- [ ] Log authentication events for security

#### Technical Notes
- Use Passport.js with JWT strategy
- Implement bcrypt for password hashing
- Store refresh tokens securely (httpOnly cookies)
- Use Redis for session management
- Implement auth middleware for protected routes

---

### Story 4.2: Formula Persistence
**Priority:** P0  
**Points:** 3  
**Dependencies:** Story 4.1

**As a** user  
**I want** to save my custom formulas  
**So that** I can reuse them without rebuilding

#### Acceptance Criteria
- [ ] Save up to 5 formulas per user (FR4)
- [ ] Name and describe each formula
- [ ] Set one formula as default
- [ ] Edit existing formulas
- [ ] Delete unwanted formulas
- [ ] Duplicate formulas for variations
- [ ] View formula creation/modified dates
- [ ] Export formulas as JSON
- [ ] Import formulas from JSON
- [ ] Share formula via unique URL
- [ ] Track formula version history
- [ ] Validate formula integrity on save

#### Technical Notes
- Store formulas in PostgreSQL with user_id FK
- Implement soft delete for recovery
- Use database transactions for consistency
- Create formula validation service
- Implement formula serialization/deserialization

---

### Story 4.3: User Dashboard
**Priority:** P0  
**Points:** 3  
**Dependencies:** Stories 4.1, 4.2

**As a** user  
**I want** a personalized dashboard  
**So that** I can manage my formulas and see my performance

#### Acceptance Criteria
- [ ] Display user's saved formulas with performance
- [ ] Show recent predictions and results
- [ ] Display accuracy trends over time
- [ ] Quick access to generate weekly tips
- [ ] Show upcoming round information
- [ ] Display notification badges for new results
- [ ] Provide quick stats (total predictions, accuracy)
- [ ] Enable formula switching with one click
- [ ] Show data freshness indicators
- [ ] Include helpful tips for new users
- [ ] Mobile-responsive layout
- [ ] Customizable dashboard widgets

#### Technical Notes
- Use server-side rendering for fast load
- Implement dashboard state persistence
- Cache dashboard data aggressively
- Use WebSockets for real-time updates
- Create reusable dashboard components

---

### Story 4.4: Prediction History Archive
**Priority:** P1  
**Points:** 3  
**Dependencies:** Story 4.1

**As a** user  
**I want** to access all my past predictions  
**So that** I can track my improvement over time

#### Acceptance Criteria
- [ ] Store all predictions with timestamps
- [ ] Link predictions to formula used
- [ ] Record actual match results
- [ ] Calculate accuracy for each round
- [ ] Filter history by date range
- [ ] Filter by formula used
- [ ] Filter by team
- [ ] Search predictions by match
- [ ] Export history as CSV
- [ ] Generate season summary reports
- [ ] Paginate long history lists
- [ ] Show prediction confidence scores

#### Technical Notes
- Implement efficient database indexing
- Use pagination for performance
- Create data export service
- Implement archival strategy for old data
- Consider using time-series database

---

### Story 4.5: User Profile and Settings
**Priority:** P1  
**Points:** 2  
**Dependencies:** Story 4.1

**As a** user  
**I want** to manage my profile and preferences  
**So that** I can customize my experience

#### Acceptance Criteria
- [ ] Update email address (with verification)
- [ ] Change password with current password confirmation
- [ ] Set timezone for match times
- [ ] Choose favorite AFL team for theming
- [ ] Configure email notifications
- [ ] Manage privacy settings
- [ ] Download all personal data (GDPR - NFR16)
- [ ] Delete account and all data
- [ ] Set default formula
- [ ] Configure prediction sharing defaults
- [ ] Manage API access tokens (future)
- [ ] View login history and active sessions

#### Technical Notes
- Implement audit logging for profile changes
- Use feature flags for preferences
- Create GDPR data export service
- Implement secure account deletion
- Store preferences in separate table

---

### Story 4.6: Session Migration Flow
**Priority:** P0  
**Points:** 3  
**Dependencies:** Story 4.1

**As a** user  
**I want** my trial work to transfer when I register  
**So that** I don't lose my formulas created before signing up

#### Acceptance Criteria
- [ ] Store formulas in sessionStorage for anonymous users (FR15)
- [ ] Detect existing session data on registration
- [ ] Prompt to import session formulas
- [ ] Merge session data with new account
- [ ] Handle conflicts (e.g., exceeding 5 formula limit)
- [ ] Clear session data after successful migration
- [ ] Provide preview of data to be migrated
- [ ] Allow selective migration
- [ ] Maintain prediction history from session
- [ ] Transfer backtest results
- [ ] Show success confirmation
- [ ] Retain session for 7 days in browser

#### Technical Notes
- Use localStorage with expiry timestamps
- Implement conflict resolution UI
- Create migration service
- Handle edge cases gracefully
- Test across different browsers

---

### Story 4.7: Multi-Device Synchronization
**Priority:** P1  
**Points:** 3  
**Dependencies:** Stories 4.1, 4.2

**As a** user  
**I want** my data synchronized across devices  
**So that** I can access my formulas anywhere

#### Acceptance Criteria
- [ ] Real-time sync of formula changes
- [ ] Sync prediction history
- [ ] Sync user preferences
- [ ] Handle concurrent edits (last-write-wins)
- [ ] Show sync status indicator
- [ ] Work offline with sync on reconnect
- [ ] Resolve conflicts automatically
- [ ] Provide manual sync trigger
- [ ] Show last sync timestamp
- [ ] Alert on sync failures
- [ ] Support 5+ concurrent devices
- [ ] Maintain data consistency

#### Technical Notes
- Use WebSockets for real-time sync
- Implement optimistic locking
- Use event sourcing for conflict resolution
- Create offline queue for changes
- Implement sync retry logic

## Testing Requirements

### Unit Tests
- Authentication logic
- Password hashing and validation
- JWT token generation/validation
- Formula persistence operations
- Session migration logic

### Integration Tests
- Complete registration flow
- Login/logout workflows
- Formula CRUD operations
- Session to account migration
- Multi-device sync scenarios

### Security Tests
- Authentication bypass attempts
- SQL injection on user inputs
- XSS attack prevention
- CSRF token validation
- Rate limiting effectiveness

### E2E Tests
- Complete user journey from anonymous to registered
- Formula creation, save, and retrieval
- Password reset flow
- Account deletion process
- Cross-device synchronization

## Documentation Deliverables
- [ ] Authentication API documentation
- [ ] User data model schema
- [ ] Privacy policy template
- [ ] Terms of service template
- [ ] GDPR compliance checklist
- [ ] Security best practices guide

## Risk Mitigation
- **Risk:** User data loss during migration
  - **Mitigation:** Implement thorough backup before migration
- **Risk:** Account security breaches
  - **Mitigation:** Implement MFA, rate limiting, and monitoring
- **Risk:** GDPR non-compliance
  - **Mitigation:** Audit all data handling, implement data portability

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Security audit passed
- [ ] GDPR compliance verified
- [ ] Test coverage >85%
- [ ] Performance benchmarks met
- [ ] Documentation complete
- [ ] Penetration testing completed
- [ ] Product owner sign-off received