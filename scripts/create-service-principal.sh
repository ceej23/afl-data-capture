#!/bin/bash

# Azure Service Principal Creation Script
# This creates the service principal needed for GitHub Actions deployment

set -e

# Configuration
SUBSCRIPTION_ID="c6fdd64b-f4ef-404f-aa8d-2b013bcd03ee"
TENANT_ID="51e77625-3a01-45a4-9802-5285304ceb71"
SP_NAME="afl-data-capture-sp"

echo "🚀 Creating Azure Service Principal for AFL Data Capture"
echo "=================================================="
echo "Subscription ID: $SUBSCRIPTION_ID"
echo "Tenant ID: $TENANT_ID"
echo ""

# Check if user is logged in
echo "📝 Checking Azure login status..."
if ! az account show &>/dev/null; then
    echo "❌ Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

# Set the subscription
echo "📝 Setting subscription..."
az account set --subscription "$SUBSCRIPTION_ID"

# Create service principal
echo "🔐 Creating service principal..."
SP_OUTPUT=$(az ad sp create-for-rbac \
    --name "$SP_NAME" \
    --role contributor \
    --scopes "/subscriptions/$SUBSCRIPTION_ID" \
    --sdk-auth)

# Parse the output
CLIENT_ID=$(echo "$SP_OUTPUT" | jq -r '.clientId')
CLIENT_SECRET=$(echo "$SP_OUTPUT" | jq -r '.clientSecret')

# Create the AZURE_CREDENTIALS secret format
AZURE_CREDENTIALS=$(cat <<EOF
{
  "clientId": "$CLIENT_ID",
  "clientSecret": "$CLIENT_SECRET",
  "subscriptionId": "$SUBSCRIPTION_ID",
  "tenantId": "$TENANT_ID"
}
EOF
)

# Save to file
OUTPUT_FILE="azure-credentials.json"
echo "$AZURE_CREDENTIALS" > "$OUTPUT_FILE"

echo ""
echo "✅ Service Principal created successfully!"
echo "=================================================="
echo ""
echo "📋 NEXT STEPS:"
echo ""
echo "1. Go to: https://github.com/ceej23/afl-data-capture/settings/secrets/actions"
echo ""
echo "2. Create a new repository secret named: AZURE_CREDENTIALS"
echo ""
echo "3. Copy and paste this JSON value:"
echo ""
echo "$AZURE_CREDENTIALS"
echo ""
echo "4. Click 'Add secret'"
echo ""
echo "⚠️  IMPORTANT: The credentials have been saved to '$OUTPUT_FILE'"
echo "   Delete this file after adding the secret to GitHub!"
echo ""
echo "5. After adding the secret, run: rm $OUTPUT_FILE"
echo ""
echo "📝 Additional secrets you may want to add:"
echo "   - AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
echo "   - AZURE_TENANT_ID: $TENANT_ID"
echo ""