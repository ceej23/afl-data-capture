#!/bin/bash

# Destroy Azure Infrastructure
# WARNING: This will delete ALL resources and data!

set -e

# Configuration
SUBSCRIPTION_ID="c6fdd64b-f4ef-404f-aa8d-2b013bcd03ee"
TERRAFORM_DIR="../terraform"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get environment argument
ENVIRONMENT="${1:-prod}"

if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
    echo -e "${RED}❌ Invalid environment. Use 'dev' or 'prod'${NC}"
    echo "Usage: ./destroy-infrastructure.sh [dev|prod]"
    exit 1
fi

echo -e "${RED}⚠️  WARNING: INFRASTRUCTURE DESTRUCTION ⚠️${NC}"
echo "=================================================="
echo -e "${YELLOW}This will PERMANENTLY DELETE:${NC}"
echo "  - ALL Azure resources for environment: $ENVIRONMENT"
echo "  - ALL databases and data"
echo "  - ALL configurations and secrets"
echo "  - ALL monitoring and logs"
echo ""

if [[ "$ENVIRONMENT" == "prod" ]]; then
    echo -e "${RED}PRODUCTION ENVIRONMENT - ESTIMATED SAVINGS: \$530/month${NC}"
    echo "Resources to be destroyed:"
    echo "  - App Service Plan S2 (\$140/month)"
    echo "  - PostgreSQL GP_Standard_D2s_v3 (\$250/month)"
    echo "  - Redis Standard C1 (\$120/month)"
    echo "  - Application Insights (\$20/month)"
else
    echo -e "${YELLOW}DEVELOPMENT ENVIRONMENT - ESTIMATED SAVINGS: \$44/month${NC}"
    echo "Resources to be destroyed:"
    echo "  - App Service Plan B1 (\$13/month)"
    echo "  - PostgreSQL B_Standard_B1ms (\$15/month)"
    echo "  - Redis Basic C0 (\$16/month)"
fi

echo ""
echo -e "${RED}This action cannot be undone!${NC}"
echo ""
read -p "Are you ABSOLUTELY SURE you want to destroy $ENVIRONMENT? Type 'destroy-$ENVIRONMENT' to confirm: " confirmation

if [[ "$confirmation" != "destroy-$ENVIRONMENT" ]]; then
    echo -e "${GREEN}✅ Destruction cancelled. Infrastructure is safe.${NC}"
    exit 0
fi

# Login to Azure if needed
echo -e "${YELLOW}📝 Checking Azure login...${NC}"
if ! az account show &>/dev/null; then
    echo "Please login to Azure..."
    az login
fi

# Set subscription
echo -e "${YELLOW}📝 Setting subscription...${NC}"
az account set --subscription "$SUBSCRIPTION_ID"

# Navigate to Terraform directory
cd "$TERRAFORM_DIR"

# Initialize Terraform
echo -e "${YELLOW}🔧 Initializing Terraform...${NC}"
terraform init

# Set environment variables for sensitive values
export TF_VAR_environment=$ENVIRONMENT
export TF_VAR_db_admin_username="destroying"
export TF_VAR_db_admin_password="DestroyingNow123!"
export TF_VAR_jwt_access_secret="destroying"
export TF_VAR_jwt_refresh_secret="destroying"

# Plan destruction
echo -e "${YELLOW}📋 Planning destruction...${NC}"
terraform plan -destroy -var-file="environments/${ENVIRONMENT}.tfvars" -out=destroy.tfplan

echo ""
echo -e "${RED}⚠️  FINAL WARNING ⚠️${NC}"
echo "This is your last chance to cancel!"
read -p "Type 'YES' to proceed with destruction: " final_confirm

if [[ "$final_confirm" != "YES" ]]; then
    echo -e "${GREEN}✅ Destruction cancelled at final stage.${NC}"
    exit 0
fi

# Destroy infrastructure
echo -e "${RED}💥 Destroying infrastructure...${NC}"
terraform apply destroy.tfplan

# Clean up local state files
echo -e "${YELLOW}🧹 Cleaning up local files...${NC}"
rm -f terraform.tfstate*
rm -f destroy.tfplan
rm -rf .terraform

echo ""
echo -e "${GREEN}✅ Infrastructure destroyed successfully!${NC}"
echo "=================================================="
echo ""
echo "Cost savings:"
if [[ "$ENVIRONMENT" == "prod" ]]; then
    echo "  - You're now saving ~\$530/month"
    echo "  - That's ~\$17/day or \$6,360/year!"
else
    echo "  - You're now saving ~\$44/month"
    echo "  - That's ~\$1.50/day or \$528/year!"
fi
echo ""
echo "Next steps:"
echo "  1. Verify in Azure Portal that all resources are gone"
echo "  2. Check your Azure cost analysis tomorrow"
echo "  3. Deploy to dev environment if needed: git checkout develop && git push"