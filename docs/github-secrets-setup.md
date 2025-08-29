# GitHub Secrets Setup

## Required Secrets

The following secrets must be configured in your GitHub repository for the CI/CD pipeline to work:

### 1. AZURE_CREDENTIALS (Required)
Contains the Azure service principal credentials in JSON format.

```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "subscriptionId": "c6fdd64b-f4ef-404f-aa8d-2b013bcd03ee",
  "tenantId": "51e77625-3a01-45a4-9802-5285304ceb71"
}
```

### 2. DB_ADMIN_USERNAME (Optional)
PostgreSQL administrator username.
- Default: `afladmin`
- Recommended: Set a custom username for production

### 3. DB_ADMIN_PASSWORD (Optional)
PostgreSQL administrator password.
- Default: `P@ssw0rd123!` (CHANGE THIS!)
- Requirements: 
  - Minimum 8 characters
  - Must contain uppercase, lowercase, number, and special character
- **IMPORTANT**: Always set a strong, unique password for production

### 4. JWT_SECRET (Optional)
Secret key for JWT token signing.
- Default: `default-jwt-secret-change-in-production`
- **IMPORTANT**: Must be changed for production
- Generate with: `openssl rand -base64 32`

## How to Add Secrets

1. Go to your repository: https://github.com/ceej23/afl-data-capture
2. Click on **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with its name and value
5. Click **Add secret**

## Security Best Practices

1. **Never commit secrets to the repository**
2. **Use strong, unique passwords for production**
3. **Rotate secrets regularly**
4. **Limit access to GitHub secrets to trusted team members**
5. **Use different values for dev and production environments**

## Default Values (Development Only)

The workflow includes default values for quick development setup:
- `DB_ADMIN_USERNAME`: afladmin
- `DB_ADMIN_PASSWORD`: P@ssw0rd123!
- `JWT_SECRET`: default-jwt-secret-change-in-production

**⚠️ WARNING**: These defaults are for development only. Always set proper secrets for production deployments.

## Verifying Secrets

After adding secrets, you can verify they're available by:
1. Triggering a workflow run
2. Checking the workflow logs (secrets will be masked as ***)
3. Ensuring Terraform doesn't prompt for variables

## Troubleshooting

If deployment is stuck waiting for input:
1. Check all required secrets are set
2. Review the workflow logs for which variable is missing
3. Add the missing secret and re-run the workflow