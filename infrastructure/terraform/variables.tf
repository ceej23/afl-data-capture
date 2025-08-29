variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "afl-predictor"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "Australia Southeast"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "afl-predictor-rg"
}

# App Service Variables
variable "app_service_plan_sku" {
  description = "SKU for App Service Plan"
  type        = string
  default     = "S1"
}

variable "cors_allowed_origins" {
  description = "CORS allowed origins for frontend"
  type        = list(string)
  default     = ["http://localhost:3000"]
}

# Database Variables
variable "postgresql_sku" {
  description = "PostgreSQL SKU"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgresql_storage_mb" {
  description = "PostgreSQL storage in MB"
  type        = number
  default     = 32768
}

variable "db_admin_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_admin_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

# Redis Variables
variable "redis_family" {
  description = "Redis cache family"
  type        = string
  default     = "C"
}

variable "redis_sku" {
  description = "Redis cache SKU"
  type        = string
  default     = "Basic"
}

variable "redis_capacity" {
  description = "Redis cache capacity"
  type        = number
  default     = 0
}

# Security Variables
variable "jwt_access_secret" {
  description = "JWT access token secret"
  type        = string
  sensitive   = true
}

variable "jwt_refresh_secret" {
  description = "JWT refresh token secret"
  type        = string
  sensitive   = true
}

# Monitoring Variables
variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = "alerts@afl-data-capture.com"
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "AFL Predictor"
    ManagedBy   = "Terraform"
    Repository  = "afl-data-capture"
  }
}