# Azure Resource Deletion Troubleshooting Guide

## Problem: Cannot Delete Resource Group (429/409 Errors)

### Error Explanations

#### 429 - Too Many Requests
- Azure is rate-limiting your deletion attempts
- Usually happens after multiple failed attempts
- Azure has API throttling limits per subscription

#### 409 - Conflict
- Resources are in use or have dependencies
- Resources might have deletion locks
- Resources might be in a transitional state
- Azure Policies might be preventing deletion

## Solution Approaches (Try in Order)

### 1. Use the Force Delete Script
```bash
cd infrastructure/scripts
chmod +x force-delete-resources.sh
./force-delete-resources.sh
```

This script:
- Removes any resource locks
- Deletes resources in dependency order
- Uses retry logic with exponential backoff
- Tries multiple deletion methods

### 2. Manual Portal Deletion (Resource by Resource)

If the script fails, try deleting resources manually in this specific order:

1. **Application Insights Web Tests** (if any)
2. **Alerts and Action Groups**
3. **Web App Slots** (staging slots first)
4. **Web Apps** (frontend and backend)
5. **App Service Plan**
6. **PostgreSQL Databases** (databases before server)
7. **PostgreSQL Server**
8. **Redis Cache**
9. **Key Vault** (may need to purge after deletion)
10. **Storage Accounts**
11. **Log Analytics Workspace**
12. **Finally, the Resource Group**

#### Portal Tips:
- Wait 30 seconds between each deletion
- If you get 429, wait 5 minutes before continuing
- Use "Force Delete" option when available
- Check "Activity Log" for detailed error messages

### 3. Azure CLI with Specific Commands

```bash
# Set subscription
az account set --subscription c6fdd64b-f4ef-404f-aa8d-2b013bcd03ee

# List all resources
az resource list --resource-group afl-predictor-rg --output table

# Delete specific resource by ID (replace with actual ID)
az resource delete --ids "/subscriptions/.../resourceGroups/afl-predictor-rg/providers/..."

# Wait and retry group deletion
sleep 300  # Wait 5 minutes
az group delete --name afl-predictor-rg --yes --no-wait
```

### 4. PowerShell Alternative

```powershell
# Install Azure PowerShell if needed
Install-Module -Name Az -AllowClobber -Scope CurrentUser

# Connect
Connect-AzAccount

# Set subscription
Set-AzContext -SubscriptionId "c6fdd64b-f4ef-404f-aa8d-2b013bcd03ee"

# Force delete with job
Remove-AzResourceGroup -Name "afl-predictor-rg" -Force -AsJob

# Check job status
Get-Job
```

### 5. Check for Hidden Issues

#### Resource Locks
```bash
# List all locks
az lock list --resource-group afl-predictor-rg

# Delete all locks
az lock delete --resource-group afl-predictor-rg --name <lock-name>
```

#### Key Vault Soft Delete
Key Vaults have soft-delete protection. Even after deletion, they remain for 90 days:

```bash
# List soft-deleted vaults
az keyvault list-deleted

# Purge a soft-deleted vault
az keyvault purge --name afl-predictor-vault-prod
```

#### Azure Backup
If any VMs or databases had backup configured:
1. Go to Recovery Services Vault
2. Stop protection and delete backup data
3. Then delete the resources

### 6. Azure Service Health Check

1. Go to Azure Portal
2. Search for "Service Health"
3. Check for any issues in your region (Australia Southeast)
4. Check "Resource Health" for your subscription

### 7. Contact Azure Support (FREE for Billing Issues)

Since this is costing you money ($530/month), this qualifies for free support:

1. **Azure Portal Method:**
   - Go to Help + Support
   - Create Support Request
   - Issue Type: **Billing**
   - Problem Type: **Cannot delete resources/Unexpected charges**
   - Severity: B - Moderate impact
   - Describe: "Cannot delete resource group afl-predictor-rg, getting 429/409 errors, being charged $530/month"

2. **Information to Provide:**
   - Subscription ID: c6fdd64b-f4ef-404f-aa8d-2b013bcd03ee
   - Resource Group: afl-predictor-rg
   - Error codes: 429 and 409
   - "Resources were created during development testing and are no longer needed"

3. **What Support Can Do:**
   - Force delete from their end
   - Remove any hidden locks or policies
   - Provide billing credit for the period you couldn't delete

## Immediate Cost Mitigation

While waiting for deletion, minimize costs:

### 1. Stop All Services
```bash
# Stop App Services
az webapp stop --name afl-predictor-frontend-prod --resource-group afl-predictor-rg
az webapp stop --name afl-predictor-backend-prod --resource-group afl-predictor-rg

# Stop PostgreSQL
az postgres flexible-server stop --name afl-predictor-db-prod --resource-group afl-predictor-rg

# Scale down App Service Plan to Free
az appservice plan update --name afl-predictor-asp-prod --resource-group afl-predictor-rg --sku F1
```

### 2. Delete Expensive Resources First
Focus on deleting the most expensive resources:
- PostgreSQL Server ($250/month) - Delete this first!
- App Service Plan S2 ($140/month) - Scale to F1 or delete
- Redis Cache ($120/month) - Delete this

## Prevention for Future

1. **Use Development Subscriptions** for testing
2. **Set up Cost Alerts** at $50 threshold
3. **Use Azure Policy** to prevent expensive resources
4. **Tag all resources** with "temporary" for easy cleanup
5. **Use Resource Groups** properly (which you now are!)

## Quick Status Check

Run this to see current status:
```bash
# Check if RG exists
az group exists --name afl-predictor-rg

# List remaining resources
az resource list --resource-group afl-predictor-rg --output table

# Check current costs
az consumption usage list --start-date 2025-08-01 --end-date 2025-08-30
```

## Expected Timeline

- **Immediate**: Stop services to reduce costs
- **5-10 minutes**: Individual resource deletion
- **10-15 minutes**: Resource group deletion
- **1-24 hours**: If Azure Support intervention needed
- **Next billing cycle**: Charges should stop

## Success Confirmation

You'll know it's deleted when:
```bash
az group exists --name afl-predictor-rg
# Returns: false
```

And in the portal, the resource group no longer appears in your resource group list.