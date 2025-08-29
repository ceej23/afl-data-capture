# Azure Deployment Guide

## Prerequisites

1. Azure CLI installed
2. Terraform installed (v1.5.7+)
3. Node.js 20+ installed
4. GitHub repository admin access

## Quick Start

### 1. Create Azure Service Principal

Run the provided script to create a service principal:

```bash
cd scripts
./create-service-principal.sh
```

This will output JSON credentials needed for GitHub Actions.

### 2. Configure GitHub Secrets

1. Go to: https://github.com/ceej23/afl-data-capture/settings/secrets/actions
2. Add new repository secret: `AZURE_CREDENTIALS`
3. Paste the JSON output from step 1
4. Click "Add secret"

### 3. Deploy Infrastructure

#### Option A: Manual Deployment
```bash
cd scripts
./deploy.sh dev  # For development
./deploy.sh prod # For production
```

#### Option B: GitHub Actions
- Push to `develop` branch → Deploys to dev environment
- Push to `main` branch → Deploys to production environment

## Azure Resources Created

### Development Environment
- Resource Group: `afl-data-capture-dev`
- App Service Plan: `afl-data-capture-plan-dev` (Free F1 tier)
- Frontend: `afl-data-capture-frontend-dev.azurewebsites.net`
- Backend: `afl-data-capture-backend-dev.azurewebsites.net`
- PostgreSQL: `afl-data-capture-db-dev` (B_Standard_B1ms)
- Redis Cache: `afl-data-capture-cache-dev` (C0 Basic)
- Key Vault: `afl-data-vault-dev`
- Application Insights: `afl-data-capture-insights-dev`

### Production Environment
- Resource Group: `afl-data-capture-prod`
- App Service Plan: `afl-data-capture-plan-prod` (S1 Standard)
- Frontend: `afl-data-capture-frontend-prod.azurewebsites.net`
- Backend: `afl-data-capture-backend-prod.azurewebsites.net`
- PostgreSQL: `afl-data-capture-db-prod` (B_Standard_B2s)
- Redis Cache: `afl-data-capture-cache-prod` (C1 Basic)
- Key Vault: `afl-data-vault-prod`
- Application Insights: `afl-data-capture-insights-prod`

## CI/CD Pipeline

The GitHub Actions workflow (`/.github/workflows/ci-cd.yml`) provides:

1. **On Pull Request**: Run tests and Terraform plan
2. **On Push to develop**: Deploy to development
3. **On Push to main**: Deploy to production with staging slot

### Pipeline Stages

1. **Test**: Runs linting, tests, and builds
2. **Terraform Plan**: Shows infrastructure changes (PR only)
3. **Deploy Dev**: Deploys to development environment
4. **Deploy Prod**: Blue-green deployment using staging slots

## Environment Variables

### Required GitHub Secrets
- `AZURE_CREDENTIALS`: Service principal credentials (JSON)

### Optional Secrets
- `AZURE_SUBSCRIPTION_ID`: c6fdd64b-f4ef-404f-aa8d-2b013bcd03ee
- `AZURE_TENANT_ID`: 51e77625-3a01-45a4-9802-5285304ceb71

## Cost Estimates

### Development (Minimal)
- **Monthly**: $0-13
- Uses free tiers where possible
- Consider local Docker for databases

### Development (Full Azure)
- **Monthly**: ~$44
- All services in Azure
- Suitable for team development

### Production
- **Monthly**: ~$170
- High availability
- Auto-scaling enabled
- Full monitoring

## Monitoring

Access Application Insights:
1. Go to Azure Portal
2. Navigate to your resource group
3. Open Application Insights resource
4. View metrics, logs, and alerts

## Troubleshooting

### Service Principal Issues
```bash
# Verify service principal
az ad sp list --display-name "afl-data-capture-sp"

# Reset credentials if needed
az ad sp credential reset --name "afl-data-capture-sp"
```

### Deployment Failures
```bash
# Check deployment logs
az webapp log tail --name afl-data-capture-frontend-dev --resource-group afl-data-capture-dev

# Check Terraform state
cd infrastructure/terraform
terraform show
```

### Connection Issues
```bash
# Test endpoints
curl https://afl-data-capture-frontend-dev.azurewebsites.net
curl https://afl-data-capture-backend-dev.azurewebsites.net/health
```

## Security Best Practices

1. **Rotate Secrets**: Rotate service principal secrets every 90 days
2. **Use Key Vault**: Store all secrets in Azure Key Vault
3. **Enable HTTPS**: Always use HTTPS endpoints
4. **Least Privilege**: Grant minimal required permissions
5. **Audit Logs**: Enable and monitor audit logs

## Next Steps

1. Create service principal using the script
2. Add GitHub secret
3. Deploy to development environment
4. Verify deployment
5. Configure production when ready

## Support

For issues or questions:
- Check Azure Portal for resource status
- Review GitHub Actions logs
- Check Application Insights for errors