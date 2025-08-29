# GitHub Branch Protection Configuration

## Overview
This document provides step-by-step instructions for configuring branch protection rules in GitHub to ensure safe deployments and prevent accidental production changes.

## Required Branch Protection Rules

### 1. Protect `main` Branch (Production)

Navigate to: `Settings > Branches > Add rule`

**Branch name pattern:** `main`

**Protection settings:**
- ✅ Require a pull request before merging
  - ✅ Require approvals: 1
  - ✅ Dismiss stale pull request approvals when new commits are pushed
  - ✅ Require review from CODEOWNERS (optional)
- ✅ Require status checks to pass before merging
  - ✅ Require branches to be up to date before merging
  - **Required status checks:**
    - `test` (from CI/CD workflow)
- ✅ Require conversation resolution before merging
- ✅ Include administrators
- ✅ Restrict who can push to matching branches
  - Add specific users/teams who can deploy to production

**Why:** Prevents direct pushes to production, ensures all changes are reviewed and tested.

### 2. Protect `develop` Branch (Development)

Navigate to: `Settings > Branches > Add rule`

**Branch name pattern:** `develop`

**Protection settings:**
- ✅ Require a pull request before merging
  - ✅ Require approvals: 1 (can be 0 for faster development)
  - ✅ Dismiss stale pull request approvals when new commits are pushed
- ✅ Require status checks to pass before merging
  - **Required status checks:**
    - `test` (from CI/CD workflow)
- ⬜ Include administrators (optional - allows admins to push directly)

**Why:** Ensures all features are tested before integration, while allowing more flexibility than production.

## GitHub Environments Configuration

### 1. Development Environment

Navigate to: `Settings > Environments > New environment`

**Name:** `development`

**Protection rules:**
- No additional protection needed
- Auto-deploys from `develop` branch

**Environment secrets:**
- Can use default/dev values for most secrets
- Cost: ~$44/month or $0 with free tier

### 2. Production Environment

Navigate to: `Settings > Environments > New environment`

**Name:** `production`

**Protection rules:**
- ✅ Required reviewers
  - Add yourself and any other authorized deployers
  - This creates a manual approval gate
- ✅ Deployment branches
  - Selected branches: `main`

**Environment secrets:**
- `DB_ADMIN_PASSWORD` (required - no default)
- `JWT_ACCESS_SECRET` (required - no default)
- `JWT_REFRESH_SECRET` (required - no default)
- `ALERT_EMAIL` (required - real email for alerts)

**Cost warning:** $530/month when deployed!

## Setting Up Protection Rules

### Step 1: Navigate to Repository Settings
```
https://github.com/ceej23/afl-data-capture/settings
```

### Step 2: Configure Default Branch
1. Go to `Settings > General`
2. Under "Default branch", change from `main` to `develop`
3. This prevents accidental production work

### Step 3: Create Branch Protection Rules
1. Go to `Settings > Branches`
2. Click "Add rule"
3. Configure as described above for both `main` and `develop`

### Step 4: Set Up Environments
1. Go to `Settings > Environments`
2. Create `development` and `production` environments
3. Add protection rules as described above

### Step 5: Configure Required Secrets
Go to `Settings > Secrets and variables > Actions`

**Repository secrets needed:**
- `AZURE_CREDENTIALS` - Already set up
- `DB_ADMIN_USERNAME` - Optional, defaults to 'afladmin'

**Environment-specific secrets:**

For `production` environment:
- `DB_ADMIN_PASSWORD` - Strong password for production DB
- `JWT_ACCESS_SECRET` - Long random string for JWT signing
- `JWT_REFRESH_SECRET` - Different long random string
- `ALERT_EMAIL` - Real email for production alerts

For `development` environment:
- All can use defaults from the workflow

## Verification Checklist

After setting up protection rules, verify:

- [ ] Cannot push directly to `main`
- [ ] Cannot push directly to `develop` (if configured)
- [ ] Pull requests to `main` require approval
- [ ] Pull requests to `main` require passing tests
- [ ] Production deployment requires manual approval
- [ ] Development deployment happens automatically on push to `develop`
- [ ] Feature branches can be created and pushed without restrictions

## Testing the Setup

### 1. Test Feature Branch Flow
```bash
git checkout develop
git checkout -b feature/test-protection
echo "test" > test.txt
git add test.txt
git commit -m "test: branch protection"
git push origin feature/test-protection
# Create PR to develop - should require tests to pass
```

### 2. Test Development Deployment
```bash
# After PR is merged to develop
# Check GitHub Actions - should auto-deploy to dev environment
# No manual approval needed
```

### 3. Test Production Protection
```bash
# Try to push directly to main (should fail)
git checkout main
echo "test" > test.txt
git add test.txt
git commit -m "test: direct push"
git push origin main
# Should get error: protected branch
```

### 4. Test Production Deployment
```bash
# Create PR from develop to main
# Requires approval
# After merge, requires manual environment approval
# Check deployment gate in GitHub Actions
```

## Common Issues and Solutions

### Issue: Developers can't create feature branches
**Solution:** Make sure branch protection only applies to `main` and `develop`, not `*` or `**/*`

### Issue: CI/CD fails with permission errors
**Solution:** Check that `AZURE_CREDENTIALS` secret is properly set

### Issue: Production deploys without approval
**Solution:** Verify environment protection rules are configured for `production` environment

### Issue: Can't push to develop even with PR
**Solution:** Check if "Include administrators" is checked - uncheck for develop if needed

## Best Practices

1. **Never bypass protection rules** - They exist for safety
2. **Use feature branches** - Always create feature/* branches for new work
3. **Keep PRs small** - Easier to review and less risky
4. **Test locally first** - Run tests before pushing
5. **Review deployment costs** - Production costs $530/month!
6. **Use preview deployments** - Test features before merging
7. **Clean up old branches** - Delete merged feature branches

## Emergency Procedures

### If you need to hotfix production:
1. Create `hotfix/*` branch from `main`
2. Make minimal fix
3. Create PR to `main`
4. After merge, backport to `develop`

### If production deployment is stuck:
1. Check GitHub Actions logs
2. Cancel workflow if needed
3. Fix issue in `develop` first
4. Test thoroughly before attempting production again

### To temporarily disable protection:
1. Go to Settings > Branches
2. Edit rule
3. Uncheck protections (remember to re-enable!)

## Cost Management Reminder

- **Development**: $44/month (or $0 with free tier)
- **Production**: $530/month - ONLY deploy when needed!
- **Always destroy production after testing!**

```bash
# Destroy production to save money
cd infrastructure/scripts
./destroy-infrastructure.sh prod
```