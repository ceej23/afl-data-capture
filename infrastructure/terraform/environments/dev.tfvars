environment = "dev"
location    = "Australia Southeast"

# App Service - Free or Basic tier for dev
app_service_plan_sku = "F1"  # Free tier (or "B1" for $13/month)
cors_allowed_origins = ["http://localhost:3000", "https://afl-predictor-frontend-dev.azurewebsites.net"]

# Database - Smallest burstable tier
postgresql_sku        = "B_Standard_B1ms"  # $15/month
postgresql_storage_mb = 32768  # 32GB

# Redis - Smallest tier
redis_family   = "C"
redis_sku      = "Basic"
redis_capacity = 0  # C0 - 250MB cache, $16/month

# Tags
tags = {
  Project     = "AFL Predictor"
  Environment = "Development"
  ManagedBy   = "Terraform"
  Repository  = "afl-data-capture"
  CostCenter  = "Development"
}