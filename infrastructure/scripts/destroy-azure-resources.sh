#!/bin/bash

# Destroy Azure Resources using Azure CLI (no Terraform required)
# WARNING: This will delete ALL resources and data!

set -e

# Configuration
SUBSCRIPTION_ID="c6fdd64b-f4ef-404f-aa8d-2b013bcd03ee"

# Get environment argument
ENVIRONMENT="${1:-prod}"
if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
    echo "Usage: $0 [dev|prod]"
    exit 1
fi

RESOURCE_GROUP="afl-predictor-rg-${ENVIRONMENT}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${RED}⚠️  WARNING: AZURE RESOURCE DESTRUCTION ⚠️${NC}"
echo "=================================================="
echo -e "${YELLOW}This will PERMANENTLY DELETE:${NC}"
echo "  - Environment: ${ENVIRONMENT^^}"
echo "  - Resource Group: $RESOURCE_GROUP"
echo "  - ALL resources within this group"
echo "  - ALL databases and data"
echo "  - ALL configurations and secrets"
echo ""
if [[ "$ENVIRONMENT" == "prod" ]]; then
    echo -e "${RED}ESTIMATED SAVINGS: \$530/month (\$17/day)${NC}"
    echo ""
    echo "Resources to be destroyed:"
    echo "  - App Service Plan S2 (\$140/month)"
    echo "  - PostgreSQL Server (\$250/month)"
    echo "  - Redis Cache (\$120/month)"
    echo "  - Application Insights (\$20/month)"
else
    echo -e "${YELLOW}ESTIMATED SAVINGS: \$44/month (\$1.50/day)${NC}"
    echo ""
    echo "Resources to be destroyed:"
    echo "  - App Service Plan F1/B1 (\$0-13/month)"
    echo "  - PostgreSQL B_Standard_B1ms (\$15/month)"
    echo "  - Redis Basic C0 (\$16/month)"
    echo "  - Application Insights (minimal)"
fi
echo "  - Key Vault"
echo "  - Web Apps (Frontend & Backend)"
echo "  - All monitoring and alerts"
echo ""
echo -e "${RED}This action cannot be undone!${NC}"
echo ""
read -p "Type 'DELETE-$ENVIRONMENT' to confirm: " confirmation

if [[ "$confirmation" != "DELETE-$ENVIRONMENT" ]]; then
    echo -e "${GREEN}✅ Destruction cancelled. Infrastructure is safe.${NC}"
    exit 0
fi

# Check Azure CLI installation
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI is not installed${NC}"
    echo "Please install from: https://aka.ms/installazurecli"
    exit 1
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

# Check if resource group exists
echo -e "${YELLOW}🔍 Checking resource group...${NC}"
if ! az group exists --name "$RESOURCE_GROUP" | grep -q true; then
    echo -e "${YELLOW}Resource group $RESOURCE_GROUP does not exist or already deleted${NC}"
    exit 0
fi

# List all resources that will be deleted
echo -e "${YELLOW}📋 Resources that will be deleted:${NC}"
az resource list --resource-group "$RESOURCE_GROUP" --output table

echo ""
echo -e "${RED}⚠️  FINAL WARNING ⚠️${NC}"
echo "This will delete EVERYTHING listed above!"
read -p "Type 'YES-DELETE-EVERYTHING' to proceed: " final_confirm

if [[ "$final_confirm" != "YES-DELETE-EVERYTHING" ]]; then
    echo -e "${GREEN}✅ Destruction cancelled at final stage.${NC}"
    exit 0
fi

# Delete the resource group and all resources within it
echo -e "${RED}💥 Deleting all resources...${NC}"
echo "This may take 5-10 minutes..."

az group delete \
    --name "$RESOURCE_GROUP" \
    --yes \
    --no-wait

echo ""
echo -e "${YELLOW}⏳ Deletion initiated!${NC}"
echo "=================================================="
echo ""
echo "The deletion is running in the background."
echo "It typically takes 5-10 minutes to complete."
echo ""
echo "To check status:"
echo "  az group exists --name $RESOURCE_GROUP"
echo ""
echo "To verify in Azure Portal:"
echo "  https://portal.azure.com/#@${SUBSCRIPTION_ID}/resource/subscriptions/${SUBSCRIPTION_ID}/resourceGroups"
echo ""
echo -e "${GREEN}💰 Cost Savings:${NC}"
echo "  - You're now saving ~\$530/month"
echo "  - That's ~\$17/day"
echo "  - Or ~\$6,360/year!"
echo ""
echo -e "${GREEN}✅ Next Steps:${NC}"
echo "  1. Wait 5-10 minutes for deletion to complete"
echo "  2. Verify in Azure Portal that all resources are gone"
echo "  3. Check Azure Cost Management tomorrow"
echo "  4. To deploy CHEAP dev environment:"
echo "     - git checkout -b develop"
echo "     - git push origin develop"
echo "     - This will cost only \$44/month (or \$0 with free tier)"