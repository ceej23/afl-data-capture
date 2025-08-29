# Branching and Environment Strategy

## Overview
This document outlines the proper branching strategy that separates feature development from environment deployments.

## Branch Types

### Protected Branches
- **main**: Production-ready code only
- **develop**: Integration branch for features

### Working Branches
- **feature/\***: New features
- **bugfix/\***: Bug fixes
- **hotfix/\***: Emergency production fixes

## Environment Mapping

| Environment | Deployed From | Trigger | Purpose |
|------------|--------------|---------|---------|
| Development | develop branch | Push to develop | Integration testing |
| Staging | develop branch | Manual/Tag | Pre-production testing |
| Production | main branch | Push to main | Live environment |

## Workflow Examples

### 1. New Feature Development
```bash
# Start from develop
git checkout develop
git pull origin develop
git checkout -b feature/add-prediction-model

# Work on feature
git add .
git commit -m "feat: add prediction model"
git push origin feature/add-prediction-model

# Create Pull Request
# feature/add-prediction-model → develop
# This triggers CI tests but NO deployment
```

### 2. Deploy to Development
```bash
# After PR approval and merge
# develop branch is updated
# This triggers DEV deployment automatically
```

### 3. Deploy to Production
```bash
# Create PR from develop to main
# After approval and merge
# main branch is updated
# This triggers PROD deployment automatically
```

### 4. Hotfix (Emergency Production Fix)
```bash
# Start from main for emergency fix
git checkout main
git pull origin main
git checkout -b hotfix/critical-bug

# Fix the bug
git add .
git commit -m "fix: resolve critical bug"
git push origin hotfix/critical-bug

# Create TWO Pull Requests:
# 1. hotfix/critical-bug → main (deploy fix to prod)
# 2. hotfix/critical-bug → develop (backport fix)
```

## CI/CD Pipeline Behavior

### Feature Branches (feature/*, bugfix/*)
- ✅ Run tests
- ✅ Run linting
- ✅ Build validation
- ❌ NO deployment

### Develop Branch
- ✅ Run tests
- ✅ Run linting
- ✅ Build validation
- ✅ Deploy to DEV environment

### Main Branch
- ✅ Run tests
- ✅ Run linting
- ✅ Build validation
- ✅ Deploy to STAGING (if configured)
- ✅ Deploy to PROD

## Best Practices

### 1. Never Commit Directly to Protected Branches
```bash
# Bad
git checkout develop
git commit -m "quick fix"
git push

# Good
git checkout -b bugfix/quick-fix
git commit -m "fix: resolve issue"
git push origin bugfix/quick-fix
# Create PR
```

### 2. Keep Feature Branches Small
- One feature per branch
- Merge frequently to avoid conflicts
- Delete branches after merge

### 3. Use Conventional Commits
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `style:` Formatting
- `refactor:` Code restructuring
- `test:` Adding tests
- `chore:` Maintenance

### 4. Regular Syncing
```bash
# Keep feature branch updated
git checkout feature/my-feature
git pull origin develop
# Resolve any conflicts
```

## Environment Variables per Environment

### Development (.env.development)
```
NODE_ENV=development
API_URL=https://afl-predictor-backend-dev.azurewebsites.net
DATABASE_URL=postgresql://dev-connection
```

### Production (.env.production)
```
NODE_ENV=production
API_URL=https://afl-predictor-backend-prod.azurewebsites.net
DATABASE_URL=postgresql://prod-connection
```

## Deployment Triggers Summary

| Action | Result |
|--------|--------|
| Push to feature/* | Tests only, no deployment |
| PR to develop | Tests only, no deployment |
| Merge to develop | Deploy to DEV |
| PR to main | Tests only, no deployment |
| Merge to main | Deploy to PROD |

## Common Scenarios

### Q: I want to test my feature branch
**A:** Create PR to develop. After merge, it deploys to DEV.

### Q: Multiple developers working simultaneously?
**A:** Each creates feature branches. All merge to develop for integration testing.

### Q: How to prevent accidental production deployment?
**A:** 
- Protect main branch
- Require PR reviews
- Use GitHub branch protection rules

### Q: Feature is in DEV but not ready for PROD?
**A:** That's fine! Features accumulate in develop until ready for release.

### Q: Need to test specific feature in isolation?
**A:** Consider preview environments (deploy feature branches temporarily).

## Migration from Current Setup

To implement this properly:

1. **Update GitHub Settings**
   - Protect main and develop branches
   - Require PR reviews
   - Require status checks

2. **Update CI/CD Pipeline**
   - Add conditions to skip deployment for feature branches
   - Add staging environment (optional)

3. **Team Training**
   - Document the flow
   - Create PR templates
   - Set up branch naming conventions

## Tools to Consider

- **GitHub Flow**: Simpler (feature → main)
- **GitFlow**: More complex (includes release branches)
- **GitHub Environments**: For deployment approvals
- **Preview Environments**: For feature branch testing