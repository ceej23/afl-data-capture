#!/bin/bash

# Import existing Azure resources into Terraform state
# Run this when resources exist but aren't in Terraform state

set -e

SUBSCRIPTION_ID="c6fdd64b-f4ef-404f-aa8d-2b013bcd03ee"
RESOURCE_GROUP="afl-predictor-rg"
ENVIRONMENT="prod"

echo "🔄 Importing existing Azure resources into Terraform state"
echo "=================================================="
echo ""

cd ../terraform

# Initialize Terraform if needed
terraform init

echo "📦 Importing Resource Group..."
terraform import azurerm_resource_group.main \
  "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}" || echo "Already imported"

echo "💾 Importing Redis Cache..."
terraform import azurerm_redis_cache.main \
  "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Cache/redis/afl-predictor-cache-${ENVIRONMENT}" || echo "Already imported"

echo "🔐 Importing Key Vault..."
terraform import azurerm_key_vault.main \
  "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.KeyVault/vaults/afl-predictor-vault-${ENVIRONMENT}" || echo "Already imported"

echo "📊 Importing Application Insights..."
terraform import azurerm_application_insights.main \
  "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Insights/components/afl-predictor-insights-${ENVIRONMENT}" || echo "Already imported"

echo "📈 Importing Log Analytics Workspace..."
terraform import azurerm_log_analytics_workspace.main \
  "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.OperationalInsights/workspaces/afl-predictor-logs-${ENVIRONMENT}" || echo "Already imported"

echo ""
echo "✅ Import complete! Now run terraform plan to see remaining resources to create."
echo ""
echo "Next steps:"
echo "1. terraform plan -var-file=environments/${ENVIRONMENT}.tfvars"
echo "2. terraform apply -var-file=environments/${ENVIRONMENT}.tfvars"