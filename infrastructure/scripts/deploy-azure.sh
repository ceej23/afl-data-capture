#!/bin/bash

# Azure Infrastructure Deployment Script
# This script deploys the AFL Predictor infrastructure to Azure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-dev}
TERRAFORM_DIR="../terraform"
RESOURCE_GROUP="afl-predictor-rg"
LOCATION="australiasoutheast"

echo -e "${GREEN}🚀 AFL Predictor - Azure Infrastructure Deployment${NC}"
echo -e "${GREEN}Environment: $ENVIRONMENT${NC}"
echo "================================================"

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"

if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI is not installed. Please install it first.${NC}"
    exit 1
fi

if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform is not installed. Please install it first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Login to Azure
echo -e "${YELLOW}🔐 Logging into Azure...${NC}"
az account show &> /dev/null || az login

# Get subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo -e "${GREEN}Using subscription: $SUBSCRIPTION_ID${NC}"

# Create resource group if it doesn't exist
echo -e "${YELLOW}📦 Creating resource group...${NC}"
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION \
    --tags Project="AFL Predictor" Environment="$ENVIRONMENT" \
    || echo "Resource group already exists"

# Create storage account for Terraform state
echo -e "${YELLOW}💾 Setting up Terraform backend...${NC}"
STORAGE_ACCOUNT="aflpredictortfstate"
CONTAINER_NAME="tfstate"

# Create storage account if it doesn't exist
if ! az storage account show --name $STORAGE_ACCOUNT --resource-group "afl-predictor-terraform" &> /dev/null; then
    az group create --name "afl-predictor-terraform" --location $LOCATION
    az storage account create \
        --name $STORAGE_ACCOUNT \
        --resource-group "afl-predictor-terraform" \
        --location $LOCATION \
        --sku Standard_LRS \
        --encryption-services blob
    
    # Get storage account key
    ACCOUNT_KEY=$(az storage account keys list \
        --resource-group "afl-predictor-terraform" \
        --account-name $STORAGE_ACCOUNT \
        --query '[0].value' -o tsv)
    
    # Create blob container
    az storage container create \
        --name $CONTAINER_NAME \
        --account-name $STORAGE_ACCOUNT \
        --account-key $ACCOUNT_KEY
fi

# Initialize Terraform
echo -e "${YELLOW}🔧 Initializing Terraform...${NC}"
cd $TERRAFORM_DIR
terraform init

# Validate Terraform configuration
echo -e "${YELLOW}✔️ Validating Terraform configuration...${NC}"
terraform validate

# Plan deployment
echo -e "${YELLOW}📋 Planning deployment...${NC}"
terraform plan \
    -var-file="environments/${ENVIRONMENT}.tfvars" \
    -out="${ENVIRONMENT}.tfplan"

# Ask for confirmation
echo -e "${YELLOW}⚠️  Review the plan above. Do you want to proceed with deployment? (yes/no)${NC}"
read -r response
if [[ "$response" != "yes" ]]; then
    echo -e "${RED}Deployment cancelled.${NC}"
    exit 0
fi

# Apply Terraform configuration
echo -e "${YELLOW}🚀 Deploying infrastructure...${NC}"
terraform apply "${ENVIRONMENT}.tfplan"

# Get outputs
echo -e "${GREEN}✨ Deployment complete!${NC}"
echo -e "${GREEN}================================================${NC}"
echo "Outputs:"
terraform output -json | jq .

# Save outputs to file
terraform output -json > "../outputs/${ENVIRONMENT}-outputs.json"

echo -e "${GREEN}✅ Infrastructure deployed successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Configure Azure DevOps pipelines"
echo "2. Set up secret values in Key Vault"
echo "3. Deploy application code"
echo "4. Run smoke tests"