# Authentication Guide

This guide explains how authentication works for both manual deployments (using CLI) and automated deployments (using GitHub Actions).

## Table of Contents

1. [Authentication Overview](#authentication-overview)
2. [Local CLI Authentication](#local-cli-authentication)
3. [GitHub Actions Authentication](#github-actions-authentication)
4. [Security Best Practices](#security-best-practices)

---

## Authentication Overview

There are **two different authentication flows** depending on how you're deploying:

### 1. **Local/Manual Deployment** (Using `deploy.sh` or `deploy.bat`)
- Uses **interactive CLI login** OR environment variables
- CLIs will prompt for authentication if not logged in
- Credentials stored locally on your machine

### 2. **Automated Deployment** (Using GitHub Actions)
- Uses **API tokens/keys** stored as GitHub Secrets
- No interactive prompts (fully automated)
- Credentials never stored in code

---

## Local CLI Authentication

### Vercel CLI Authentication

#### How It Works

The Vercel CLI has **two authentication methods**:

**Method 1: Interactive Login (Recommended for Local Development)**

```bash
vercel login
```

**What happens:**
1. Opens your browser automatically
2. You authenticate via Vercel's OAuth flow
3. CLI receives authentication token
4. Token is saved to `~/.vercel/auth.json` (Mac/Linux) or `%USERPROFILE%\.vercel\auth.json` (Windows)
5. All future `vercel` commands use this saved token

**Does it force authentication?**
- ✅ **YES** - If you run `vercel login`, it will always open the browser
- ✅ **YES** - If you run `vercel deploy` without being logged in, it will automatically prompt you to login
- ⚠️ The script checks `vercel whoami` first to avoid unnecessary login prompts

**Method 2: Environment Variable (Recommended for CI/CD)**

```bash
export VERCEL_TOKEN=your_token_here
vercel deploy --token $VERCEL_TOKEN
```

**What happens:**
1. No interactive prompt
2. Uses token directly from environment variable
3. Token is passed explicitly to every command

**Getting a Vercel Token:**
1. Go to https://vercel.com/account/tokens
2. Click "Create Token"
3. Give it a name (e.g., "CI/CD Demo")
4. Copy the token (shown only once!)
5. Set it as environment variable:
   ```bash
   # Mac/Linux/WSL
   export VERCEL_TOKEN=your_token_here

   # Windows PowerShell
   $env:VERCEL_TOKEN="your_token_here"

   # Windows Command Prompt
   set VERCEL_TOKEN=your_token_here
   ```

#### In Our deploy.sh Script

```bash
# Step 1: Check if VERCEL_TOKEN environment variable exists
if [ -z "$VERCEL_TOKEN" ]; then
    # No token found - try interactive login

    # Step 2: Check if already logged in
    if ! vercel whoami &> /dev/null; then
        # Not logged in - prompt for login
        echo "Please login to Vercel..."
        vercel login  # Opens browser for OAuth
    else
        # Already logged in - use saved credentials
        echo "Already logged in to Vercel"
    fi
else
    # Token found - use it directly
    vercel deploy --token $VERCEL_TOKEN
fi
```

**User Experience:**
- First time: Browser opens for OAuth login
- Subsequent runs: Uses saved credentials (no prompt)
- With `VERCEL_TOKEN` set: No prompts at all

---

### Render CLI Authentication

#### How It Works

The Render CLI has **two authentication methods**:

**Method 1: Interactive Login (For Local Development)**

```bash
render login
```

**What happens:**
1. Opens your browser automatically
2. You confirm authentication on Render's website
3. CLI receives authentication token
4. Token is saved locally to config file

**Does it force authentication?**
- ✅ **YES** - If you run `render login`, it will always open the browser
- ⚠️ **NO** - If you run `render` commands without being logged in, it will ERROR (not auto-prompt)
- Our script handles this by checking for `RENDER_API_KEY` first

**Method 2: API Key (Recommended for Both Local and CI/CD)**

```bash
export RENDER_API_KEY=your_api_key_here
render services list
```

**What happens:**
1. No interactive prompt
2. Uses API key directly from environment variable
3. API key takes precedence over CLI login

**Getting a Render API Key:**
1. Go to https://dashboard.render.com/u/settings#api-keys
2. Click "Create API Key"
3. Give it a name (e.g., "CI/CD Demo")
4. Copy the API key
5. Set it as environment variable:
   ```bash
   # Mac/Linux/WSL
   export RENDER_API_KEY=your_api_key_here

   # Windows PowerShell
   $env:RENDER_API_KEY="your_api_key_here"

   # Windows Command Prompt
   set RENDER_API_KEY=your_api_key_here
   ```

#### In Our deploy.sh Script

```bash
# Step 1: Check if RENDER_API_KEY environment variable exists
if [ -z "$RENDER_API_KEY" ]; then
    # No API key found - warn user
    echo "RENDER_API_KEY not found in environment"
    echo "Please set your Render API key:"
    echo "  export RENDER_API_KEY=your_api_key_here"

    # Ask if user wants to continue without Render
    read -p "Continue without Render? (y/n) "
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1  # User said no - exit script
    fi
    SKIP_RENDER=true  # Skip Render deployment
else
    # API key found - proceed with Render deployment
    render deploys create SERVICE_ID
fi
```

**User Experience:**
- Without `RENDER_API_KEY`: Script warns and asks if you want to skip Render
- With `RENDER_API_KEY` set: No prompts, automatic deployment
- **Important:** Render CLI does NOT auto-prompt like Vercel does

---

## GitHub Actions Authentication

### How GitHub Actions Authenticates

GitHub Actions uses **GitHub Secrets** to store sensitive credentials. These secrets are:
- Encrypted at rest
- Only accessible during workflow execution
- Never exposed in logs
- Injected as environment variables at runtime

### Setting Up GitHub Secrets

#### 1. Add Secrets to Your Repository

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret:

**Required Secrets:**

| Secret Name | Description | How to Get It |
|------------|-------------|---------------|
| `VERCEL_TOKEN` | Vercel authentication token | https://vercel.com/account/tokens |
| `VERCEL_ORG_ID` | Your Vercel organization ID | Run `vercel link` in frontend directory |
| `VERCEL_PROJECT_ID` | Your Vercel project ID | Run `vercel link` in frontend directory |
| `RENDER_API_KEY` | Render API key | https://dashboard.render.com/u/settings#api-keys |

#### 2. Getting Vercel IDs

```bash
cd frontend

# Link to Vercel project (or create new one)
vercel link

# This creates .vercel/project.json
cat .vercel/project.json
```

Example output:
```json
{
  "orgId": "team_abc123xyz",
  "projectId": "prj_xyz789abc"
}
```

Use these values for `VERCEL_ORG_ID` and `VERCEL_PROJECT_ID`.

#### 3. How GitHub Actions Uses Secrets

In `.github/workflows/deploy.yml`:

```yaml
- name: Deploy Frontend to Vercel
  env:
    VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
    VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
    VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}
  run: |
    cd frontend
    vercel deploy --token $VERCEL_TOKEN --yes
```

**What happens:**
1. GitHub Actions reads secrets from encrypted storage
2. Injects them as environment variables for that step only
3. Vercel CLI uses `--token $VERCEL_TOKEN` (no browser needed)
4. No interactive prompts (fully automated)

**For Render:**

```yaml
- name: Deploy Backend to Render
  env:
    RENDER_API_KEY: ${{ secrets.RENDER_API_KEY }}
  run: |
    # Render CLI automatically uses RENDER_API_KEY from environment
    render deploys create SERVICE_ID
```

---

## Security Best Practices

### ✅ DO

1. **Use Environment Variables for Automation**
   ```bash
   export VERCEL_TOKEN=xxx
   export RENDER_API_KEY=xxx
   ```

2. **Use GitHub Secrets for CI/CD**
   - Never hardcode tokens in workflows
   - Use `${{ secrets.SECRET_NAME }}`

3. **Use Interactive Login for Local Development**
   ```bash
   vercel login  # Saves credentials locally
   ```

4. **Regenerate Tokens if Exposed**
   - If you accidentally commit a token, regenerate it immediately

5. **Use Different Tokens for Different Environments**
   - Development token (local)
   - CI/CD token (GitHub Actions)

### ❌ DON'T

1. **Never Commit Tokens to Git**
   ```bash
   # BAD!
   export VERCEL_TOKEN=abc123xyz
   git add .
   git commit -m "Add deployment script"
   ```

2. **Never Share Tokens**
   - Tokens grant full access to your accounts
   - Each person should use their own tokens

3. **Never Use Production Tokens in Development**
   - Use separate projects/services for testing

4. **Never Log Tokens**
   ```bash
   # BAD!
   echo "Token: $VERCEL_TOKEN"
   ```

---

## Summary: Authentication Flow Comparison

### Local CLI (deploy.sh / deploy.bat)

| Step | Vercel CLI | Render CLI |
|------|-----------|------------|
| Check for token/key | ✅ Checks `VERCEL_TOKEN` | ✅ Checks `RENDER_API_KEY` |
| If not found | Opens browser for OAuth | ⚠️ Warns user (doesn't auto-prompt) |
| After first login | Saves credentials locally | Saves credentials locally |
| Subsequent runs | Uses saved credentials | Uses saved credentials |
| With env variable set | Uses token directly | Uses API key directly |
| Interactive? | **YES** (opens browser if needed) | **NO** (script handles it) |

### GitHub Actions

| Step | Vercel | Render |
|------|--------|--------|
| Authentication | Uses `${{ secrets.VERCEL_TOKEN }}` | Uses `${{ secrets.RENDER_API_KEY }}` |
| Interactive? | **NO** (fully automated) | **NO** (fully automated) |
| Credentials stored | GitHub Secrets (encrypted) | GitHub Secrets (encrypted) |
| Browser required? | **NO** | **NO** |

---

## Quick Reference

### First-Time Setup (Local)

```bash
# Option 1: Interactive Login
vercel login
render login

# Option 2: Environment Variables (Recommended)
export VERCEL_TOKEN=your_vercel_token
export RENDER_API_KEY=your_render_key

# Add to shell profile for persistence
echo 'export VERCEL_TOKEN=xxx' >> ~/.bashrc
echo 'export RENDER_API_KEY=xxx' >> ~/.bashrc
```

### First-Time Setup (GitHub Actions)

1. Get tokens:
   - Vercel: https://vercel.com/account/tokens
   - Render: https://dashboard.render.com/u/settings#api-keys

2. Get Vercel IDs:
   ```bash
   cd frontend && vercel link && cat .vercel/project.json
   ```

3. Add to GitHub Secrets:
   - Repository → Settings → Secrets and variables → Actions
   - Add: `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`, `RENDER_API_KEY`

### Running Deployments

```bash
# Mac/Linux/WSL
./deploy.sh

# Windows Command Prompt
deploy.bat

# Windows PowerShell
.\deploy.bat
```

---

## Troubleshooting

### "Vercel CLI not authenticated"

**Solution:**
```bash
vercel login
# OR
export VERCEL_TOKEN=your_token
```

### "Render API key not found"

**Solution:**
```bash
export RENDER_API_KEY=your_api_key
```

### "GitHub Actions: Vercel deployment failed"

**Check:**
1. Is `VERCEL_TOKEN` set in GitHub Secrets?
2. Is `VERCEL_ORG_ID` set in GitHub Secrets?
3. Is `VERCEL_PROJECT_ID` set in GitHub Secrets?
4. Has the token expired? (Regenerate if needed)

### "GitHub Actions: Render deployment failed"

**Check:**
1. Is `RENDER_API_KEY` set in GitHub Secrets?
2. Does the Render service exist?
3. Is the API key still valid?

---

**For more information, see [DEPLOYMENT.md](DEPLOYMENT.md)**
