#!/bin/bash

# Cleanup script for old resource group (afl-predictor-rg)
# This removes resources created before we added environment suffixes

set -e

# Configuration
SUBSCRIPTION_ID="c6fdd64b-f4ef-404f-aa8d-2b013bcd03ee"
OLD_RESOURCE_GROUP="afl-predictor-rg"  # The old naming without environment suffix

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}⚠️  CLEANUP: Old Azure Resources ⚠️${NC}"
echo "=================================================="
echo -e "${YELLOW}This script removes resources from the OLD naming convention${NC}"
echo ""
echo "Resource Group to Delete: ${RED}$OLD_RESOURCE_GROUP${NC}"
echo ""
echo "This was created during initial deployment attempts before we"
echo "switched to environment-specific resource groups:"
echo "  - NEW Dev: afl-predictor-rg-dev"
echo "  - NEW Prod: afl-predictor-rg-prod"
echo ""
echo -e "${RED}This will DELETE ALL resources in $OLD_RESOURCE_GROUP${NC}"
echo ""
read -p "Type 'CLEANUP-OLD' to confirm: " confirmation

if [[ "$confirmation" != "CLEANUP-OLD" ]]; then
    echo -e "${GREEN}✅ Cleanup cancelled.${NC}"
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

# Check if old resource group exists
echo -e "${YELLOW}🔍 Checking for old resource group...${NC}"
if ! az group exists --name "$OLD_RESOURCE_GROUP" | grep -q true; then
    echo -e "${GREEN}✅ Old resource group $OLD_RESOURCE_GROUP does not exist${NC}"
    echo "Nothing to clean up!"
    exit 0
fi

# List all resources that will be deleted
echo -e "${YELLOW}📋 Resources that will be deleted:${NC}"
az resource list --resource-group "$OLD_RESOURCE_GROUP" --output table

echo ""
echo -e "${RED}⚠️  FINAL WARNING ⚠️${NC}"
echo "This will delete EVERYTHING listed above!"
echo "This includes any data stored in databases or storage accounts!"
read -p "Type 'YES-DELETE-OLD' to proceed: " final_confirm

if [[ "$final_confirm" != "YES-DELETE-OLD" ]]; then
    echo -e "${GREEN}✅ Cleanup cancelled at final stage.${NC}"
    exit 0
fi

# Delete the resource group and all resources within it
echo -e "${RED}💥 Deleting old resource group and all contents...${NC}"
echo "This may take 5-10 minutes..."

az group delete \
    --name "$OLD_RESOURCE_GROUP" \
    --yes \
    --no-wait

echo ""
echo -e "${YELLOW}⏳ Deletion initiated for $OLD_RESOURCE_GROUP!${NC}"
echo "=================================================="
echo ""
echo "The deletion is running in the background."
echo "It typically takes 5-10 minutes to complete."
echo ""
echo "To check status:"
echo "  az group exists --name $OLD_RESOURCE_GROUP"
echo ""
echo "To verify in Azure Portal:"
echo "  https://portal.azure.com/#@${SUBSCRIPTION_ID}/resource/subscriptions/${SUBSCRIPTION_ID}/resourceGroups"
echo ""
echo -e "${GREEN}✅ Next Steps:${NC}"
echo "  1. Wait for deletion to complete (5-10 minutes)"
echo "  2. Verify old resources are gone"
echo "  3. Deploy to new environment-specific resource groups:"
echo "     - Dev: afl-predictor-rg-dev"
echo "     - Prod: afl-predictor-rg-prod"
echo ""
echo "To deploy to DEV after cleanup:"
echo "  git push origin develop"
echo ""
echo -e "${YELLOW}💡 Tip:${NC} The new naming prevents conflicts between environments!"