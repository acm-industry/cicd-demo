# CI/CD Deployment Guide

This guide covers how to deploy the frontend (Next.js) to Vercel and the backend (Flask) to Render using automated CI/CD pipelines.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Authentication Setup](#authentication-setup)
4. [Manual Deployment](#manual-deployment)
5. [Automated Deployment](#automated-deployment)
6. [Branch Strategy](#branch-strategy)
7. [Environment Variables](#environment-variables)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

1. **Node.js** (v18 or higher)
   ```bash
   node --version
   ```

2. **Python** (v3.11 or higher)
   ```bash
   python --version
   ```

3. **Git**
   ```bash
   git --version
   ```

4. **Vercel CLI**
   ```bash
   npm install -g vercel
   vercel --version
   ```

5. **Render CLI** (Optional but recommended)
   - Visit: https://render.com/docs/cli
   - Follow installation instructions for your platform

### Required Accounts

1. **Vercel Account**: https://vercel.com/signup
2. **Render Account**: https://render.com/register
3. **GitHub Account**: https://github.com/signup (for repository hosting)

---

## Quick Start

For a complete automated deployment:

```bash
# Make the deployment script executable (Mac/Linux/WSL)
chmod +x deploy.sh

# Run the deployment script
./deploy.sh
```

The script will:
- Detect your current git branch
- Check for required CLI tools
- Prompt for authentication if needed
- Deploy frontend to Vercel
- Deploy backend to Render (if service exists)

---

## Authentication Setup

### Vercel Authentication

#### Option 1: Interactive Login (Recommended for Training)

```bash
vercel login
```

This will open your browser for OAuth authentication. Your credentials are saved locally.

#### Option 2: API Token (Recommended for CI/CD)

1. Go to https://vercel.com/account/tokens
2. Click "Create Token"
3. Give it a name (e.g., "CI/CD Demo")
4. Copy the token
5. Set environment variable:

   **Mac/Linux/WSL:**
   ```bash
   export VERCEL_TOKEN=your_token_here
   # Add to ~/.bashrc or ~/.zshrc for persistence
   echo 'export VERCEL_TOKEN=your_token_here' >> ~/.bashrc
   ```

   **Windows (PowerShell):**
   ```powershell
   $env:VERCEL_TOKEN="your_token_here"
   # For persistence, add to your PowerShell profile
   ```

   **Windows (Git Bash):**
   ```bash
   export VERCEL_TOKEN=your_token_here
   # Add to ~/.bashrc
   echo 'export VERCEL_TOKEN=your_token_here' >> ~/.bashrc
   ```

6. You'll also need Project ID and Org ID:
   ```bash
   # Navigate to frontend directory
   cd frontend

   # Link to Vercel project (or create new one)
   vercel link

   # This creates .vercel/project.json with IDs
   ```

### Render Authentication

1. Go to https://dashboard.render.com/u/settings#api-keys
2. Click "Create API Key"
3. Give it a name (e.g., "CI/CD Demo")
4. Copy the API key
5. Set environment variable:

   **Mac/Linux/WSL:**
   ```bash
   export RENDER_API_KEY=your_api_key_here
   # Add to ~/.bashrc or ~/.zshrc for persistence
   echo 'export RENDER_API_KEY=your_api_key_here' >> ~/.bashrc
   ```

   **Windows (PowerShell):**
   ```powershell
   $env:RENDER_API_KEY="your_api_key_here"
   ```

   **Windows (Git Bash):**
   ```bash
   export RENDER_API_KEY=your_api_key_here
   echo 'export RENDER_API_KEY=your_api_key_here' >> ~/.bashrc
   ```

---

## Manual Deployment

### Deploy Frontend to Vercel

```bash
cd frontend

# Preview deployment (any branch except main)
vercel deploy

# Production deployment (main branch)
vercel deploy --prod

# With branch metadata for proper branch detection
vercel deploy \
  -m githubDeployment="1" \
  -m githubCommitRef="$(git rev-parse --abbrev-ref HEAD)"
```

### Deploy Backend to Render

#### First-Time Setup (Create Service)

1. Go to https://dashboard.render.com/create?type=web
2. Connect your GitHub repository
3. Configure the service:
   - **Name**: `cicd-demo-backend-main` (or use branch-specific name)
   - **Branch**: `main` (or your desired branch)
   - **Runtime**: Python 3
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `python server.py`
4. Add environment variables from `backend/.env.example`:
   - `FLASK_ENV=production`
   - `PORT=8080`
   - `PYTHON_VERSION=3.11.0`
5. Click "Create Web Service"

#### Subsequent Deployments

```bash
# Using Render CLI
render services list  # Get your service ID
render deploys create <SERVICE_ID> --wait

# Or trigger via Deploy Hook
curl https://api.render.com/deploy/srv-XXXXX?key=YYYYY
```

---

## Automated Deployment

### Using the Deployment Script

The `deploy.sh` script automates the entire deployment process:

```bash
# Ensure script is executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

**What the script does:**

1. **Branch Detection**: Automatically detects your current git branch
2. **Tool Validation**: Checks for Vercel CLI and Render CLI
3. **Authentication Check**: Verifies tokens or prompts for login
4. **Frontend Deployment**: Deploys to Vercel with appropriate environment
5. **Backend Deployment**: Triggers Render deployment (if service exists)
6. **Status Report**: Shows deployment URLs and status

### Script Behavior by Branch

- **`main` branch**: Deploys to production
- **Other branches**: Deploys to preview/staging environments

---

## Branch Strategy

### Production Branch: `main`

- Deploys to production Vercel environment (`--prod` flag)
- Uses Render service named `cicd-demo-backend-main`
- Accessible at production URLs

### Preview/Staging Branches

- Any branch other than `main`
- Deploys to Vercel preview environment
- Uses separate Render services (e.g., `cicd-demo-backend-staging`)
- Each branch can have its own backend service

### Recommended Workflow

```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes
# ...

# Deploy to preview
./deploy.sh

# Test preview deployment
# ...

# Merge to main when ready
git checkout main
git merge feature/new-feature
git push

# Deploy to production
./deploy.sh
```

---

## Environment Variables

### Frontend (Next.js)

Copy `frontend/.env.example` to `frontend/.env.local`:

```bash
cd frontend
cp .env.example .env.local
```

Edit `.env.local`:

```env
# For local development
NEXT_PUBLIC_API_URL=http://localhost:8080

# For production (set in Vercel Dashboard)
# NEXT_PUBLIC_API_URL=https://your-backend.onrender.com
```

**Set in Vercel Dashboard:**

1. Go to your project settings
2. Navigate to "Environment Variables"
3. Add `NEXT_PUBLIC_API_URL` with your Render backend URL
4. Select appropriate environments (Production, Preview, Development)

### Backend (Flask)

Copy `backend/.env.example` to `backend/.env`:

```bash
cd backend
cp .env.example .env
```

Edit `.env`:

```env
FLASK_ENV=development
PORT=8080
PYTHON_VERSION=3.11.0
CORS_ORIGINS=http://localhost:3000,https://your-frontend.vercel.app
```

**Set in Render Dashboard:**

1. Go to your service settings
2. Navigate to "Environment"
3. Add all variables from `.env.example`
4. Update `CORS_ORIGINS` with your Vercel frontend URL

---

## Troubleshooting

### Common Issues

#### 1. "Vercel CLI not found"

**Solution:**
```bash
npm install -g vercel
```

#### 2. "VERCEL_TOKEN not found"

**Solution:**
```bash
# Either login interactively
vercel login

# Or set token
export VERCEL_TOKEN=your_token_here
```

#### 3. "Render service not found"

**Solution:**
- Create the service manually first through Render Dashboard
- Run `deploy.sh` again after service creation

#### 4. "Failed to detect git branch"

**Solution:**
```bash
# Ensure you're in a git repository
git status

# If not, initialize git
git init
git add .
git commit -m "Initial commit"
```

#### 5. "CORS errors in frontend"

**Solution:**
- Ensure backend `CORS_ORIGINS` includes your frontend URL
- Update environment variable in Render Dashboard
- Redeploy backend

#### 6. "Vercel deployment shows old code"

**Solution:**
```bash
# Force new deployment
vercel deploy --force --prod
```

#### 7. "Permission denied: ./deploy.sh"

**Solution:**
```bash
chmod +x deploy.sh
```

#### 8. "Script fails on Windows"

**Solution:**
- Use Git Bash instead of Command Prompt/PowerShell
- Or use WSL2 (Windows Subsystem for Linux)

---

## Advanced Configuration

### GitHub Actions (Automated CI/CD)

For fully automated deployments on every push, see `.github/workflows/deploy.yml`.

**To enable:**

1. Add secrets to GitHub repository:
   - `VERCEL_TOKEN`
   - `VERCEL_ORG_ID`
   - `VERCEL_PROJECT_ID`
   - `RENDER_API_KEY`

2. Push to repository - deployments happen automatically

### Custom Domains

#### Vercel (Frontend)
1. Go to project settings → Domains
2. Add your custom domain
3. Configure DNS records as instructed

#### Render (Backend)
1. Go to service settings → Custom Domains
2. Add your custom domain
3. Configure DNS records as instructed

---

## Training Tips

For training purposes, this setup demonstrates:

1. **Branch-based deployments**: Different branches → different environments
2. **Authentication in CI/CD**: Token management and security
3. **Platform-specific configurations**: Vercel vs Render requirements
4. **Environment variable management**: Different values per environment
5. **Automated deployment scripts**: Shell scripting for DevOps
6. **Multi-service coordination**: Frontend + Backend deployment orchestration

---

## Additional Resources

- **Vercel Documentation**: https://vercel.com/docs
- **Render Documentation**: https://render.com/docs
- **Next.js Documentation**: https://nextjs.org/docs
- **Flask Documentation**: https://flask.palletsprojects.com/

---

## Support

If you encounter issues:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review platform-specific documentation
3. Check deployment logs in Vercel/Render dashboards
4. Verify environment variables are set correctly

---

**Happy Deploying!** 🚀
