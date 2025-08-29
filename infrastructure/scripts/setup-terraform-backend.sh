#!/bin/bash

# Setup Terraform Backend Storage in Azure
# This script creates the storage account needed for Terraform state

set -e

# Configuration
RESOURCE_GROUP="afl-data-capture-terraform"
STORAGE_ACCOUNT="afldatacapturetfstate"
CONTAINER_NAME="tfstate"
LOCATION="australiaeast"
SUBSCRIPTION_ID="c6fdd64b-f4ef-404f-aa8d-2b013bcd03ee"

echo "🚀 Setting up Terraform Backend Storage"
echo "========================================"
echo "Resource Group: $RESOURCE_GROUP"
echo "Storage Account: $STORAGE_ACCOUNT"
echo "Container: $CONTAINER_NAME"
echo ""

# Check if logged in
echo "📝 Checking Azure login..."
if ! az account show &>/dev/null; then
    echo "❌ Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

# Set subscription
echo "📝 Setting subscription..."
az account set --subscription "$SUBSCRIPTION_ID"

# Create resource group
echo "📦 Creating resource group..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output none || echo "Resource group already exists"

# Create storage account
echo "💾 Creating storage account..."
az storage account create \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --output none || echo "Storage account already exists"

# Get storage account key
echo "🔑 Getting storage account key..."
ACCOUNT_KEY=$(az storage account keys list \
    --resource-group "$RESOURCE_GROUP" \
    --account-name "$STORAGE_ACCOUNT" \
    --query '[0].value' \
    --output tsv)

# Create blob container
echo "📦 Creating blob container..."
az storage container create \
    --name "$CONTAINER_NAME" \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$ACCOUNT_KEY" \
    --output none || echo "Container already exists"

echo ""
echo "✅ Terraform backend storage setup complete!"
echo ""
echo "📋 Backend configuration for main.tf:"
echo ""
cat <<EOF
terraform {
  backend "azurerm" {
    resource_group_name  = "$RESOURCE_GROUP"
    storage_account_name = "$STORAGE_ACCOUNT"
    container_name      = "$CONTAINER_NAME"
    key                 = "terraform.tfstate"
  }
}
EOF
echo ""
echo "🔑 Storage Account Key (keep secure):"
echo "$ACCOUNT_KEY"
echo ""
echo "Add this key as a GitHub secret: ARM_ACCESS_KEY"