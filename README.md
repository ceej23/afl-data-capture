# AFL Data Capture Platform

A comprehensive platform for AFL match predictions and data analysis using custom formulas and machine learning.

## 🏗 Tech Stack

- **Frontend**: Next.js 14+, React 18+, TypeScript 5+, Tailwind CSS 3.4+
- **Backend**: Node.js 20 LTS, Fastify 4.25+, TypeScript 5+
- **Database**: PostgreSQL 15, Redis 7.0+
- **Infrastructure**: Azure App Service, Azure Database for PostgreSQL, Azure Cache for Redis
- **Monorepo**: pnpm 8.14+, Turborepo 1.11+

## 📋 Prerequisites

- Node.js 20 LTS or higher
- pnpm 8.14 or higher
- Docker and Docker Compose (for local development)
- Git

## 🚀 Getting Started

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-org/afl-data-capture.git
cd afl-data-capture
```

2. Install dependencies:
```bash
pnpm install
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Start the development environment:
```bash
pnpm dev
```

The application will be available at:
- Frontend: http://localhost:3000
- Backend: http://localhost:3001

## 📦 Project Structure

```
afl-data-capture/
├── frontend/          # Next.js application
├── backend/           # Node.js microservices
├── shared/            # Shared TypeScript types
├── infrastructure/    # Terraform/IaC
├── scripts/           # Build and utility scripts
├── docs/              # Documentation
└── tests/             # E2E and integration tests
```

## 🛠 Available Scripts

- `pnpm dev` - Start all services in development mode
- `pnpm build` - Build all packages
- `pnpm test` - Run tests across all packages
- `pnpm lint` - Lint all packages
- `pnpm type-check` - Type check all packages
- `pnpm format` - Format code with Prettier

## 🔧 Development Workflow

1. Create a feature branch:
```bash
git checkout -b feature/your-feature-name
```

2. Make your changes and commit:
```bash
git add .
git commit -m "feat: your feature description"
```

3. Push and create a pull request:
```bash
git push origin feature/your-feature-name
```

## 📝 Documentation

- [Architecture Documentation](./docs/architecture/index.md)
- [Product Requirements](./docs/prd.md)
- [API Specification](./docs/architecture/api-specification.md)
- [Security Guide](./docs/architecture/security.md)

## 🧪 Testing

Run tests with:
```bash
pnpm test
```

For coverage reports:
```bash
pnpm test:coverage
```

## 🚢 Deployment

Deployments are automated through CI/CD pipelines:
- **Development**: Auto-deploy on merge to `develop`
- **Staging**: Auto-deploy with approval gate
- **Production**: Manual approval required

## 🤝 Contributing

Please read our [Contributing Guidelines](./CONTRIBUTING.md) before submitting PRs.

## 📄 License

This project is private and proprietary.

---

Built with ❤️ by the AFL Data Capture Team