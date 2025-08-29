# Deployment Strategy - AFL Data Capture Platform

## Current Situation
✅ **Development environment deployed** - Costing ~**$44/month**
✅ **Production infrastructure removed** - Saving **$530/month**

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

## Current Deployment Status

### ✅ Completed Actions
1. **Development branch created** - `develop` branch is active
2. **Dev environment deployed** - Running on Azure with F1 tier
3. **Production resources removed** - Saving $530/month
4. **CI/CD pipeline working** - Automatic deployments to dev on push

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

## Current URLs

### Development Environment
- **Frontend**: https://afl-predictor-frontend-dev.azurewebsites.net
- **Backend**: https://afl-predictor-backend-dev.azurewebsites.net
- **Resource Group**: afl-predictor-rg-dev

## Next Steps

### Development Phase (Current)
1. Build application features on `develop` branch
2. Test in dev environment
3. Keep costs under $50/month

### Pre-Production Phase (When Ready)
1. Feature freeze on `develop`
2. Create staging environment if needed
3. Performance testing

### Production Launch (When Product Ready)
1. Merge `develop` to `main`
2. Deploy production infrastructure
3. Monitor costs daily
4. Destroy if not actively used

## Questions to Answer

1. **Do you need production at all right now?** Probably not!
2. **Can you use free tier for dev?** Yes, with local Docker
3. **When do you need production?** Only for actual users

## Contact for Help

If you see unexpected charges or need help:
1. Check Azure Cost Management immediately
2. Run destroy script if needed
3. Review this guide for proper branch usage