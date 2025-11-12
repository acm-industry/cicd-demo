# Quick Setup Guide

This guide will get you up and running with the CI/CD pipeline in minutes.

## Prerequisites

Install the required tools:

```bash
# Node.js and npm
node --version  # Should be 18+

# Python
python --version  # Should be 3.11+

# Vercel CLI
npm install -g vercel

# Render CLI (optional but recommended)
# Visit: https://render.com/docs/cli
```

## Step 1: Clone and Setup

```bash
# Clone the repository
git clone https://github.com/acm-industry/cicd-demo.git
cd cicd-demo

# Install frontend dependencies
cd frontend
npm install
cd ..

# Setup backend
cd backend
python setup.py
cd ..
```

## Step 2: Configure Authentication

### Option A: Using .env File (Recommended)

1. Copy the environment template:
   ```bash
   cp .env.example .env
   ```

2. Get your tokens:
   - **Vercel Token**: https://vercel.com/account/tokens
   - **Render API Key**: https://dashboard.render.com/u/settings#api-keys

3. Edit `.env` and fill in your tokens:
   ```env
   VERCEL_TOKEN=your_vercel_token_here
   VERCEL_ORG_ID=your_org_id_here
   VERCEL_PROJECT_ID=your_project_id_here
   RENDER_API_KEY=your_render_key_here
   ```

4. Get Vercel project IDs:
   ```bash
   cd frontend
   vercel link
   cat .vercel/project.json  # Copy orgId and projectId to .env
   cd ..
   ```

### Option B: Using Environment Variables

```bash
# Mac/Linux/WSL
export VERCEL_TOKEN=your_token_here
export RENDER_API_KEY=your_key_here

# Windows PowerShell
$env:VERCEL_TOKEN="your_token_here"
$env:RENDER_API_KEY="your_key_here"

# Windows Command Prompt
set VERCEL_TOKEN=your_token_here
set RENDER_API_KEY=your_key_here
```

### Option C: Interactive Login

Just run the deploy script and follow the prompts:

```bash
./deploy.sh  # Will prompt for Vercel login
```

## Step 3: Deploy

```bash
# Make script executable (Mac/Linux/WSL)
chmod +x deploy.sh

# Run deployment
./deploy.sh  # Mac/Linux/WSL
# OR
deploy.bat   # Windows
```

## Step 4: Create Deployment Branches

```bash
# Create beta branch
git checkout -b beta
git push origin beta

# Create gamma branch
git checkout -b gamma
git push origin gamma

# Create prod branch
git checkout -b prod
git push origin prod
```

## Step 5: Setup GitHub Actions (Optional)

For automated deployments on push:

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Add these secrets:
   - `VERCEL_TOKEN`
   - `VERCEL_ORG_ID`
   - `VERCEL_PROJECT_ID`
   - `RENDER_API_KEY`

4. Push to any branch - automatic deployment will trigger!

## Quick Reference

### Deploy Current Branch
```bash
./deploy.sh
```

### Promote Between Environments
```bash
./promote.sh beta gamma    # Beta → Gamma
./promote.sh gamma prod    # Gamma → Production
```

### Rollback
```bash
./rollback.sh prod         # Rollback last commit
./rollback.sh prod 3       # Rollback last 3 commits
```

## File Structure

```
.env                    # Your tokens (gitignored)
.env.example            # Template for tokens
deploy.sh               # Deployment script (Mac/Linux/WSL)
deploy.bat              # Deployment script (Windows)
promote.sh              # Promotion script
rollback.sh             # Rollback script
```

## Environment Priority

The scripts load tokens in this order:

1. **`.env` file** (if exists) - Loaded first
2. **Environment variables** - Override .env if set
3. **Interactive login** - Fallback if no tokens found

This means you can:
- Use `.env` for local development
- Override with environment variables in CI/CD
- Fall back to interactive login for first-time setup

## Security Notes

- ✅ `.env` is gitignored and will NOT be committed
- ✅ Never commit tokens to the repository
- ✅ Use GitHub Secrets for CI/CD
- ⚠️ Regenerate tokens if exposed

## Troubleshooting

### ".env file not found"

This is normal! Copy the example:
```bash
cp .env.example .env
```

### "Token invalid"

Check that you copied the full token:
```bash
# Should be a long string like:
VERCEL_TOKEN=abc123xyz789...
```

### "Permission denied: deploy.sh"

Make it executable:
```bash
chmod +x deploy.sh promote.sh rollback.sh
```

### "Vercel project not linked"

Link your project first:
```bash
cd frontend
vercel link
```

## What's Next?

- Read [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment guide
- Read [AUTHENTICATION.md](AUTHENTICATION.md) for authentication details
- Read [PROMOTIONS_ROLLBACKS.md](PROMOTIONS_ROLLBACKS.md) for promotion strategies

---

**Ready to deploy?** Run `./deploy.sh` and you're done! 🚀
