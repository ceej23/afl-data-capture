# Technology Stack

## Overview

This document details all technology choices for the AFL Data Capture Platform, including specific versions, justifications, and alternatives considered.

## Frontend Technologies

| Component | Technology | Version | Justification |
|-----------|------------|---------|---------------|
| **Framework** | Next.js | 14+ | Server-side rendering, optimal performance, React ecosystem, App Router for better DX |
| **UI Library** | React | 18+ | Component reusability, virtual DOM efficiency, industry standard, concurrent features |
| **Language** | TypeScript | 5+ | Type safety, better IDE support, reduced bugs, self-documenting code |
| **Styling** | Tailwind CSS | 3.4+ | Utility-first, consistent design system, small bundle, rapid development |
| **State Management** | Zustand | 4.5+ | Lightweight (8KB), TypeScript-first, minimal boilerplate, devtools support |
| **Drag & Drop** | @dnd-kit | 6.1+ | Accessible by default, performant, touch-friendly, keyboard support |
| **Data Fetching** | TanStack Query | 5.0+ | Intelligent caching, optimistic updates, background refetching, offline support |
| **Forms** | React Hook Form | 7.48+ | Minimal re-renders, built-in validation, TypeScript support |
| **Validation** | Zod | 3.22+ | Schema validation, TypeScript integration, runtime type checking |
| **Charts** | Recharts | 2.10+ | Responsive, customizable, React-native, good performance |
| **PWA** | next-pwa | 5.6+ | Service workers, offline capability, app-like experience |
| **Animation** | Framer Motion | 11.0+ | Smooth animations, gesture support, spring physics |
| **Icons** | Lucide React | 0.300+ | Tree-shakeable, TypeScript support, consistent design |

### Frontend Alternatives Considered

| Technology | Alternative | Reason Not Chosen |
|------------|-------------|-------------------|
| Next.js | Remix | Less mature ecosystem, smaller community |
| React | Vue.js | Smaller talent pool, less enterprise adoption |
| Zustand | Redux Toolkit | More boilerplate, steeper learning curve |
| @dnd-kit | react-beautiful-dnd | Not actively maintained, accessibility issues |
| Tailwind | CSS Modules | More development time, less consistency |
| Recharts | Victory | Larger bundle size, more complex API |

## Backend Technologies

| Component | Technology | Version | Justification |
|-----------|------------|---------|---------------|
| **Runtime** | Node.js | 20 LTS | Event-driven, JavaScript ecosystem, Azure support, LTS stability |
| **Framework** | Fastify | 4.25+ | High performance (30% faster than Express), schema validation, plugin ecosystem |
| **Language** | TypeScript | 5+ | Type safety, better IDE support, shared types with frontend |
| **API Documentation** | OpenAPI | 3.0 | Industry standard, auto-generated docs, client SDK generation |
| **Authentication** | JWT + Passport.js | Latest | Stateless, scalable, extensible strategies, industry standard |
| **Job Queue** | Bull MQ | 5.0+ | Redis-backed, reliable, dashboard included, good DX |
| **ORM** | Prisma | 5.7+ | Type-safe queries, migrations, connection pooling, great DX |
| **Validation** | Zod | 3.22+ | Schema validation, TypeScript integration, shared with frontend |
| **Testing** | Vitest | 1.1+ | Fast, Jest-compatible, native ESM support |
| **API Testing** | Supertest | 6.3+ | Express/Fastify testing, easy assertions |
| **Process Manager** | PM2 | 5.3+ | Process management, clustering, monitoring |

### Backend Alternatives Considered

| Technology | Alternative | Reason Not Chosen |
|------------|-------------|-------------------|
| Fastify | Express | Slower performance, less built-in features |
| Node.js | Deno | Less mature ecosystem, limited Azure support |
| Prisma | TypeORM | Less type safety, more complex API |
| Bull MQ | Agenda | Less reliable, fewer features |
| JWT | Sessions | Not stateless, harder to scale |

## Infrastructure Technologies

| Component | Technology | Version | Justification |
|-----------|------------|---------|---------------|
| **Cloud Provider** | Azure | - | Regional presence, managed services, cost optimization, enterprise support |
| **Compute** | App Service | - | Auto-scaling, managed platform, deployment slots, easy setup |
| **Container** | Docker | 24+ | Containerization, consistent environments, easy deployment |
| **Orchestration** | Azure Container Instances | - | Serverless containers, pay-per-second, no cluster management |
| **Database** | Azure Database for PostgreSQL | 15 | Managed, automatic backups, high availability, proven reliability |
| **Cache** | Azure Cache for Redis | 7.0+ | Managed, clustering support, persistence, high performance |
| **Storage** | Azure Blob Storage | - | Cost-effective, CDN integration, lifecycle policies |
| **CDN** | Azure Front Door | - | Global distribution, WAF, intelligent routing, DDoS protection |
| **Message Queue** | Azure Service Bus | - | Reliable messaging, dead-letter queues, topics/subscriptions |
| **Monitoring** | Application Insights | - | Deep integration, custom metrics, alerting, APM features |
| **Secrets** | Azure Key Vault | - | Centralized secrets, rotation, audit logs, HSM backing |
| **CI/CD** | GitHub Actions | - | Native GitHub integration, free for public repos, great marketplace |
| **IaC** | Terraform | 1.6+ | Multi-cloud support, declarative, state management, large community |

### Infrastructure Alternatives Considered

| Technology | Alternative | Reason Not Chosen |
|------------|-------------|-------------------|
| Azure | AWS | Less regional presence in Australia, more complex |
| PostgreSQL | MongoDB | Less suitable for relational data, ACID compliance |
| Redis | Memcached | Less features, no persistence |
| Terraform | ARM Templates | Azure-specific, less readable |

## Development Tools

| Category | Tool | Version | Purpose |
|----------|------|---------|---------|
| **Package Manager** | pnpm | 8.14+ | Faster installs, disk space efficient, strict dependencies |
| **Monorepo Tool** | Turborepo | 1.11+ | Build caching, parallel execution, incremental builds |
| **Code Quality** | ESLint | 8.56+ | Code linting, enforce standards, custom rules |
| **Formatting** | Prettier | 3.1+ | Consistent formatting, auto-fix, IDE integration |
| **Git Hooks** | Husky | 8.0+ | Pre-commit hooks, enforce quality, automate checks |
| **Commit Linting** | Commitlint | 18.4+ | Conventional commits, changelog generation |
| **Bundle Analyzer** | @next/bundle-analyzer | 14+ | Bundle size analysis, optimization insights |
| **API Testing** | Insomnia | - | API development, testing, documentation |

## Testing Stack

| Type | Tool | Version | Purpose |
|------|------|---------|---------|
| **Unit Testing** | Vitest | 1.1+ | Fast, Jest-compatible, native ESM |
| **React Testing** | Testing Library | 14+ | User-centric testing, accessibility |
| **E2E Testing** | Playwright | 1.40+ | Cross-browser, reliable, fast |
| **API Testing** | Supertest | 6.3+ | HTTP assertions, easy integration |
| **Load Testing** | k6 | 0.48+ | Performance testing, scriptable |
| **Accessibility** | axe-core | 4.8+ | Automated a11y testing |
| **Visual Regression** | Percy | - | Visual testing, CI integration |

## Security Tools

| Category | Tool | Purpose |
|----------|------|---------|
| **Dependency Scanning** | npm audit | Security vulnerability scanning |
| **Code Scanning** | Snyk | Advanced vulnerability detection |
| **Secret Scanning** | GitGuardian | Prevent secret leaks |
| **WAF** | Azure WAF | Web application firewall |
| **DDoS Protection** | Azure DDoS | DDoS mitigation |
| **SSL/TLS** | Let's Encrypt | Free SSL certificates |

## Data Pipeline Tools

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Web Scraping** | Playwright | Reliable scraping, handles JavaScript |
| **Data Validation** | Zod | Schema validation, type safety |
| **ETL** | Custom Node.js | Full control, cost-effective |
| **Scheduling** | node-cron | Simple, reliable scheduling |
| **Rate Limiting** | bottleneck | Respect API limits, prevent bans |

## Version Management Strategy

### Pinning Strategy

```json
{
  "dependencies": {
    "next": "14.1.0",           // Exact: Framework core
    "react": "^18.2.0",         // Minor: Stable library
    "tailwindcss": "~3.4.0",    // Patch: CSS framework
    "@dnd-kit/core": "^6.1.0",  // Minor: Feature library
    "zod": "^3.22.0"            // Minor: Validation
  }
}
```

### Update Policy

- **Security patches**: Immediate
- **Patch versions**: Weekly
- **Minor versions**: Bi-weekly
- **Major versions**: Quarterly planning

## Technology Evaluation Criteria

When evaluating new technologies, we consider:

1. **Performance**: Does it meet our speed requirements?
2. **Scalability**: Can it handle 10,000+ users?
3. **Cost**: Does it fit within budget constraints?
4. **Community**: Is there active development and support?
5. **Documentation**: Is it well-documented?
6. **Security**: Are there known vulnerabilities?
7. **Learning Curve**: Can the team adopt it quickly?
8. **Integration**: Does it work with our stack?
9. **Maintenance**: Long-term support and stability?
10. **License**: Compatible with our usage?

## Technology Sunset Plan

Technologies to phase out or upgrade:

| Technology | Timeline | Replacement | Reason |
|------------|----------|-------------|---------|
| Node.js 18 | Q2 2025 | Node.js 20 LTS | End of LTS |
| React 17 | Immediate | React 18 | Missing features |
| Express | Q1 2025 | Fastify | Performance |

## Cost Analysis

### Monthly Cost Breakdown

| Service | Cost | Percentage |
|---------|------|------------|
| Compute (App Service) | $150 | 30% |
| Database (PostgreSQL) | $100 | 20% |
| Cache (Redis) | $50 | 10% |
| Storage & CDN | $30 | 6% |
| Monitoring | $50 | 10% |
| Network | $70 | 14% |
| Reserve | $50 | 10% |
| **Total** | **$500** | **100%** |

## Technology Governance

### Approval Process

1. **Minor libraries**: Team lead approval
2. **Major libraries**: Architecture review
3. **Framework changes**: CTO approval
4. **Infrastructure**: Cost-benefit analysis required

### Evaluation Checklist

- [ ] Security audit completed
- [ ] Performance benchmarks met
- [ ] Cost analysis performed
- [ ] Team training planned
- [ ] Migration path defined
- [ ] Rollback plan created
- [ ] Documentation updated
- [ ] License verified

---

*Technology Stack Version 1.0 - Created 2025-08-28*