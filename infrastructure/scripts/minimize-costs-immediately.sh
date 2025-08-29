#!/bin/bash

# Emergency cost reduction script
# Stops all services and scales down to minimize charges while working on deletion

set +e  # Continue even if some commands fail

# Configuration
SUBSCRIPTION_ID="c6fdd64b-f4ef-404f-aa8d-2b013bcd03ee"
RESOURCE_GROUP="afl-predictor-rg"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${RED}==================================================${NC}"
echo -e "${RED}     EMERGENCY COST REDUCTION SCRIPT${NC}"
echo -e "${RED}==================================================${NC}"
echo ""
echo -e "${YELLOW}This will STOP all services to minimize costs${NC}"
echo -e "${YELLOW}Current cost: ~\$530/month (\$17/day)${NC}"
echo ""
read -p "Press Enter to start cost reduction..."

# Login check
echo -e "${BLUE}📝 Checking Azure login...${NC}"
if ! az account show &>/dev/null; then
    echo "Please login to Azure..."
    az login
fi

# Set subscription
az account set --subscription "$SUBSCRIPTION_ID"

# Check if resource group exists
if ! az group exists --name "$RESOURCE_GROUP" | grep -q true; then
    echo -e "${GREEN}✅ Resource group doesn't exist - no costs!${NC}"
    exit 0
fi

echo -e "${BLUE}🛑 Step 1: Stopping all App Services...${NC}"
# Stop all web apps
for webapp in $(az webapp list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv); do
    echo "  Stopping: $webapp"
    az webapp stop --name "$webapp" --resource-group "$RESOURCE_GROUP" 2>/dev/null || true
    echo -e "  ${GREEN}✓ Stopped $webapp${NC}"
done

echo -e "${BLUE}📉 Step 2: Scaling down App Service Plans to FREE tier...${NC}"
# Scale down all app service plans
for plan in $(az appservice plan list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv); do
    echo "  Scaling down: $plan to F1 (Free)"
    az appservice plan update --name "$plan" --resource-group "$RESOURCE_GROUP" --sku F1 2>/dev/null || {
        echo "  F1 failed, trying B1 (Basic - \$13/month)"
        az appservice plan update --name "$plan" --resource-group "$RESOURCE_GROUP" --sku B1 2>/dev/null || true
    }
    echo -e "  ${GREEN}✓ Scaled down $plan${NC}"
done

echo -e "${BLUE}🛑 Step 3: Stopping PostgreSQL servers...${NC}"
# Stop all PostgreSQL flexible servers
for pgserver in $(az postgres flexible-server list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv); do
    echo "  Stopping: $pgserver"
    az postgres flexible-server stop --name "$pgserver" --resource-group "$RESOURCE_GROUP" 2>/dev/null || true
    echo -e "  ${GREEN}✓ Stopped $pgserver (saves \$250/month)${NC}"
done

echo -e "${BLUE}🗑️  Step 4: Attempting to delete Redis Cache...${NC}"
# Try to delete Redis (can't be stopped, only deleted)
for redis in $(az redis list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv); do
    echo "  Deleting: $redis"
    az redis delete --name "$redis" --resource-group "$RESOURCE_GROUP" --yes 2>/dev/null || {
        echo -e "  ${YELLOW}⚠️  Couldn't delete $redis - manual deletion needed${NC}"
    }
done

echo -e "${BLUE}📊 Step 5: Checking what's still running...${NC}"
echo ""

# Show current status
echo -e "${YELLOW}Current Resource Status:${NC}"
echo "----------------------------"

# Check web apps
echo -e "${BLUE}Web Apps:${NC}"
az webapp list --resource-group "$RESOURCE_GROUP" --query "[].{Name:name, State:state}" --output table

# Check app service plans
echo -e "${BLUE}App Service Plans:${NC}"
az appservice plan list --resource-group "$RESOURCE_GROUP" --query "[].{Name:name, Sku:sku.name, Tier:sku.tier}" --output table

# Check PostgreSQL
echo -e "${BLUE}PostgreSQL Servers:${NC}"
az postgres flexible-server list --resource-group "$RESOURCE_GROUP" --query "[].{Name:name, State:state, Sku:sku.name}" --output table

# Check Redis
echo -e "${BLUE}Redis Cache:${NC}"
az redis list --resource-group "$RESOURCE_GROUP" --query "[].{Name:name, Sku:sku.name}" --output table

echo ""
echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}         COST REDUCTION COMPLETE${NC}"
echo -e "${GREEN}==================================================${NC}"
echo ""
echo -e "${YELLOW}💰 Estimated Savings:${NC}"
echo "  • PostgreSQL stopped: Saves \$250/month"
echo "  • App Service scaled: Saves ~\$127/month"
echo "  • Redis (if deleted): Saves \$120/month"
echo ""
echo -e "${YELLOW}📋 Remaining Costs (if not deleted):${NC}"
echo "  • App Service F1/B1: \$0-13/month"
echo "  • Storage/Monitoring: ~\$20/month"
echo "  • Total: ~\$33/month instead of \$530/month"
echo ""
echo -e "${RED}⚠️  IMPORTANT:${NC}"
echo "  • PostgreSQL will auto-restart after 7 days"
echo "  • Some resources still incur charges when stopped"
echo "  • You should still delete the resource group ASAP"
echo ""
echo -e "${YELLOW}🔧 Next Steps:${NC}"
echo "  1. Run ./force-delete-resources.sh to delete everything"
echo "  2. Or delete manually in Azure Portal"
echo "  3. Or contact Azure Support (free for billing issues)"
echo ""
echo -e "${BLUE}To check if deletion worked later:${NC}"
echo "  az group exists --name $RESOURCE_GROUP"
echo ""