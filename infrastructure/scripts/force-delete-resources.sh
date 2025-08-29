#!/bin/bash

# Force deletion script for stubborn Azure resources
# Handles 429 (rate limiting) and 409 (conflict) errors

set +e  # Don't exit on error - we need to handle errors gracefully

# Configuration
SUBSCRIPTION_ID="c6fdd64b-f4ef-404f-aa8d-2b013bcd03ee"
RESOURCE_GROUP="afl-predictor-rg"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}==================================================${NC}"
echo -e "${YELLOW}   Azure Resource Force Deletion Tool${NC}"
echo -e "${YELLOW}==================================================${NC}"
echo ""
echo -e "${RED}⚠️  This script handles 429/409 deletion errors${NC}"
echo ""

# Login check
echo -e "${BLUE}📝 Checking Azure login...${NC}"
if ! az account show &>/dev/null; then
    echo "Please login to Azure..."
    az login
fi

# Set subscription
echo -e "${BLUE}📝 Setting subscription...${NC}"
az account set --subscription "$SUBSCRIPTION_ID"

# Function to retry with exponential backoff
retry_with_backoff() {
    local max_attempts=5
    local timeout=1
    local attempt=0
    local exitCode=0

    while [[ $attempt < $max_attempts ]]; do
        "$@"
        exitCode=$?

        if [[ $exitCode == 0 ]]; then
            break
        fi

        echo -e "${YELLOW}Attempt $((attempt + 1)) failed. Retrying in $timeout seconds...${NC}"
        sleep $timeout
        timeout=$((timeout * 2))
        attempt=$((attempt + 1))
    done

    return $exitCode
}

echo -e "${BLUE}🔍 Step 1: Checking if resource group exists...${NC}"
if ! az group exists --name "$RESOURCE_GROUP" | grep -q true; then
    echo -e "${GREEN}✅ Resource group $RESOURCE_GROUP does not exist!${NC}"
    exit 0
fi

echo -e "${BLUE}🔍 Step 2: Checking for resource locks...${NC}"
LOCKS=$(az lock list --resource-group "$RESOURCE_GROUP" --output json)
if [ "$(echo $LOCKS | jq '. | length')" -gt 0 ]; then
    echo -e "${RED}⚠️  Found resource locks. Removing them...${NC}"
    echo "$LOCKS" | jq -r '.[].id' | while read lock_id; do
        echo "Removing lock: $lock_id"
        retry_with_backoff az lock delete --ids "$lock_id"
    done
else
    echo -e "${GREEN}✅ No resource locks found${NC}"
fi

echo -e "${BLUE}🔍 Step 3: Listing all resources in the group...${NC}"
RESOURCES=$(az resource list --resource-group "$RESOURCE_GROUP" --output json)
RESOURCE_COUNT=$(echo $RESOURCES | jq '. | length')
echo -e "${YELLOW}Found $RESOURCE_COUNT resources${NC}"

echo -e "${BLUE}🗑️  Step 4: Attempting to delete resources individually...${NC}"
echo -e "${YELLOW}This helps avoid dependency conflicts${NC}"
echo ""

# Delete in specific order to handle dependencies
declare -a RESOURCE_ORDER=(
    "Microsoft.Insights/webTests"
    "Microsoft.Insights/metricAlerts"
    "Microsoft.Insights/components"
    "Microsoft.Insights/autoscalesettings"
    "Microsoft.Insights/actionGroups"
    "Microsoft.OperationalInsights/workspaces"
    "Microsoft.Web/sites/slots"
    "Microsoft.Web/sites"
    "Microsoft.Web/serverfarms"
    "Microsoft.Cache/Redis"
    "Microsoft.DBforPostgreSQL/flexibleServers/databases"
    "Microsoft.DBforPostgreSQL/flexibleServers/firewallRules"
    "Microsoft.DBforPostgreSQL/flexibleServers"
    "Microsoft.KeyVault/vaults"
    "Microsoft.Storage/storageAccounts"
)

for RESOURCE_TYPE in "${RESOURCE_ORDER[@]}"; do
    echo -e "${BLUE}Deleting $RESOURCE_TYPE resources...${NC}"
    
    echo "$RESOURCES" | jq -r --arg TYPE "$RESOURCE_TYPE" \
        '.[] | select(.type == $TYPE) | .id' | while read resource_id; do
        
        if [ ! -z "$resource_id" ]; then
            RESOURCE_NAME=$(echo "$resource_id" | rev | cut -d'/' -f1 | rev)
            echo -e "  Deleting: ${YELLOW}$RESOURCE_NAME${NC}"
            
            # Try to delete with retry logic
            if retry_with_backoff az resource delete --ids "$resource_id" --no-wait; then
                echo -e "  ${GREEN}✓ Deletion initiated for $RESOURCE_NAME${NC}"
            else
                echo -e "  ${RED}✗ Failed to delete $RESOURCE_NAME - will retry in group delete${NC}"
            fi
            
            # Small delay to avoid rate limiting
            sleep 2
        fi
    done
done

echo ""
echo -e "${BLUE}⏳ Step 5: Waiting for individual deletions to complete...${NC}"
echo "Waiting 30 seconds for resources to be deleted..."
sleep 30

echo -e "${BLUE}🔍 Step 6: Checking remaining resources...${NC}"
REMAINING=$(az resource list --resource-group "$RESOURCE_GROUP" --output json | jq '. | length')
echo -e "${YELLOW}$REMAINING resources remaining${NC}"

echo -e "${BLUE}💥 Step 7: Attempting to delete the entire resource group...${NC}"
echo "This will clean up any remaining resources..."

# Try multiple deletion methods
echo -e "${YELLOW}Method 1: Standard deletion with no-wait${NC}"
if az group delete --name "$RESOURCE_GROUP" --yes --no-wait; then
    echo -e "${GREEN}✅ Resource group deletion initiated${NC}"
else
    echo -e "${YELLOW}Method 1 failed, trying Method 2...${NC}"
    
    echo -e "${YELLOW}Method 2: Force deletion with PowerShell${NC}"
    # Try PowerShell if available
    if command -v pwsh &> /dev/null; then
        pwsh -Command "Remove-AzResourceGroup -Name '$RESOURCE_GROUP' -Force -AsJob"
        echo -e "${GREEN}✅ PowerShell deletion job started${NC}"
    else
        echo -e "${YELLOW}PowerShell not available${NC}"
    fi
fi

echo ""
echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}           Deletion Process Initiated${NC}"
echo -e "${GREEN}==================================================${NC}"
echo ""
echo -e "${YELLOW}📋 What to do next:${NC}"
echo ""
echo "1. Wait 5-10 minutes for deletion to complete"
echo ""
echo "2. Check if the resource group still exists:"
echo -e "   ${BLUE}az group exists --name $RESOURCE_GROUP${NC}"
echo ""
echo "3. Monitor deletion progress in Azure Portal:"
echo -e "   ${BLUE}https://portal.azure.com${NC}"
echo ""
echo "4. If still having issues after 10 minutes:"
echo "   a) Try running this script again"
echo "   b) Check Azure Service Health for any outages"
echo "   c) Contact Azure Support (free for billing issues)"
echo ""
echo -e "${YELLOW}💡 Common causes of deletion failures:${NC}"
echo "   • Azure Backup configured on resources"
echo "   • Azure Policy preventing deletion"
echo "   • Resources in transitional state"
echo "   • Subscription-level throttling"
echo ""
echo -e "${YELLOW}📧 To contact Azure Support:${NC}"
echo "   1. Go to Azure Portal > Help + Support"
echo "   2. Create a support request"
echo "   3. Issue type: Billing (free support)"
echo "   4. Problem: Cannot delete resources"
echo ""

# Final check after a delay
echo -e "${BLUE}Waiting 60 seconds before final check...${NC}"
sleep 60

if az group exists --name "$RESOURCE_GROUP" | grep -q false; then
    echo -e "${GREEN}✅ SUCCESS! Resource group has been deleted!${NC}"
    echo -e "${GREEN}You're now saving \$530/month!${NC}"
else
    echo -e "${YELLOW}⚠️  Resource group still exists.${NC}"
    echo -e "${YELLOW}It may still be deleting in the background.${NC}"
    echo -e "${YELLOW}Check again in a few minutes or contact Azure Support.${NC}"
fi