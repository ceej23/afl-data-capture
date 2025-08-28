terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  backend "azurerm" {
    resource_group_name  = "afl-predictor-terraform"
    storage_account_name = "aflpredictortfstate"
    container_name      = "tfstate"
    key                 = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  
  tags = var.tags
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "${var.project_name}-asp-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type            = "Linux"
  sku_name           = var.app_service_plan_sku
  
  tags = var.tags
}

# Frontend App Service
resource "azurerm_linux_web_app" "frontend" {
  name                = "${var.project_name}-frontend-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id
  
  site_config {
    always_on = var.environment == "prod" ? true : false
    
    application_stack {
      node_version = "20-lts"
    }
    
    app_command_line = "npm run start"
    
    cors {
      allowed_origins = var.cors_allowed_origins
    }
  }
  
  app_settings = {
    "NODE_ENV"                = var.environment == "prod" ? "production" : "development"
    "NEXT_PUBLIC_API_URL"     = "https://${azurerm_linux_web_app.backend.default_hostname}"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.main.connection_string
  }
  
  https_only = true
  
  # Deployment slot for staging
  dynamic "sticky_app_setting_names" {
    for_each = var.environment == "prod" ? [1] : []
    content {
      app_setting_names = ["NODE_ENV", "NEXT_PUBLIC_API_URL"]
    }
  }
  
  tags = var.tags
}

# Backend App Service
resource "azurerm_linux_web_app" "backend" {
  name                = "${var.project_name}-backend-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id
  
  site_config {
    always_on = var.environment == "prod" ? true : false
    
    application_stack {
      node_version = "20-lts"
    }
    
    app_command_line = "npm run start"
    
    cors {
      allowed_origins     = ["https://${var.project_name}-frontend-${var.environment}.azurewebsites.net"]
      support_credentials = true
    }
  }
  
  app_settings = {
    "NODE_ENV"           = var.environment == "prod" ? "production" : "development"
    "PORT"              = "8080"
    "DATABASE_URL"      = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.database_url.versionless_id})"
    "REDIS_URL"         = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.redis_url.versionless_id})"
    "JWT_ACCESS_SECRET" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.jwt_access_secret.versionless_id})"
    "JWT_REFRESH_SECRET" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.jwt_refresh_secret.versionless_id})"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.main.connection_string
  }
  
  identity {
    type = "SystemAssigned"
  }
  
  https_only = true
  
  tags = var.tags
}

# Staging slots for production environment
resource "azurerm_linux_web_app_slot" "frontend_staging" {
  count           = var.environment == "prod" ? 1 : 0
  name            = "staging"
  app_service_id  = azurerm_linux_web_app.frontend.id
  
  site_config {
    always_on = true
    
    application_stack {
      node_version = "20-lts"
    }
    
    app_command_line = "npm run start"
  }
  
  app_settings = {
    "NODE_ENV"                = "staging"
    "NEXT_PUBLIC_API_URL"     = "https://${azurerm_linux_web_app_slot.backend_staging[0].default_hostname}"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.main.connection_string
  }
  
  https_only = true
  
  tags = var.tags
}

resource "azurerm_linux_web_app_slot" "backend_staging" {
  count           = var.environment == "prod" ? 1 : 0
  name            = "staging"
  app_service_id  = azurerm_linux_web_app.backend.id
  
  site_config {
    always_on = true
    
    application_stack {
      node_version = "20-lts"
    }
    
    app_command_line = "npm run start"
  }
  
  app_settings = {
    "NODE_ENV"           = "staging"
    "PORT"              = "8080"
    "DATABASE_URL"      = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.database_url.versionless_id})"
    "REDIS_URL"         = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.redis_url.versionless_id})"
    "JWT_ACCESS_SECRET" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.jwt_access_secret.versionless_id})"
    "JWT_REFRESH_SECRET" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.jwt_refresh_secret.versionless_id})"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.main.connection_string
  }
  
  identity {
    type = "SystemAssigned"
  }
  
  https_only = true
  
  tags = var.tags
}