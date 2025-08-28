# Epic 1: Foundation & Core Formula Engine

## Epic Overview
**Goal:** Establish project foundation and build the core drag-and-drop formula builder that allows users to create prediction formulas visually.

**Key Deliverable:** Working formula builder with drag-and-drop interface where users can select metrics and adjust weights.

**Requirements Coverage:** FR1, FR2, FR3, NFR14, Technical Architecture, Testing Strategy, NFR7, NFR8

**Dependencies:** None - this is the foundational epic

**Estimated Duration:** 2 weeks

## Success Criteria
- [ ] Development environment fully configured with CI/CD pipeline
- [ ] Basic app shell deployed to staging environment
- [ ] Formula builder allows drag-and-drop of at least 20 metrics
- [ ] Weight adjustment works with real-time preview
- [ ] Formula calculations complete in <100ms
- [ ] 95% test coverage on formula engine

## Story Breakdown

### Story 1.1: Project Foundation Setup
**Priority:** P0 (Blocker)  
**Points:** 5  
**Dependencies:** None

**As a** developer  
**I want** a fully configured development environment with CI/CD pipeline  
**So that** the team can build and deploy features consistently

#### Acceptance Criteria
- [ ] Create GitHub repository with initial README
- [ ] Set up monorepo structure with frontend and backend folders
- [ ] Initialize Next.js 14+ project with TypeScript in frontend folder
- [ ] Initialize Node.js with Fastify and TypeScript in backend folder
- [ ] Configure ESLint, Prettier, and Husky for code quality
- [ ] Set up GitHub Actions for CI (test, lint, type-check)
- [ ] Configure Azure DevOps for CD to App Service
- [ ] Create development, staging, and production environments in Azure
- [ ] Set up Azure Database for PostgreSQL (development instance)
- [ ] Configure Azure Cache for Redis (development instance)
- [ ] Create .env.example files with all required variables
- [ ] Document local development setup in README
- [ ] Verify deployment pipeline works end-to-end

#### Technical Notes
- Use pnpm workspaces for monorepo management
- Configure path aliases for clean imports
- Set up pre-commit hooks for linting and formatting
- Use Docker Compose for local development dependencies

---

### Story 1.2: Basic App Shell and Navigation
**Priority:** P0  
**Points:** 3  
**Dependencies:** Story 1.1

**As a** user  
**I want** to navigate between different sections of the app  
**So that** I can access all features intuitively

#### Acceptance Criteria
- [ ] Create responsive layout with header, main content, and footer
- [ ] Implement primary navigation: Formula Builder, Predictions, Account, Help
- [ ] Add mobile hamburger menu with smooth transitions
- [ ] Configure Next.js routing for all main sections
- [ ] Implement 404 and error pages
- [ ] Add loading states for route transitions
- [ ] Ensure WCAG AA accessibility compliance
- [ ] Page loads in <3s on 4G connection
- [ ] Set up meta tags for SEO
- [ ] Configure PWA manifest for installability

#### Technical Notes
- Use Next.js App Router for routing
- Implement layout.tsx for consistent structure
- Use Tailwind CSS for responsive design
- Add next-pwa for PWA functionality

---

### Story 1.3: Metrics Library Component
**Priority:** P0  
**Points:** 3  
**Dependencies:** Story 1.2

**As a** user  
**I want** to browse and search available metrics  
**So that** I can find the right metrics for my formula

#### Acceptance Criteria
- [ ] Display all 20+ metrics from requirements (FR2)
- [ ] Implement search functionality with instant filtering
- [ ] Show metric name, icon, and description
- [ ] Group metrics by category (Performance, Historical, Environmental)
- [ ] Highlight metric on hover with tooltip explanation
- [ ] Mobile-optimized with touch-friendly cards
- [ ] Lazy load metric descriptions for performance
- [ ] Include "coming soon" section for future metrics

#### Technical Notes
- Create reusable MetricCard component
- Use React.memo for performance optimization
- Implement virtual scrolling if needed
- Store metrics configuration in JSON

---

### Story 1.4: Drag-and-Drop Formula Builder
**Priority:** P0  
**Points:** 5  
**Dependencies:** Story 1.3

**As a** user  
**I want** to drag metrics into my formula visually  
**So that** I can build formulas without coding

#### Acceptance Criteria
- [ ] Implement drag-and-drop using @dnd-kit library
- [ ] Create formula canvas with clear drop zones
- [ ] Support dragging metrics from library to canvas
- [ ] Allow reordering metrics within formula
- [ ] Show visual feedback during drag operations
- [ ] Limit formula to maximum configured metrics
- [ ] Support keyboard navigation for accessibility
- [ ] Provide "Add" button alternative to drag-and-drop
- [ ] Auto-save formula to session storage
- [ ] Clear visual distinction between empty and populated states

#### Technical Notes
- Use @dnd-kit for accessible drag-and-drop
- Implement optimistic updates for smooth UX
- Consider touch gestures for mobile
- Use Zustand for formula state management

---

### Story 1.5: Formula Calculation Engine
**Priority:** P0  
**Points:** 5  
**Dependencies:** Story 1.4

**As a** system  
**I want** to calculate formula results efficiently  
**So that** users get instant feedback on their formulas

#### Acceptance Criteria
- [ ] Implement formula calculation algorithm
- [ ] Support all metric types and weightings
- [ ] Calculate results in <100ms (NFR2)
- [ ] Handle missing or invalid data gracefully
- [ ] Implement result caching strategy
- [ ] Create comprehensive unit tests (95% coverage)
- [ ] Support both percentage and raw score outputs
- [ ] Document calculation methodology
- [ ] Implement calculation explanation generator

#### Technical Notes
- Create separate calculation module for testing
- Use Web Workers for heavy calculations if needed
- Implement memoization for repeated calculations
- Consider WASM for performance-critical paths

---

### Story 1.6: Metric Weighting Controls
**Priority:** P0  
**Points:** 3  
**Dependencies:** Story 1.4

**As a** user  
**I want** to adjust the importance of each metric  
**So that** I can fine-tune my formula

#### Acceptance Criteria
- [ ] Create slider component for 0-100% weight adjustment
- [ ] Display current weight value during adjustment
- [ ] Update formula preview in real-time (<100ms)
- [ ] Implement "normalize weights" option
- [ ] Support keyboard input for precise values
- [ ] Color-code weights by intensity
- [ ] Touch-optimized with 44px minimum target
- [ ] Persist weight changes immediately
- [ ] Show total weight distribution visualization

#### Technical Notes
- Use React Hook Form for form management
- Implement debounced updates for performance
- Create custom slider component
- Use Framer Motion for smooth animations

---

### Story 1.7: Sample Data and Preview
**Priority:** P1  
**Points:** 3  
**Dependencies:** Stories 1.5, 1.6

**As a** user  
**I want** to see how my formula performs on sample matches  
**So that** I can validate my formula logic before using real data

#### Acceptance Criteria
- [ ] Create sample dataset with 5 representative AFL matches
- [ ] Display prediction for each sample match
- [ ] Show confidence percentage for each prediction
- [ ] Update instantly when formula changes
- [ ] Include variety of match scenarios (close games, blowouts, upsets)
- [ ] Display calculation breakdown on demand
- [ ] Compare formula output to actual results
- [ ] Highlight correct vs incorrect predictions

#### Technical Notes
- Store sample data in JSON files
- Create fixture data generator for testing
- Implement calculation explanation component
- Cache preview results for performance

## Testing Requirements

### Unit Tests
- Formula calculation engine (100% coverage)
- Metric weight normalization
- Drag-and-drop state management
- Component rendering logic

### Integration Tests
- Formula builder workflow end-to-end
- Data flow from UI to calculation engine
- Session storage persistence
- Navigation between sections

### E2E Tests
- Complete formula creation flow
- Mobile drag-and-drop alternatives
- Accessibility with screen readers
- Performance benchmarks

## Documentation Deliverables
- [ ] API documentation for formula endpoints
- [ ] Component storybook for UI components
- [ ] Formula calculation methodology guide
- [ ] Accessibility compliance report
- [ ] Performance benchmark results

## Risk Mitigation
- **Risk:** Drag-and-drop complexity on mobile
  - **Mitigation:** Implement button-based alternatives
- **Risk:** Formula calculation performance
  - **Mitigation:** Use Web Workers and caching
- **Risk:** Browser compatibility issues
  - **Mitigation:** Progressive enhancement approach

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Test coverage >95% for critical paths
- [ ] Code reviewed and approved
- [ ] Documentation complete
- [ ] Deployed to staging environment
- [ ] Performance benchmarks passed
- [ ] Accessibility audit passed (WCAG AA)
- [ ] Product owner sign-off received