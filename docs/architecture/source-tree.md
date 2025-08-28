# Source Tree & Project Structure

## Overview

This document defines the complete project structure for the AFL Data Capture Platform, providing clear guidance on where code should be placed and how the project is organized.

## Root Directory Structure

```
afl-data-capture/
├── .github/                     # GitHub configuration
│   ├── workflows/              # CI/CD workflows
│   ├── dependabot.yml         # Dependency updates
│   └── pull_request_template.md
├── .bmad-core/                 # BMAD configuration
│   ├── agents/                # AI agents
│   ├── checklists/           # Quality checklists
│   ├── tasks/                # Task definitions
│   └── templates/            # Document templates
├── .vscode/                    # VS Code configuration
│   ├── settings.json
│   ├── extensions.json
│   └── launch.json
├── backend/                    # Backend services
├── docs/                       # Documentation
│   ├── architecture/         # Architecture docs
│   ├── prd/                  # Product requirements
│   ├── stories/              # User stories
│   └── qa/                   # QA documentation
├── frontend/                   # Frontend application
├── infrastructure/             # IaC and deployment
├── scripts/                    # Build and utility scripts
├── shared/                     # Shared code/types
├── tests/                      # E2E and integration tests
├── .env.example               # Environment variables template
├── .gitignore                 # Git ignore rules
├── docker-compose.yml         # Local development
├── package.json               # Root package.json
├── pnpm-workspace.yaml        # Monorepo configuration
├── README.md                  # Project documentation
└── turbo.json                 # Turborepo configuration
```

## Frontend Structure

```
frontend/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── (auth)/            # Auth group routes
│   │   │   ├── login/
│   │   │   ├── register/
│   │   │   └── layout.tsx
│   │   ├── (dashboard)/       # Protected routes
│   │   │   ├── formulas/
│   │   │   │   ├── page.tsx
│   │   │   │   ├── new/page.tsx
│   │   │   │   └── [id]/
│   │   │   │       ├── page.tsx
│   │   │   │       └── edit/page.tsx
│   │   │   ├── predictions/
│   │   │   ├── backtest/
│   │   │   └── layout.tsx
│   │   ├── api/               # API routes (BFF)
│   │   │   ├── auth/
│   │   │   └── formulas/
│   │   ├── layout.tsx         # Root layout
│   │   ├── page.tsx           # Home page
│   │   └── global.css         # Global styles
│   │
│   ├── components/
│   │   ├── ui/                # Base UI components
│   │   │   ├── Button/
│   │   │   ├── Input/
│   │   │   ├── Card/
│   │   │   └── Modal/
│   │   ├── formula/           # Formula components
│   │   │   ├── FormulaBuilder/
│   │   │   ├── MetricCard/
│   │   │   └── WeightSlider/
│   │   ├── predictions/       # Prediction components
│   │   ├── layout/           # Layout components
│   │   └── shared/           # Shared components
│   │
│   ├── hooks/                 # Custom React hooks
│   ├── stores/               # Zustand stores
│   ├── services/             # API services
│   ├── lib/                  # Utilities
│   ├── types/                # TypeScript types
│   └── styles/               # Additional styles
│
├── public/                    # Static assets
│   ├── images/
│   ├── fonts/
│   └── manifest.json
│
├── tests/                     # Frontend tests
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── .env.local                # Local environment
├── next.config.js            # Next.js configuration
├── package.json              # Frontend dependencies
├── tailwind.config.js        # Tailwind configuration
└── tsconfig.json             # TypeScript configuration
```

## Backend Structure

```
backend/
├── src/
│   ├── services/             # Microservices
│   │   ├── formula/          # Formula service
│   │   │   ├── api/
│   │   │   │   ├── routes/
│   │   │   │   ├── controllers/
│   │   │   │   └── middleware/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── services/
│   │   │   │   └── repositories/
│   │   │   ├── infrastructure/
│   │   │   │   ├── database/
│   │   │   │   ├── cache/
│   │   │   │   └── messaging/
│   │   │   ├── application/
│   │   │   │   ├── commands/
│   │   │   │   ├── queries/
│   │   │   │   └── events/
│   │   │   └── index.ts
│   │   │
│   │   ├── prediction/       # Prediction service
│   │   ├── backtest/        # Backtest service
│   │   ├── user/            # User service
│   │   └── gateway/         # API gateway
│   │
│   ├── pipeline/            # Data pipeline
│   │   ├── ingestion/
│   │   ├── transformation/
│   │   └── distribution/
│   │
│   ├── shared/              # Shared code
│   │   ├── database/
│   │   ├── cache/
│   │   ├── messaging/
│   │   ├── errors/
│   │   └── utils/
│   │
│   └── config/              # Configuration
│       ├── database.ts
│       ├── redis.ts
│       └── services.ts
│
├── prisma/                  # Database schema
│   ├── schema.prisma
│   ├── migrations/
│   └── seed.ts
│
├── tests/                   # Backend tests
│   ├── unit/
│   ├── integration/
│   └── fixtures/
│
├── .env                     # Environment variables
├── package.json            # Backend dependencies
├── tsconfig.json           # TypeScript config
└── vitest.config.ts        # Test configuration
```

## Infrastructure Structure

```
infrastructure/
├── terraform/              # Terraform IaC
│   ├── environments/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── production/
│   ├── modules/
│   │   ├── app-service/
│   │   ├── database/
│   │   ├── redis/
│   │   └── networking/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── kubernetes/            # K8s manifests (future)
│   ├── deployments/
│   ├── services/
│   └── configmaps/
│
├── docker/               # Docker configuration
│   ├── frontend.Dockerfile
│   ├── backend.Dockerfile
│   └── nginx.conf
│
└── scripts/              # Deployment scripts
    ├── deploy.sh
    ├── rollback.sh
    └── health-check.sh
```

## Shared Code Structure

```
shared/
├── types/                # Shared TypeScript types
│   ├── formula.ts
│   ├── prediction.ts
│   ├── user.ts
│   └── api.ts
│
├── constants/           # Shared constants
│   ├── metrics.ts
│   └── limits.ts
│
├── validators/          # Shared validators
│   ├── formula.ts
│   └── user.ts
│
└── package.json        # Shared package
```

## File Naming Conventions

### TypeScript/JavaScript Files

```typescript
// Components (PascalCase)
FormulaBuilder.tsx
MetricCard.tsx

// Hooks (camelCase with 'use' prefix)
useFormula.ts
useAuth.ts

// Services (camelCase)
formulaService.ts
apiClient.ts

// Types (PascalCase with suffix)
Formula.types.ts
User.interface.ts

// Tests (same name with suffix)
FormulaBuilder.test.tsx
formulaService.test.ts

// Stories (same name with suffix)
Button.stories.tsx
```

### Directory Naming

```
// Feature directories (kebab-case)
formula-builder/
user-profile/

// Domain directories (singular)
formula/
prediction/
user/

// Utility directories (plural or descriptive)
hooks/
utils/
services/
```

## Import Path Aliases

### Frontend (tsconfig.json)

```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@hooks/*": ["./src/hooks/*"],
      "@services/*": ["./src/services/*"],
      "@stores/*": ["./src/stores/*"],
      "@types/*": ["./src/types/*"],
      "@lib/*": ["./src/lib/*"]
    }
  }
}
```

### Backend (tsconfig.json)

```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"],
      "@services/*": ["./src/services/*"],
      "@shared/*": ["./src/shared/*"],
      "@config/*": ["./src/config/*"],
      "@pipeline/*": ["./src/pipeline/*"]
    }
  }
}
```

## Environment Files

### Development

```bash
# .env.local (frontend)
NEXT_PUBLIC_API_URL=http://localhost:3001
NEXT_PUBLIC_WS_URL=ws://localhost:3002

# .env (backend)
NODE_ENV=development
DATABASE_URL=postgresql://user:pass@localhost:5432/afl_dev
REDIS_URL=redis://localhost:6379
```

### Production

```bash
# Managed by Azure Key Vault
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
JWT_SECRET=...
API_KEYS=...
```

## Build Output Structure

```
dist/                    # Build output
├── frontend/           # Next.js build
│   ├── .next/
│   └── out/           # Static export
├── backend/           # Compiled backend
│   ├── services/
│   └── pipeline/
└── shared/            # Compiled shared
```

## Testing Structure

```
tests/
├── unit/              # Unit tests
│   ├── frontend/
│   └── backend/
├── integration/       # Integration tests
│   ├── api/
│   └── database/
├── e2e/              # End-to-end tests
│   ├── specs/
│   └── fixtures/
└── performance/      # Performance tests
    ├── load/
    └── stress/
```

## Documentation Structure

```
docs/
├── architecture/     # Architecture documentation
│   ├── index.md
│   ├── system-design.md
│   └── ...
├── api/             # API documentation
│   ├── openapi.yaml
│   └── postman/
├── guides/          # Development guides
│   ├── getting-started.md
│   ├── deployment.md
│   └── troubleshooting.md
└── adr/             # Architecture Decision Records
    ├── 001-microservices.md
    └── 002-event-driven.md
```

## Git Branch Structure

```
main                 # Production branch
├── develop         # Development branch
│   ├── feature/*  # Feature branches
│   ├── bugfix/*   # Bug fix branches
│   └── chore/*    # Maintenance branches
├── release/*       # Release branches
└── hotfix/*        # Hotfix branches
```

## CI/CD Pipeline Files

```
.github/workflows/
├── ci.yml          # Continuous Integration
├── cd-staging.yml  # Deploy to staging
├── cd-prod.yml     # Deploy to production
├── security.yml    # Security scanning
└── dependency.yml  # Dependency updates
```

## Code Organization Best Practices

1. **Single Responsibility**: Each file should have one clear purpose
2. **Co-location**: Keep related files together
3. **Barrel Exports**: Use index.ts for clean imports
4. **Consistent Naming**: Follow naming conventions strictly
5. **Shallow Nesting**: Avoid deep directory nesting (max 4 levels)
6. **Feature Folders**: Organize by feature, not file type
7. **Shared Code**: Extract truly shared code to shared/
8. **Test Proximity**: Keep tests close to source code
9. **Documentation**: Include README.md in complex directories
10. **Clean Imports**: Use path aliases for cleaner imports

---

*Source Tree Version 1.0 - Created 2025-08-28*