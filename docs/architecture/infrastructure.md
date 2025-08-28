# Infrastructure Architecture

## Overview

The infrastructure is built on Azure cloud services, optimized for Australian users with a focus on scalability, reliability, and cost-effectiveness within a $500/month budget.

## Cloud Architecture

### Azure Services Overview

```yaml
Region: Australia Southeast (Primary)
Backup Region: Australia East (DR)

Services:
  Compute:
    - Azure App Service (Linux)
    - Azure Functions (Serverless)
  
  Data:
    - Azure Database for PostgreSQL
    - Azure Cache for Redis
    - Azure Blob Storage
  
  Networking:
    - Azure Front Door (CDN + WAF)
    - Azure API Management
    - Virtual Network
  
  Security:
    - Azure Key Vault
    - Azure AD B2C
    - Web Application Firewall
  
  Monitoring:
    - Application Insights
    - Log Analytics
    - Azure Monitor
```

## Deployment Architecture

### CI/CD Pipeline

```yaml
name: Production Deployment

stages:
  - name: Build
    jobs:
      - lint:
          command: npm run lint
      - typecheck:
          command: npm run typecheck
      - test:
          command: npm run test:ci
          coverage_threshold: 80%
      - security_scan:
          command: npm audit
      - build:
          command: npm run build
          artifacts: ['.next/', 'dist/']
  
  - name: Deploy to Staging
    environment: staging
    jobs:
      - deploy:
          strategy: blue-green
          health_check: /api/health
      - smoke_tests:
          command: npm run test:e2e:staging
      - performance_tests:
          threshold:
            p95_response_time: 500ms
            error_rate: 1%
  
  - name: Deploy to Production
    environment: production
    approval: required
    jobs:
      - deploy:
          strategy: canary
          canary_percentage: [10, 50, 100]
          rollback_on_failure: true
      - verify:
          monitors: ['availability', 'performance', 'errors']
          duration: 10m
```

### Deployment Strategies

#### Blue-Green Deployment
```mermaid
graph LR
    LB[Load Balancer]
    B[Blue - Current]
    G[Green - New]
    
    LB -->|100% traffic| B
    LB -.->|0% traffic| G
    
    B --> DB[(Database)]
    G --> DB
```

#### Canary Deployment
```yaml
Canary Stages:
  Stage 1:
    traffic: 10%
    duration: 10 minutes
    rollback_threshold:
      error_rate: 5%
      response_time: 1000ms
  
  Stage 2:
    traffic: 50%
    duration: 30 minutes
    rollback_threshold:
      error_rate: 2%
      response_time: 750ms
  
  Stage 3:
    traffic: 100%
    monitor: 1 hour
```

## Infrastructure as Code

### Terraform Configuration

```hcl
# main.tf
terraform {
  required_version = ">= 1.6"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  backend "azurerm" {
    resource_group_name  = "afl-terraform-state"
    storage_account_name = "aflterraformstate"
    container_name      = "tfstate"
    key                 = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "afl-predictor-rg"
  location = "Australia Southeast"
  
  tags = {
    Environment = var.environment
    Project     = "AFL-Predictor"
    ManagedBy   = "Terraform"
  }
}
```

### App Service Configuration

```hcl
# App Service Plan
resource "azurerm_app_service_plan" "main" {
  name                = "afl-predictor-asp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Linux"
  reserved            = true
  
  sku {
    tier = var.environment == "production" ? "Standard" : "Basic"
    size = var.environment == "production" ? "S2" : "B1"
  }
  
  # Auto-scaling configuration
  maximum_elastic_worker_count = var.environment == "production" ? 20 : 5
}

# App Service - Frontend
resource "azurerm_linux_web_app" "frontend" {
  name                = "afl-predictor-frontend"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_app_service_plan.main.id
  
  site_config {
    always_on              = var.environment == "production"
    linux_fx_version      = "NODE|20-lts"
    app_command_line      = "npm start"
    
    application_stack {
      node_version = "20-lts"
    }
    
    cors {
      allowed_origins = ["https://afl-predictor.com"]
    }
  }
  
  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "20-lts"
    "NEXT_PUBLIC_API_URL"          = var.api_url
    "NODE_ENV"                     = var.environment
  }
  
  connection_string {
    name  = "Redis"
    type  = "RedisCache"
    value = azurerm_redis_cache.main.primary_connection_string
  }
}

# App Service - Backend Services
resource "azurerm_linux_web_app" "backend" {
  for_each = toset(["formula", "prediction", "backtest", "user"])
  
  name                = "afl-${each.key}-service"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_app_service_plan.main.id
  
  site_config {
    always_on              = true
    linux_fx_version      = "NODE|20-lts"
    health_check_path     = "/health"
    
    application_stack {
      node_version = "20-lts"
    }
  }
  
  app_settings = {
    "NODE_ENV"        = var.environment
    "DATABASE_URL"    = azurerm_postgresql_server.main.connection_string
    "REDIS_URL"       = azurerm_redis_cache.main.connection_string
    "SERVICE_NAME"    = each.key
  }
}
```

### Database Infrastructure

```hcl
# PostgreSQL Server
resource "azurerm_postgresql_server" "main" {
  name                = "afl-predictor-db"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  sku_name = var.environment == "production" ? "GP_Gen5_4" : "B_Gen5_2"
  version  = "15"
  storage_mb = var.environment == "production" ? 102400 : 32768
  
  administrator_login          = var.db_admin_username
  administrator_login_password = random_password.db_password.result
  
  backup_retention_days        = 30
  geo_redundant_backup_enabled = var.environment == "production"
  auto_grow_enabled            = true
  
  public_network_access_enabled = false
  ssl_enforcement_enabled       = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

# Redis Cache
resource "azurerm_redis_cache" "main" {
  name                = "afl-predictor-cache"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  capacity            = var.environment == "production" ? 2 : 0
  family              = "C"
  sku_name            = var.environment == "production" ? "Standard" : "Basic"
  
  redis_configuration {
    maxmemory_policy      = "allkeys-lru"
    enable_authentication = true
    
    # Enable persistence for production
    rdb_backup_enabled     = var.environment == "production"
    rdb_backup_frequency   = var.environment == "production" ? 60 : 0
    rdb_backup_max_snapshot_count = 1
  }
}

# Blob Storage
resource "azurerm_storage_account" "main" {
  name                     = "aflpredictorstorage"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = var.environment == "production" ? "GRS" : "LRS"
  
  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = 7
    }
    
    container_delete_retention_policy {
      days = 7
    }
  }
  
  lifecycle_rule {
    enabled = true
    
    blob {
      tier_to_cool_after_days_since_modification_greater_than    = 30
      tier_to_archive_after_days_since_modification_greater_than = 90
      delete_after_days_since_modification_greater_than          = 365
    }
  }
}
```

### Networking Configuration

```hcl
# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "afl-predictor-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}

# Subnets
resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
  
  delegation {
    name = "app-service-delegation"
    
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "data" {
  name                 = "data-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
  
  service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
}

# Azure Front Door (CDN + WAF)
resource "azurerm_frontdoor" "main" {
  name                = "afl-predictor-fd"
  resource_group_name = azurerm_resource_group.main.name
  
  frontend_endpoint {
    name      = "afl-predictor-frontend"
    host_name = "afl-predictor.azurefd.net"
    
    web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.main.id
  }
  
  backend_pool {
    name = "backend-pool"
    
    backend {
      host_header = azurerm_linux_web_app.frontend.default_hostname
      address     = azurerm_linux_web_app.frontend.default_hostname
      http_port   = 80
      https_port  = 443
      weight      = 100
      priority    = 1
    }
    
    load_balancing_settings {
      name                        = "loadbalancing"
      sample_size                 = 4
      successful_samples_required = 2
    }
    
    health_probe_settings {
      name                = "healthprobe"
      path                = "/health"
      protocol            = "Https"
      interval_in_seconds = 30
    }
  }
}
```

### Security Infrastructure

```hcl
# Key Vault
resource "azurerm_key_vault" "main" {
  name                = "afl-predictor-kv"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  
  purge_protection_enabled   = var.environment == "production"
  soft_delete_retention_days = 90
  
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    
    ip_rules = var.allowed_ips
  }
}

# Secrets
resource "azurerm_key_vault_secret" "db_connection" {
  name         = "database-connection-string"
  value        = azurerm_postgresql_server.main.connection_string
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "jwt_secret" {
  name         = "jwt-secret"
  value        = random_password.jwt_secret.result
  key_vault_id = azurerm_key_vault.main.id
}

# WAF Policy
resource "azurerm_frontdoor_firewall_policy" "main" {
  name                = "aflpredictorwaf"
  resource_group_name = azurerm_resource_group.main.name
  
  enabled = true
  mode    = var.environment == "production" ? "Prevention" : "Detection"
  
  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
    
    managed_rule_set {
      type    = "BotProtection"
      version = "1.0"
    }
  }
  
  custom_rules {
    name      = "RateLimitRule"
    priority  = 1
    rule_type = "RateLimitRule"
    
    match_conditions {
      match_variable = "RequestUri"
      operator       = "Contains"
      match_values   = ["/api"]
    }
    
    action               = "Block"
    rate_limit_threshold = 100
    rate_limit_duration_in_minutes = 1
  }
}
```

## Container Configuration

### Docker Setup

```dockerfile
# frontend.Dockerfile
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
ENV PORT 3000

CMD ["node", "server.js"]
```

```dockerfile
# backend.Dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV production

RUN apk add --no-cache dumb-init

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

USER node
EXPOSE 3001

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]
```

### Docker Compose (Development)

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: afl_dev
      POSTGRES_USER: developer
      POSTGRES_PASSWORD: dev_password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
  
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    environment:
      NEXT_PUBLIC_API_URL: http://localhost:3001
    volumes:
      - ./frontend:/app
      - /app/node_modules
  
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    ports:
      - "3001:3001"
    environment:
      DATABASE_URL: postgresql://developer:dev_password@postgres:5432/afl_dev
      REDIS_URL: redis://redis:6379
    depends_on:
      - postgres
      - redis
    volumes:
      - ./backend:/app
      - /app/node_modules

volumes:
  postgres_data:
  redis_data:
```

## Monitoring Configuration

```hcl
# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "afl-predictor-insights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  
  daily_data_cap_in_gb = var.environment == "production" ? 5 : 1
  retention_in_days    = var.environment == "production" ? 90 : 30
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "afl-predictor-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = var.environment == "production" ? 90 : 30
}

# Alerts
resource "azurerm_monitor_metric_alert" "high_cpu" {
  name                = "high-cpu-alert"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_app_service_plan.main.id]
  
  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
  
  window_size        = "PT5M"
  frequency          = "PT1M"
  severity           = 2
  
  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
```

## Cost Optimization

### Monthly Budget Allocation

```yaml
Resource Allocation ($500/month):
  Compute: $200
    App Service Plan (S2): $150
    Functions (Consumption): $50
  
  Database: $150
    PostgreSQL (B_Gen5_2): $100
    Redis Cache (C1): $50
  
  Storage: $30
    Blob Storage: $20
    CDN Bandwidth: $10
  
  Monitoring: $50
    Application Insights: $30
    Log Analytics: $20
  
  Network: $70
    Front Door: $50
    Bandwidth: $20

Cost Saving Strategies:
  - Use B-series VMs for non-production
  - Reserved instances (1-year): 30% savings
  - Spot instances for batch jobs
  - Auto-scaling with aggressive scale-down
  - Cold storage for old data
  - Optimize Application Insights sampling
```

### Auto-scaling Configuration

```yaml
Scaling Rules:
  Scale Out:
    - CPU > 70% for 5 minutes → Add 2 instances
    - Memory > 80% for 5 minutes → Add 1 instance
    - Request queue > 100 → Add 2 instances
  
  Scale In:
    - CPU < 30% for 10 minutes → Remove 1 instance
    - Memory < 40% for 10 minutes → Remove 1 instance
  
  Limits:
    Min Instances: 2 (production), 1 (staging)
    Max Instances: 20 (production), 5 (staging)
    Cool Down: 5 minutes
```

---

*Infrastructure Architecture Version 1.0 - Created 2025-08-28*