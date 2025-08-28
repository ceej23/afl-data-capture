#!/bin/bash

# Azure App Service Rollback Script
# This script performs a rollback by swapping slots back

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-prod}
SERVICE=${2:-all}  # frontend, backend, or all

echo -e "${RED}🔄 AFL Predictor - Emergency Rollback${NC}"
echo -e "${RED}Environment: $ENVIRONMENT${NC}"
echo -e "${RED}Service: $SERVICE${NC}"
echo "================================================"

if [[ "$ENVIRONMENT" != "prod" ]]; then
    echo -e "${RED}❌ Rollback is only available for production environment${NC}"
    exit 1
fi

# Check prerequisites
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI is not installed.${NC}"
    exit 1
fi

# Login check
echo -e "${YELLOW}🔐 Checking Azure login...${NC}"
az account show &> /dev/null || az login

# Confirm rollback
echo -e "${RED}⚠️  WARNING: This will rollback the production deployment!${NC}"
echo -e "${RED}This action will swap the staging slot back to production.${NC}"
echo -e "${YELLOW}Are you sure you want to proceed? (yes/no)${NC}"
read -r response
if [[ "$response" != "yes" ]]; then
    echo "Rollback cancelled."
    exit 0
fi

# Function to rollback a service
rollback_service() {
    local service_name=$1
    local app_name="afl-predictor-${service_name}-prod"
    
    echo -e "${YELLOW}Rolling back ${service_name}...${NC}"
    
    # Swap slots back
    az webapp deployment slot swap \
        --name "$app_name" \
        --resource-group "afl-predictor-rg" \
        --slot "staging" \
        --target-slot "production"
    
    echo -e "${GREEN}✅ ${service_name} rolled back successfully${NC}"
    
    # Verify health
    echo -e "${YELLOW}Verifying ${service_name} health...${NC}"
    local health_endpoint=""
    if [[ "$service_name" == "backend" ]]; then
        health_endpoint="https://${app_name}.azurewebsites.net/health"
    else
        health_endpoint="https://${app_name}.azurewebsites.net/"
    fi
    
    response_code=$(curl -s -o /dev/null -w "%{http_code}" "$health_endpoint")
    if [[ "$response_code" == "200" ]]; then
        echo -e "${GREEN}✅ ${service_name} health check passed${NC}"
    else
        echo -e "${RED}⚠️  ${service_name} health check failed (HTTP $response_code)${NC}"
    fi
}

# Perform rollback
if [[ "$SERVICE" == "all" ]]; then
    rollback_service "frontend"
    rollback_service "backend"
elif [[ "$SERVICE" == "frontend" ]]; then
    rollback_service "frontend"
elif [[ "$SERVICE" == "backend" ]]; then
    rollback_service "backend"
else
    echo -e "${RED}❌ Invalid service: $SERVICE${NC}"
    echo "Valid options: frontend, backend, all"
    exit 1
fi

echo -e "${GREEN}✨ Rollback complete!${NC}"
echo ""
echo "Post-rollback checklist:"
echo "1. ✓ Verify application functionality"
echo "2. ✓ Check Application Insights for errors"
echo "3. ✓ Notify team of rollback"
echo "4. ✓ Investigate root cause"
echo "5. ✓ Plan fix and re-deployment"