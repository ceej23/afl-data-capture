#!/bin/bash

# Manual Azure Deployment Script
# Deploy infrastructure and applications to Azure

set -e

# Configuration
SUBSCRIPTION_ID="c6fdd64b-f4ef-404f-aa8d-2b013bcd03ee"
ENVIRONMENT="${1:-dev}"
TERRAFORM_DIR="../infrastructure/terraform"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 AFL Data Capture - Azure Deployment${NC}"
echo "=================================================="
echo "Environment: $ENVIRONMENT"
echo "Subscription: $SUBSCRIPTION_ID"
echo ""

# Check environment
if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
    echo -e "${RED}❌ Invalid environment. Use 'dev' or 'prod'${NC}"
    exit 1
fi

# Check Azure CLI
echo -e "${YELLOW}📝 Checking Azure CLI...${NC}"
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI not found. Please install: https://aka.ms/installazurecli${NC}"
    exit 1
fi

# Check Terraform
echo -e "${YELLOW}📝 Checking Terraform...${NC}"
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform not found. Please install: https://www.terraform.io/downloads${NC}"
    exit 1
fi

# Login to Azure
echo -e "${YELLOW}📝 Checking Azure login...${NC}"
if ! az account show &>/dev/null; then
    echo -e "${YELLOW}Please login to Azure...${NC}"
    az login
fi

# Set subscription
echo -e "${YELLOW}📝 Setting subscription...${NC}"
az account set --subscription "$SUBSCRIPTION_ID"

# Deploy infrastructure
echo -e "${GREEN}🏗️  Deploying infrastructure with Terraform...${NC}"
cd "$TERRAFORM_DIR"

# Initialize Terraform
echo -e "${YELLOW}Initializing Terraform...${NC}"
terraform init

# Plan deployment
echo -e "${YELLOW}Planning deployment...${NC}"
terraform plan -var-file="environments/${ENVIRONMENT}.tfvars" -out=tfplan

# Apply deployment
echo -e "${YELLOW}Applying infrastructure changes...${NC}"
read -p "Do you want to apply these changes? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    terraform apply tfplan
    
    # Get outputs
    echo -e "${GREEN}📋 Terraform Outputs:${NC}"
    terraform output
    
    # Store outputs for app deployment
    RESOURCE_GROUP=$(terraform output -raw resource_group_name)
    FRONTEND_APP=$(terraform output -raw frontend_app_name)
    BACKEND_APP=$(terraform output -raw backend_app_name)
else
    echo -e "${RED}❌ Deployment cancelled${NC}"
    exit 1
fi

cd - > /dev/null

# Build applications
echo -e "${GREEN}🔨 Building applications...${NC}"

# Frontend
echo -e "${YELLOW}Building frontend...${NC}"
cd ../frontend
npm ci
npm run build

# Backend
echo -e "${YELLOW}Building backend...${NC}"
cd ../backend
npm ci
npm run build

cd ../scripts

# Deploy applications
echo -e "${GREEN}🚀 Deploying applications to Azure...${NC}"

# Deploy Frontend
echo -e "${YELLOW}Deploying frontend to $FRONTEND_APP...${NC}"
cd ../frontend
zip -r frontend.zip . -x "*.git*" "node_modules/*" "*.env*"
az webapp deploy \
    --resource-group "$RESOURCE_GROUP" \
    --name "$FRONTEND_APP" \
    --src-path frontend.zip \
    --type zip
rm frontend.zip

# Deploy Backend
echo -e "${YELLOW}Deploying backend to $BACKEND_APP...${NC}"
cd ../backend
zip -r backend.zip . -x "*.git*" "node_modules/*" "*.env*"
az webapp deploy \
    --resource-group "$RESOURCE_GROUP" \
    --name "$BACKEND_APP" \
    --src-path backend.zip \
    --type zip
rm backend.zip

cd ../scripts

# Run smoke tests
echo -e "${GREEN}🧪 Running smoke tests...${NC}"

FRONTEND_URL="https://${FRONTEND_APP}.azurewebsites.net"
BACKEND_URL="https://${BACKEND_APP}.azurewebsites.net"

echo -e "${YELLOW}Waiting for services to be ready...${NC}"
sleep 30

echo -e "${YELLOW}Testing frontend at $FRONTEND_URL...${NC}"
if curl -f "$FRONTEND_URL" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Frontend is responding${NC}"
else
    echo -e "${RED}❌ Frontend is not responding${NC}"
fi

echo -e "${YELLOW}Testing backend at $BACKEND_URL/health...${NC}"
if curl -f "$BACKEND_URL/health" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Backend is healthy${NC}"
else
    echo -e "${RED}❌ Backend health check failed${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Deployment Complete!${NC}"
echo "=================================================="
echo "Frontend: $FRONTEND_URL"
echo "Backend: $BACKEND_URL"
echo ""
echo "View resources in Azure Portal:"
echo "https://portal.azure.com/#@${TENANT_ID}/resource/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}"
echo ""