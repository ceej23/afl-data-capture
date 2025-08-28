environment = "prod"
location    = "Australia Southeast"

# App Service - Production sizing
app_service_plan_sku = "S2"
cors_allowed_origins = ["https://aflpredictor.com", "https://www.aflpredictor.com"]

# Database - Production tier
postgresql_sku        = "GP_Standard_D2s_v3"
postgresql_storage_mb = 131072  # 128GB

# Redis - Standard tier for production
redis_family   = "C"
redis_sku      = "Standard"
redis_capacity = 1

# Tags
tags = {
  Project     = "AFL Predictor"
  Environment = "Production"
  ManagedBy   = "Terraform"
  Repository  = "afl-data-capture"
  CostCenter  = "Production"
  Compliance  = "Required"
}