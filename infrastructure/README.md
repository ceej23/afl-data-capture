# AFL Predictor - Azure Infrastructure

This directory contains all Infrastructure as Code (IaC) and deployment configurations for the AFL Predictor platform.

## 📁 Directory Structure

```
infrastructure/
├── terraform/              # Terraform IaC configurations
│   ├── main.tf            # Core Azure resources
│   ├── database.tf        # PostgreSQL and Redis
│   ├── monitoring.tf      # Application Insights and alerts
│   ├── variables.tf       # Input variables
│   ├── outputs.tf         # Output values
│   └── environments/      # Environment-specific configs
│       ├── dev.tfvars     # Development (F1 tier, $44/month)
│       └── prod.tfvars    # Production (S2 tier, $530/month)
├── azure-devops/          # Legacy Azure DevOps pipeline
│   └── azure-pipelines.yml
└── scripts/               # Deployment and utility scripts
    ├── deploy-azure.sh         # Manual deployment script
    ├── destroy-azure-resources.sh  # Destroy by environment
    ├── destroy-infrastructure.sh   # Terraform destroy
    ├── rollback.sh            # Emergency rollback
    └── setup-terraform-backend.sh  # Backend configuration
```

## 🚀 Current Status

| Environment | Status | Resource Group | Monthly Cost | URL |
|------------|--------|---------------|--------------|-----|
| Development | ✅ Deployed | afl-predictor-rg-dev | ~$44 | [Frontend](https://afl-predictor-frontend-dev.azurewebsites.net) |
| Production | ❌ Not Deployed | afl-predictor-rg-prod | $0 | N/A |

## 🔧 Deployment Methods

### Method 1: GitHub Actions (Recommended)
The CI/CD pipeline automatically deploys on push:
- `develop` branch → Development environment
- `main` branch → Production environment (requires approval)

### Method 2: Manual Terraform Deployment
```bash
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Deploy development
terraform apply -var-file="environments/dev.tfvars"

# Deploy production (WARNING: $530/month)
terraform apply -var-file="environments/prod.tfvars"
```

### Method 3: Script Deployment
```bash
cd infrastructure/scripts

# Deploy to development
./deploy-azure.sh dev

# Deploy to production (WARNING: $530/month)
./deploy-azure.sh prod
```

## 💰 Cost Management

### Environment Costs
| Resource | Development | Production |
|----------|------------|------------|
| App Service Plan | F1 Free ($0) | S2 Standard ($140) |
| PostgreSQL | B_Standard_B1ms ($15) | GP_Standard_D2s_v3 ($250) |
| Redis Cache | Basic C0 ($16) | Standard C1 ($120) |
| Application Insights | Basic ($5) | Standard ($20) |
| Key Vault | ~$1 | ~$2 |
| **Total** | **~$44/month** | **~$530/month** |

### Cost Control Scripts
```bash
# Destroy development environment
./destroy-azure-resources.sh dev

# Destroy production environment
./destroy-azure-resources.sh prod

# Check if resource group exists
az group exists --name afl-predictor-rg-dev
```

## 🔐 Security Configuration

### Key Vault Secrets
All sensitive data is stored in Azure Key Vault:
- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string
- `JWT_ACCESS_SECRET` - JWT signing secret
- `JWT_REFRESH_SECRET` - JWT refresh token secret

### Access Control
- App Services use Managed Identity for Key Vault access
- PostgreSQL uses firewall rules (Azure services only)
- All services enforce HTTPS only

## 📊 Monitoring

### Application Insights
Configured alerts:
- Error rate > 1%
- Response time > 2 seconds
- CPU usage > 80%
- Memory usage > 80%

### View Metrics
1. Azure Portal → Application Insights
2. Select `afl-predictor-insights-dev`
3. View Live Metrics or Logs

## 🚨 Troubleshooting

### Common Issues

**Issue: Resource group already exists**
```bash
# Import existing resource group
terraform import azurerm_resource_group.main \
  "/subscriptions/{subscription-id}/resourceGroups/afl-predictor-rg-dev"
```

**Issue: High costs**
```bash
# Immediately stop services
az webapp stop --name afl-predictor-frontend-dev --resource-group afl-predictor-rg-dev
az postgres flexible-server stop --name afl-predictor-db-dev --resource-group afl-predictor-rg-dev

# Then destroy resources
./destroy-azure-resources.sh dev
```

**Issue: Deployment fails**
1. Check GitHub Actions logs
2. Verify Azure credentials are set
3. Ensure all required secrets are configured

## 📝 Environment Variables

### Required GitHub Secrets
- `AZURE_CREDENTIALS` - Service principal JSON (required)
- `DB_ADMIN_USERNAME` - Database admin (optional, defaults to 'afladmin')
- `DB_ADMIN_PASSWORD` - Database password (optional for dev)
- `JWT_ACCESS_SECRET` - JWT secret (optional for dev)
- `JWT_REFRESH_SECRET` - JWT refresh secret (optional for dev)
- `ALERT_EMAIL` - Alert email address (optional)

### Terraform Variables
See `variables.tf` for all available variables. Key ones:
- `environment` - dev or prod
- `location` - Azure region (default: Australia Southeast)
- `project_name` - Project prefix (default: afl-predictor)

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow
Located at `.github/workflows/ci-cd.yml`

**Pipeline stages:**
1. **Test** - Runs on all branches
2. **Deploy-Dev** - Runs on push to `develop`
3. **Deploy-Prod** - Runs on push to `main` (requires approval)

### Manual Deployment
If you need to deploy manually:
```bash
# Login to Azure
az login

# Set subscription
az account set --subscription "your-subscription-id"

# Run deployment
cd infrastructure/terraform
terraform init
terraform apply -var-file="environments/dev.tfvars"
```

## 📚 Additional Resources

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure App Service Documentation](https://docs.microsoft.com/azure/app-service/)
- [GitHub Actions Documentation](https://docs.github.com/actions)

## ⚠️ Important Notes

1. **Always destroy production** when not actively needed (saves $530/month)
2. **Use development environment** for all testing ($44/month)
3. **Monitor costs daily** in Azure Cost Management
4. **Set budget alerts** to avoid surprises
5. **Use local Docker** for databases during development when possible

---

*Last Updated: August 2025*
*Environment-specific resource groups implemented to prevent conflicts*