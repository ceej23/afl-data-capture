# Deployment Strategy - AFL Data Capture Platform

## Current Situation
⚠️ **WARNING**: Production infrastructure is currently deployed costing **$530/month**!

## Branch Strategy

### Development Environment (Low Cost)
- **Branch**: `develop`
- **Cost**: ~$44/month (or $0 with free tiers)
- **Trigger**: Push to `develop` branch
- **Resources**:
  - App Service: F1 Free or B1 Basic ($13/month)
  - PostgreSQL: B_Standard_B1ms ($15/month)
  - Redis: C0 Basic ($16/month)
  - Retention: 30 days logs

### Production Environment (High Cost)
- **Branch**: `main`
- **Cost**: ~$530/month ⚠️
- **Trigger**: Push to `main` branch
- **Resources**:
  - App Service: S2 Standard ($140/month)
  - PostgreSQL: GP_Standard_D2s_v3 ($250/month)
  - Redis: C1 Standard ($120/month)
  - Retention: 90 days logs

## IMMEDIATE ACTIONS REQUIRED

### 1. Destroy Expensive Production Resources
```bash
cd infrastructure/scripts
./destroy-infrastructure.sh prod
```
This will save you **$530/month** immediately!

### 2. Create Development Branch
```bash
# Create and switch to develop branch
git checkout -b develop

# Push to trigger dev deployment
git push origin develop
```

### 3. Update Default Branch (GitHub)
1. Go to: https://github.com/ceej23/afl-data-capture/settings
2. Change default branch from `main` to `develop`
3. This prevents accidental production deployments

## Recommended Workflow

### For Development (CHEAP - Daily Use)
```bash
# Always work on develop branch
git checkout develop
git add .
git commit -m "feat: your changes"
git push origin develop
```
**Cost**: $44/month or FREE with adjustments

### For Production (EXPENSIVE - Only When Ready)
```bash
# Only when ready for production
git checkout main
git merge develop
git push origin main
```
**Cost**: $530/month - DO NOT KEEP RUNNING!

## Free Tier Option (Development)

To run development for **$0/month**:

1. **Update dev.tfvars**:
```hcl
app_service_plan_sku = "F1"  # Free tier
# Comment out Redis (use local Docker instead)
# Comment out PostgreSQL (use local Docker instead)
```

2. **Use Docker Locally**:
```yaml
# docker-compose.yml already configured for:
- PostgreSQL (local)
- Redis (local)
```

3. **Deploy Only App Service**:
- Frontend: Free F1 tier
- Backend: Free F1 tier
- Total: $0/month

## Cost Comparison

| Environment | Current Setup | Free Option | Savings |
|------------|--------------|-------------|---------|
| Dev | $44/month | $0/month | $44/month |
| Prod | $530/month | Don't use! | $530/month |

## Monitoring Costs

Check your Azure costs:
1. Azure Portal → Cost Management
2. Set up budget alerts ($50 for dev, $0 for prod unless needed)
3. Review daily to avoid surprises

## Emergency Shutdown

If costs are rising unexpectedly:
```bash
# Destroy everything immediately
cd infrastructure/scripts
./destroy-infrastructure.sh prod  # For production
./destroy-infrastructure.sh dev   # For development
```

## Best Practices

1. **DEFAULT TO DEVELOP BRANCH** - Never work on main unless deploying to production
2. **DESTROY PROD IMMEDIATELY** - After testing, always destroy production
3. **USE LOCAL SERVICES** - PostgreSQL and Redis can run locally via Docker
4. **MONITOR COSTS DAILY** - Azure can surprise you with costs
5. **SET BUDGETS** - Configure Azure budget alerts

## Current Status & Next Steps

### Immediate (TODAY):
1. ❗ Run destroy script for production: `./destroy-infrastructure.sh prod`
2. Create develop branch: `git checkout -b develop`
3. Push to develop to create cheap dev environment

### Tomorrow:
1. Verify production resources are destroyed
2. Check Azure cost analysis
3. Configure budget alerts

### This Week:
1. Test application in dev environment
2. Optimize for free tier if possible
3. Document any additional cost savings

## Questions to Answer

1. **Do you need production at all right now?** Probably not!
2. **Can you use free tier for dev?** Yes, with local Docker
3. **When do you need production?** Only for actual users

## Contact for Help

If you see unexpected charges or need help:
1. Check Azure Cost Management immediately
2. Run destroy script if needed
3. Review this guide for proper branch usage