# Contributing to AFL Data Capture Platform

Thank you for your interest in contributing to the AFL Data Capture Platform! This guide will help you get started.

## 🚀 Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/afl-data-capture.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Commit using conventional commits
6. Push to your fork
7. Create a Pull Request

## 📋 Prerequisites

- Node.js 20 LTS or higher
- pnpm 8.14 or higher
- Docker and Docker Compose
- Git

## 🛠 Development Setup

1. Install dependencies:
```bash
pnpm install
```

2. Copy environment files:
```bash
cp .env.example .env
cp frontend/.env.local.example frontend/.env.local
cp backend/.env.example backend/.env
```

3. Start local services:
```bash
docker-compose up -d
```

4. Run development servers:
```bash
pnpm dev
```

## 📝 Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/). Format:

```
type(scope): subject

body

footer
```

### Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes

### Examples:
```bash
feat(formula): add drag-and-drop formula builder
fix(predictions): correct confidence score calculation
docs(readme): update installation instructions
```

## 🧪 Testing

Run all tests:
```bash
pnpm test
```

Run tests with coverage:
```bash
pnpm test:coverage
```

Run specific package tests:
```bash
pnpm --filter=frontend test
pnpm --filter=backend test
```

## 📊 Code Quality

### Linting
```bash
pnpm lint
```

### Type Checking
```bash
pnpm type-check
```

### Formatting
```bash
pnpm format
```

## 🏗 Project Structure

```
afl-data-capture/
├── frontend/       # Next.js application
├── backend/        # Fastify microservices
├── shared/         # Shared types and utilities
├── infrastructure/ # IaC and deployment
└── docs/          # Documentation
```

## 📐 Coding Standards

Please follow our [Coding Standards](./docs/architecture/coding-standards.md):

- Use TypeScript with strict mode
- Follow ESLint and Prettier configurations
- Write tests for new features
- Keep functions small and focused
- Use meaningful variable names
- Add JSDoc comments for public APIs

## 🔄 Pull Request Process

1. **Update Documentation**: Update README.md and relevant docs
2. **Add Tests**: Include unit tests for new functionality
3. **Pass CI**: Ensure all CI checks pass
4. **Code Review**: Address reviewer feedback
5. **Squash Commits**: Keep history clean

### PR Title Format
```
type(scope): brief description
```

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No console.logs left
- [ ] No commented code
```

## 🐛 Reporting Issues

Use GitHub Issues with:
- Clear title
- Description of the problem
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Environment details

## 💡 Suggesting Features

Open a GitHub Issue with:
- Feature description
- Use case
- Proposed implementation
- Alternatives considered

## 📚 Resources

- [Architecture Documentation](./docs/architecture/index.md)
- [API Specification](./docs/architecture/api-specification.md)
- [Tech Stack](./docs/architecture/tech-stack.md)
- [Security Guide](./docs/architecture/security.md)

## 🤝 Code of Conduct

Please be respectful and professional in all interactions.

## 📄 License

By contributing, you agree that your contributions will be licensed under the project's license.

## 🙏 Thank You!

Your contributions help make this project better for everyone!