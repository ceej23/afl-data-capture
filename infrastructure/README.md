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
│       ├── dev.tfvars
│       └── prod.tfvars
├── azure-devops/          # CI/CD pipelines
│   └── azure-pipelines.yml
├── scripts/               # Deployment and utility scripts
│   ├── deploy-azure.sh    # Main deployment script
│   └── rollback.sh        # Emergency rollback script
└── manual-setup/          # Manual setup guides
```

## 🚀 Quick Start

### Prerequisites

1. Azure CLI installed (`az --version`)
2. Terraform installed (`terraform --version`)
3. Azure subscription with appropriate permissions
4. Azure DevOps account (for CI/CD)

### Deploy Infrastructure

```bash
# Navigate to scripts directory
cd infrastructure/scripts

# Deploy to development environment
./deploy-azure.sh dev

# Deploy to production environment
./deploy-azure.sh prod
```

## 📋 Manual Azure Portal Setup

If you prefer manual setup through Azure Portal:

### 1. Create Resource Group
- Name: `afl-predictor-rg`
- Region: `Australia Southeast`

### 2. Create App Service Plan
- Name: `afl-predictor-asp-{env}`
- OS: Linux
- SKU: S1 (dev) or S2 (prod)
- Region: Same as resource group

### 3. Create App Services

#### Frontend:
- Name: `afl-predictor-frontend-{env}`
- Runtime: Node 20 LTS
- Startup Command: `npm run start`
- HTTPS Only: Enabled

#### Backend:
- Name: `afl-predictor-backend-{env}`
- Runtime: Node 20 LTS
- Startup Command: `npm run start`
- HTTPS Only: Enabled
- System Assigned Identity: Enabled

### 4. Create PostgreSQL Database
- Server Name: `afl-predictor-db-{env}`
- Version: 15
- SKU: Basic (dev) or General Purpose (prod)
- SSL Enforcement: Enabled
- Firewall: Allow Azure Services

### 5. Create Redis Cache
- Name: `afl-predictor-cache-{env}`
- SKU: Basic C0 (dev) or Standard C1 (prod)
- TLS: 1.2 minimum

### 6. Create Key Vault
- Name: `afl-predictor-vault-{env}`
- Access Policies: Grant backend app service Secret Get/List
- Soft Delete: Enabled
- Purge Protection: Enabled (prod only)

### 7. Create Application Insights
- Name: `afl-predictor-insights-{env}`
- Application Type: Web
- Link to App Services

## 🔐 Required Secrets

Add these secrets to Key Vault:

```bash
# Database connection
database-url: postgresql://{username}:{password}@{server}.postgres.database.azure.com:5432/aflpredictor?sslmode=require

# Redis connection
redis-url: rediss://default:{key}@{cache}.redis.cache.windows.net:6380

# JWT secrets (generate strong random strings)
jwt-access-secret: {random-string-min-32-chars}
jwt-refresh-secret: {random-string-min-32-chars}
```

## 🔄 Deployment Process

### Using Terraform (Recommended)

1. **Initialize Terraform:**
```bash
cd infrastructure/terraform
terraform init
```

2. **Plan deployment:**
```bash
terraform plan -var-file="environments/dev.tfvars"
```

3. **Apply configuration:**
```bash
terraform apply -var-file="environments/dev.tfvars"
```

### Using Azure CLI

```bash
# Create resource group
az group create --name afl-predictor-rg --location australiasoutheast

# Create App Service Plan
az appservice plan create \
  --name afl-predictor-asp-dev \
  --resource-group afl-predictor-rg \
  --sku S1 \
  --is-linux

# Create Frontend App Service
az webapp create \
  --name afl-predictor-frontend-dev \
  --resource-group afl-predictor-rg \
  --plan afl-predictor-asp-dev \
  --runtime "NODE:20-lts"

# Create Backend App Service
az webapp create \
  --name afl-predictor-backend-dev \
  --resource-group afl-predictor-rg \
  --plan afl-predictor-asp-dev \
  --runtime "NODE:20-lts"
```

## 🚨 Emergency Rollback

For production issues, use the rollback script:

```bash
# Rollback all services
./scripts/rollback.sh prod all

# Rollback frontend only
./scripts/rollback.sh prod frontend

# Rollback backend only
./scripts/rollback.sh prod backend
```

## 📊 Monitoring

### Application Insights Queries

```kusto
// Response time percentiles
requests
| where timestamp > ago(1h)
| summarize percentiles(duration, 50, 90, 99) by bin(timestamp, 5m)

// Error rate
requests
| where timestamp > ago(1h)
| summarize 
    total = count(), 
    failures = countif(success == false) 
by bin(timestamp, 5m)
| extend errorRate = failures * 100.0 / total
```

### Alerts Configuration

| Alert | Threshold | Severity | Action |
|-------|-----------|----------|--------|
| Response Time | > 2s avg | Warning | Email team |
| Error Rate | > 5% | Critical | Email + SMS |
| CPU Usage | > 80% | Warning | Auto-scale |
| Memory Usage | > 85% | Warning | Investigate |

## 💰 Cost Optimization

### Development Environment
- Use Basic/Standard tiers
- Enable auto-shutdown during non-business hours
- Share resources where possible

### Production Environment
- Use Reserved Instances (1-year: ~40% savings)
- Enable auto-scaling instead of over-provisioning
- Monitor and optimize based on actual usage

### Estimated Monthly Costs

#### Minimal Development (Recommended)
| Service | Cost | Notes |
|---------|------|-------|
| App Service Plan (F1 Free) | $0 | Limited to 60 CPU min/day |
| App Service Plan (B1 Basic) | $13 | Better performance option |
| Local Docker PostgreSQL | $0 | Run locally |
| Local Docker Redis | $0 | Run locally |
| Application Insights | $0 | 5GB free tier |
| **Total** | **$0-13** | Hybrid local/cloud |

#### Full Azure Development
| Service | Cost | Notes |
|---------|------|-------|
| App Service Plan (B1) | $13 | Basic tier |
| PostgreSQL (B1ms) | $15 | Smallest burstable |
| Redis Cache (C0) | $16 | 250MB cache |
| Application Insights | $0 | Free tier |
| Key Vault | $0 | Minimal usage |
| **Total** | **$44** | All services in Azure |

#### Production Environment
| Service | Cost | Notes |
|---------|------|-------|
| App Service Plan (S1) | $70 | Standard tier, auto-scale |
| PostgreSQL (B2s) | $35 | 2 vCores, production-ready |
| Redis Cache (C1) | $50 | 1GB cache |
| Application Insights | $10 | ~10GB ingestion |
| Key Vault | $5 | Standard operations |
| **Total** | **$170** | Production-grade |

## 🔒 Security Checklist

- [ ] HTTPS enforced on all services
- [ ] Database SSL required
- [ ] Secrets in Key Vault only
- [ ] Managed identities for service auth
- [ ] Network security groups configured
- [ ] Regular security scanning enabled
- [ ] Backup encryption enabled
- [ ] Audit logging enabled

## 📚 Additional Resources

- [Azure App Service Documentation](https://docs.microsoft.com/azure/app-service/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure DevOps Pipelines](https://docs.microsoft.com/azure/devops/pipelines/)
- [Azure Cost Management](https://azure.microsoft.com/pricing/calculator/)

## 🆘 Troubleshooting

### Common Issues

1. **Deployment fails with "Resource already exists"**
   - Check if resource was created manually
   - Import existing resource: `terraform import azurerm_resource_group.main /subscriptions/{id}/resourceGroups/afl-predictor-rg`

2. **App Service won't start**
   - Check Application Insights for errors
   - Verify environment variables in App Service Configuration
   - Check deployment logs in Kudu console

3. **Database connection fails**
   - Verify firewall rules allow App Service IPs
   - Check SSL enforcement settings
   - Verify connection string format

4. **High costs**
   - Review Application Insights for usage patterns
   - Consider scaling down during low usage
   - Enable auto-scaling instead of fixed high tier

## 📞 Support

For infrastructure issues:
1. Check Application Insights for errors
2. Review deployment logs
3. Contact DevOps team
4. Escalate to Azure Support if needed