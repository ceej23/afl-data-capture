# Project Brief: User-Driven Sports Prediction Platform

## Executive Summary

A user-driven sports prediction platform that democratizes sports analytics by enabling punters to build, test, and share their own prediction formulas through an intuitive drag-and-drop interface. The platform transforms users' intrinsic understanding of sports into testable, mechanized prediction models without requiring coding or statistics knowledge. Starting with AFL tipping competitions, the solution addresses the gap between black-box AI predictions and manual guessing by giving users full control over what metrics matter. The core value proposition is simple: "You already know what matters - we help you prove it."

## Problem Statement

Currently, sports punters face a frustrating paradox: they possess deep, experience-based insights about what drives game outcomes, yet lack the tools to formalize and validate these theories. Existing solutions force users into two unsatisfactory extremes - either blindly trusting black-box AI algorithms that offer no transparency or control, or manually picking winners based on gut feel without systematic validation.

The impact is significant: millions of Australians participate in tipping competitions weekly, with the sports betting market reaching $5.6 billion annually, yet most participants achieve only 50-55% accuracy despite believing they understand the game deeply. Current platforms like FootyTips serve over 1 million users but provide zero analytical tools, while AI platforms like Rithmm charge $30-100/month for predictions users can't customize or understand.

This problem demands immediate attention as the AI sports analytics market grows at 29.8% CAGR, increasingly pushing opaque solutions that disconnect users from their own expertise. Without intervention, the gap between those with data science skills and everyday fans will only widen, leaving passionate sports enthusiasts unable to compete or validate their knowledge in an increasingly data-driven landscape.

## Proposed Solution

The platform provides a visual, drag-and-drop formula builder that transforms sports prediction from a black-box mystery into a transparent, user-controlled process. Users select metrics they believe matter (team height, recent form, tackle count, etc.), define relationships between them through natural language or visual weighting, and instantly see predictions for upcoming games. Every formula can be backtested against historical data to prove its effectiveness before being used for real predictions.

Key differentiators from existing solutions:
- **User-owned intelligence**: Unlike AI platforms, users create and own their prediction logic
- **Formula marketplace**: Successful formulas can be shared, followed, or monetized by creators
- **Progressive complexity**: Casual users can adopt proven formulas with one click, while power users can build complex multi-metric models
- **Multi-domain scalability**: The same engine that predicts AFL can be applied to elections, stocks, or any predictable event

This solution succeeds where others haven't by recognizing a fundamental truth: punters already have theories about what drives outcomes - they just need tools to formalize and test them. By democratizing prediction modeling and creating network effects through formula sharing, the platform becomes more valuable as more users contribute their unique insights. The transparent, explainable nature of user-built formulas builds trust and engagement that black-box algorithms can never achieve.

## Target Users

### Primary User Segment: The Weekend Warrior

**Profile:**
- Demographics: 25-45 years old, predominantly male (70%), middle to upper-middle income
- Participates in 2-3 office tipping competitions annually
- Watches 3+ games per week during season, attends 5-10 games per year
- Has played the sport at some level (junior, amateur, or social)

**Current Behaviors:**
- Manually enters tips on FootyTips or similar platforms weekly
- Discusses predictions with mates at work/pub
- Follows team news religiously but struggles to quantify insights
- Achieves 55-60% accuracy but believes they could do better with right tools

**Specific Needs:**
- Quick generation of tips for entire round (9 games)
- Way to prove their theories ("defense wins finals")
- Beating workplace rivals with data-backed selections
- Understanding why their predictions fail

**Goals:**
- Win office tipping competition
- Validate their sports knowledge
- Gain bragging rights through superior predictions

### Secondary User Segment: The Data Skeptic Gambler

**Profile:**
- Demographics: 30-50 years old, higher disposable income, tech-comfortable
- Places $50-500 in bets weekly
- Burned by "expert tips" and suspicious of bookmaker odds

**Current Behaviors:**
- Maintains complex Excel spreadsheets
- Subscribes to multiple stats sites
- Spends 5+ hours weekly analyzing matches
- Achieves 52-58% success rate but seeks consistency

**Specific Needs:**
- Deep customization and formula control
- Extensive backtesting capabilities
- Access to obscure metrics others miss
- Transparency in prediction logic

**Goals:**
- Find sustainable edge over bookmakers
- Build and refine the "perfect" formula
- Achieve consistent 60%+ accuracy

## Goals & Success Metrics

### Business Objectives
- **Achieve 10,000 active users within 6 months** (measured by weekly active formula users)
- **Generate $20,000 MRR by month 12** (through premium subscriptions at $20-50/month)
- **Create marketplace with 100+ shared formulas by month 6** (driving network effects)
- **Secure 2 data partnerships within 90 days** (reducing data costs by 50%)
- **Achieve 20% conversion from free to paid within 9 months** (validating freemium model)

### User Success Metrics
- **Average user prediction accuracy improves 5-10%** over their baseline
- **Formula creation time under 5 minutes** for basic formulas
- **Backtesting validates formula performance** within 30 seconds
- **60% of users create at least one custom formula** within first week
- **30% of users share or adopt community formulas** within first month

### Key Performance Indicators (KPIs)
- **Weekly Active Users (WAU):** Target 40% of registered users active weekly
- **Formula Creation Rate:** Average 2.5 formulas created per active user
- **Prediction Accuracy:** Platform average 58%+ (vs 52% baseline)
- **Time to First Value:** User generates first predictions within 10 minutes
- **Formula Marketplace Velocity:** 20+ new formulas shared weekly
- **Churn Rate:** Less than 10% monthly for paid users
- **Customer Acquisition Cost (CAC):** Under $20 per paid user
- **Net Promoter Score (NPS):** 40+ (users recommend to other punters)

## MVP Scope

### Core Features (Must Have)

- **Visual Formula Builder:** Drag-and-drop interface for selecting metrics (5-10 initial metrics like recent form, head-to-head, home advantage, weather) and defining relationships through sliders/weights
- **AFL Focus Only:** Single sport/league to prove concept with quality over quantity
- **Basic Backtesting:** Test formulas against last 2 seasons of historical data with accuracy percentage display
- **Predictions for Upcoming Round:** Generate winner predictions for all 9 games in the next AFL round
- **Formula Save/Load:** Users can save up to 5 formulas and modify them over time
- **Free Data Integration:** Use Squiggle API and AFL Tables for cost-effective data access
- **Mobile Web UI:** Responsive design that works on phones (where users check tips)
- **Simple Onboarding:** Get to first predictions in under 10 minutes without registration

### Out of Scope for MVP

- Formula marketplace/sharing features
- Multiple sports or leagues  
- Premium data sources (Champion Data metrics)
- Native mobile apps
- Payment processing/subscriptions
- Social features/following
- Advanced statistics (ELO ratings, Monte Carlo simulations)
- Custom metric creation
- API for third-party integration
- Detailed player-level predictions

### MVP Success Criteria

The MVP succeeds if we achieve:
- 1,000 registered users within 60 days
- 50% of users create at least one formula
- Average formula accuracy of 55%+ (beating random 50%)
- 100 weekly active users generating predictions
- User feedback validates core concept ("This is exactly what I wanted")
- Technical proof that formula builder scales

## Post-MVP Vision

### Phase 2 Features (Months 3-6)

**Formula Marketplace Launch**
- Public formula sharing with performance tracking
- User profiles with reputation scores based on formula success
- Follow/copy successful formula creators
- Comments and discussions on formulas

**Enhanced Analytics**
- Advanced metrics integration (disposals, contested possessions, metres gained)
- Multi-season backtesting with detailed performance graphs
- Head-to-head formula comparisons
- Confidence intervals on predictions

**Monetization Features**
- Premium tier with unlimited formulas and deeper historical data
- API-Sports integration for real-time data
- Email/SMS alerts for predictions
- Ad-free experience

### Long-term Vision (1-2 Years)

Transform from a single-sport prediction tool into a comprehensive "Prediction Platform as a Service" where users can apply formula-building methodology to any domain with available data. Become the WordPress of predictions - a platform where anyone can build, share, and monetize their analytical insights without coding.

Key developments:
- Multi-sport expansion (NRL, NBL, cricket, racing)
- International markets (NFL, Premier League)
- Non-sport domains (elections, reality TV, stock movements)
- White-label B2B offering for media companies
- AI-assisted formula suggestions based on successful patterns
- Educational content platform teaching analytical thinking

### Expansion Opportunities

**Geographic:** Asia-Pacific focus initially (similar sports culture), then Europe (football) and North America (fantasy sports integration)

**Partnership:** Integration with major tipping platforms (FootyTips acquisition target), official league partnerships, media company collaborations (Fox Sports, ESPN)

**Technology:** Natural language formula creation ("Teams that win more contested marks in wet weather"), voice-driven predictions (Alexa/Google Home), AR overlays during live games

**Revenue:** Formula creator revenue sharing, sponsored formulas from media personalities, enterprise analytics for professional teams, data marketplace for unique metrics

## Technical Considerations

### Platform Requirements

- **Target Platforms:** Mobile-first web application (PWA-ready for future app conversion)
- **Browser/OS Support:** Chrome, Safari, Firefox (last 2 versions); iOS 14+, Android 10+
- **Performance Requirements:** 
  - Formula calculations complete in <2 seconds
  - Backtesting results in <5 seconds for 2 seasons
  - Page load time <3 seconds on 4G
  - Support 10,000 concurrent users at launch

### Technology Preferences

- **Frontend:** React or Next.js for component reusability and mobile responsiveness; drag-and-drop library (react-beautiful-dnd or similar)
- **Backend:** Node.js with Express or FastAPI (Python) for formula calculation engine; RESTful API with potential GraphQL for complex queries
- **Database:** PostgreSQL for user data and formulas; Redis for caching predictions and backtesting results; Time-series DB (InfluxDB) for historical match data
- **Hosting/Infrastructure:** Azure (as specified) with App Service for web app; Azure Functions for serverless formula calculations; Azure Cosmos DB as alternative to PostgreSQL if global scale needed

### Architecture Considerations

- **Repository Structure:** Monorepo initially for faster development; frontend/ backend/ shared/ packages structure; Infrastructure as Code using Terraform
- **Service Architecture:** Start with modular monolith, prepare for microservices (formula engine, data ingestion, user management as separate services when scaling)
- **Integration Requirements:** 
  - Squiggle API (REST, public)
  - AFL Tables (web scraping with caching)
  - Future: API-Sports (REST, authenticated)
  - Future: Payment processors (Stripe)
  - Future: Social login (Google, Facebook)
- **Security/Compliance:** 
  - HTTPS everywhere
  - JWT-based authentication
  - Rate limiting on API endpoints
  - GDPR compliance for future EU expansion
  - Australian Privacy Principles adherence
  - No gambling transaction processing (reduces compliance burden)

## Constraints & Assumptions

### Constraints

- **Budget:** Bootstrap/self-funded initially; targeting <$10K for MVP development; seeking seed funding post-validation ($500K-1M)
- **Timeline:** MVP launch in 8-12 weeks; Phase 2 features by month 6; breakeven by month 12
- **Resources:** Small founding team (2-3 people); no dedicated data scientists initially; limited marketing budget (organic growth focus)
- **Technical:** 
  - Must use free/cheap data sources initially (no Champion Data)
  - Azure hosting costs must stay under $500/month for MVP
  - No native app development resources for first 6 months
  - Limited to publicly available metrics (no proprietary data)

### Key Assumptions

- **Free data sources (Squiggle, AFL Tables) provide sufficient metrics for viable predictions**
- **Users will trust formulas they build more than black-box AI, even if slightly less accurate**
- **AFL fans represent a large enough market for MVP validation (1M+ FootyTips users)**
- **Visual formula building can be intuitive enough for non-technical users**
- **Network effects from formula sharing will create defensible moat before competitors copy**
- **Freemium model will convert at 15-20% (industry standard for productivity tools)**
- **Regulatory environment won't require gambling licenses (not facilitating bets directly)**
- **Users willing to pay $20-50/month for premium features once value proven**
- **Mobile web experience sufficient (native apps not required for adoption)**
- **Patent protection possible for visual formula builder interface**

## Risks & Open Questions

### Key Risks

- **Fast Follower Risk:** FootyTips or Sportsbet could quickly copy the formula builder concept once proven, leveraging their existing user base to crush us
- **Data Quality Risk:** Free data sources may lack the depth/accuracy needed for formulas to meaningfully outperform random selection (killing the value prop)
- **User Complexity Risk:** Formula building might be too complex for average punters despite visual interface, limiting market to technical users only
- **Platform Dependence Risk:** Squiggle API or AFL Tables could shut down, charge for access, or rate-limit us, crippling the MVP
- **Regulatory Risk:** Gambling regulators might classify formula predictions as "inducement to bet," requiring expensive licenses
- **Formula Effectiveness Risk:** User-generated formulas might consistently underperform simple heuristics, destroying trust in the platform

### Open Questions

- **What percentage of FootyTips users actually want more control over predictions vs. simple convenience?**
- **Will users share their successful formulas or keep them secret for competitive advantage?**
- **How complex can formulas be before users get overwhelmed? (3 metrics? 5? 10?)**
- **Can natural language formula input be technically implemented without AI/NLP complexity?**
- **What's the minimum prediction accuracy improvement needed for users to perceive value?**
- **How do we handle formula gaming (users creating fake successful formulas to gain followers)?**
- **Should we allow negative weightings in formulas (e.g., "less tackles = better")?**

### Areas Needing Further Research

- **Legal research on gambling adjacency regulations in each Australian state**
- **Technical spike on drag-and-drop formula builders (existing libraries vs. custom)**
- **User interviews with FootyTips power users about prediction tool desires**
- **Analysis of which free metrics correlate most strongly with match outcomes**
- **Patent search for similar visual prediction builders**
- **Performance testing of formula calculations at scale (10K users simultaneously)**
- **Research on formula verification methods to prevent gaming/manipulation**

## Appendices

### A. Research Summary

**Market Research Findings:**
- AI sports market growing at 29.8% CAGR to $3.1B by 2025
- 1M+ Australians use FootyTips for AFL tipping competitions
- Average punter achieves only 50-55% prediction accuracy
- No existing platform offers user-built formula marketplaces

**Competitive Analysis Key Insights:**
- Direct competitors: None (completely new category)
- Adjacent threats: Rithmm ($30-100/mo AI predictions), OddsJam (arbitrage focus)
- Vulnerable incumbent: FootyTips (no analytics, ripe for disruption)
- Data moat: Champion Data controls premium AFL stats (expensive)

**User Research Priorities:**
- Validate assumption that punters want prediction control
- Test formula builder UX with non-technical users
- Confirm willingness to pay $20-50/month for premium features

### B. References

- Brainstorming Session Results: `/docs/brainstorming-session-results.md`
- Competitive Analysis: `/docs/competitor-analysis.md`
- Squiggle API Documentation: https://api.squiggle.com.au/
- AFL Tables Historical Data: https://afltables.com/
- Azure Pricing Calculator: https://azure.microsoft.com/pricing/calculator/

## Next Steps

### Immediate Actions

1. **Conduct 10 user interviews with FootyTips power users** to validate formula builder demand
2. **Create clickable prototype** of formula builder interface for user testing
3. **Technical spike on drag-and-drop implementation** using React libraries
4. **Legal consultation** on gambling regulations and platform classification
5. **File provisional patent** for visual formula builder concept
6. **Set up Azure infrastructure** and cost monitoring for MVP
7. **Begin data pipeline development** from Squiggle API

### PM Handoff

This Project Brief provides the full context for the User-Driven Sports Prediction Platform. Please start in 'PRD Generation Mode', review the brief thoroughly to work with the user to create the PRD section by section as the template indicates, asking for any necessary clarification or suggesting improvements.

Key areas requiring PM attention:
- Feature prioritization within MVP scope
- User story development for formula builder
- Sprint planning for 8-12 week MVP timeline
- Stakeholder communication strategy
- Risk mitigation planning for fast-follower threat

---

*Project Brief completed: 2025-08-28*
*Next review: Post user interview completion*