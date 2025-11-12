#!/bin/bash

# CI/CD Deployment Script
# Automatically deploys frontend to Vercel and backend to Render based on current branch

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Banner
echo ""
echo "=========================================="
echo "   CI/CD Deployment Script"
echo "=========================================="
echo ""

# Load environment variables from .env file if it exists
if [ -f ".env" ]; then
    print_info "Loading environment variables from .env file..."
    export $(cat .env | grep -v '^#' | grep -v '^[[:space:]]*$' | xargs)
    print_success "Environment variables loaded from .env"
    echo ""
fi

# Step 1: Detect current branch
print_info "Detecting current git branch..."
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$BRANCH" ]; then
    print_error "Failed to detect git branch. Are you in a git repository?"
    exit 1
fi

print_success "Current branch: $BRANCH"
echo ""

# Step 2: Check for required CLI tools
print_info "Checking for required CLI tools..."

# Check for Vercel CLI
if ! command -v vercel &> /dev/null; then
    print_error "Vercel CLI not found. Please install it:"
    echo "  npm install -g vercel"
    exit 1
fi
print_success "Vercel CLI found"

# Check for Render CLI
if ! command -v render &> /dev/null; then
    print_warning "Render CLI not found. Install it from: https://render.com/docs/cli"
    print_info "Continuing without Render deployment..."
    SKIP_RENDER=true
else
    print_success "Render CLI found"
    SKIP_RENDER=false
fi

echo ""

# Step 3: Check authentication
print_info "Checking authentication..."

# Check Vercel authentication
if [ -z "$VERCEL_TOKEN" ]; then
    print_warning "VERCEL_TOKEN not found in environment"
    print_info "Attempting to use local Vercel credentials..."
    print_info "If this is your first time, you'll be prompted to login"
    echo ""

    # Check if already logged in
    if ! vercel whoami &> /dev/null; then
        print_info "Please login to Vercel..."
        vercel login
    else
        print_success "Already logged in to Vercel"
    fi
else
    print_success "VERCEL_TOKEN found"
fi

# Check Render authentication
if [ "$SKIP_RENDER" = false ]; then
    if [ -z "$RENDER_API_KEY" ]; then
        print_warning "RENDER_API_KEY not found in environment"
        print_info "Please set your Render API key:"
        echo "  export RENDER_API_KEY=your_api_key_here"
        echo ""
        print_info "Get your API key from: https://dashboard.render.com/u/settings#api-keys"
        echo ""
        read -p "Do you want to continue without deploying to Render? (y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
        SKIP_RENDER=true
    else
        print_success "RENDER_API_KEY found"
    fi
fi

echo ""

# Step 4: Deploy Frontend to Vercel
print_info "Deploying frontend to Vercel..."
cd frontend

# Determine deployment environment based on branch
case "$BRANCH" in
    prod|production|main)
        DEPLOY_ENV="production"
        VERCEL_ARGS="--prod"
        EFFECTIVE_BRANCH="prod"
        print_info "Deploying to PRODUCTION environment"
        ;;
    gamma)
        DEPLOY_ENV="gamma"
        VERCEL_ARGS=""
        EFFECTIVE_BRANCH="gamma"
        print_info "Deploying to GAMMA (pre-production) environment"
        ;;
    beta)
        DEPLOY_ENV="beta"
        VERCEL_ARGS=""
        EFFECTIVE_BRANCH="beta"
        print_info "Deploying to BETA (staging) environment"
        ;;
    *)
        DEPLOY_ENV="preview"
        VERCEL_ARGS=""
        EFFECTIVE_BRANCH="$BRANCH"
        print_info "Deploying to PREVIEW environment"
        ;;
esac

# Deploy with branch metadata
if [ -n "$VERCEL_TOKEN" ]; then
    VERCEL_URL=$(vercel deploy $VERCEL_ARGS \
        --token "$VERCEL_TOKEN" \
        --yes \
        -m githubDeployment="1" \
        -m githubCommitRef="$BRANCH" \
        2>&1 | grep -Eo 'https://[^ ]+' | tail -1)
else
    VERCEL_URL=$(vercel deploy $VERCEL_ARGS \
        --yes \
        -m githubDeployment="1" \
        -m githubCommitRef="$BRANCH" \
        2>&1 | grep -Eo 'https://[^ ]+' | tail -1)
fi

if [ -z "$VERCEL_URL" ]; then
    print_error "Failed to deploy frontend to Vercel"
    cd ..
    exit 1
fi

print_success "Frontend deployed to: $VERCEL_URL"
cd ..

echo ""

# Step 5: Deploy Backend to Render
if [ "$SKIP_RENDER" = false ]; then
    print_info "Deploying backend to Render..."
    cd backend

    # Determine service name based on branch
    case "$BRANCH" in
        prod|production|main)
            SERVICE_NAME="cicd-demo-backend-prod"
            ;;
        gamma)
            SERVICE_NAME="cicd-demo-backend-gamma"
            ;;
        beta)
            SERVICE_NAME="cicd-demo-backend-beta"
            ;;
        *)
            # Sanitize branch name for service name (replace special chars with hyphens)
            SANITIZED_BRANCH=$(echo "$BRANCH" | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]')
            SERVICE_NAME="cicd-demo-backend-$SANITIZED_BRANCH"
            ;;
    esac

    print_info "Service name: $SERVICE_NAME"

    # Check if service exists
    print_info "Checking if Render service exists..."
    SERVICE_ID=$(render services list --format json 2>/dev/null | grep -o "\"id\":\"$SERVICE_NAME\"" | head -1 | cut -d'"' -f4)

    if [ -z "$SERVICE_ID" ]; then
        print_warning "Service '$SERVICE_NAME' not found"
        print_info "You need to create this service manually on Render Dashboard:"
        echo "  1. Go to https://dashboard.render.com/create?type=web"
        echo "  2. Connect your GitHub repository"
        echo "  3. Set service name: $SERVICE_NAME"
        echo "  4. Set branch: $BRANCH"
        echo "  5. Set build command: pip install -r requirements.txt"
        echo "  6. Set start command: python server.py"
        echo "  7. Add environment variables from backend/.env.example"
        echo ""
        print_info "After creating the service, run this script again"
    else
        print_success "Service found: $SERVICE_ID"
        print_info "Triggering deployment..."

        # Get current commit SHA
        COMMIT_SHA=$(git rev-parse HEAD)

        # Trigger deployment
        render deploys create "$SERVICE_ID" --commit "$COMMIT_SHA" --wait

        if [ $? -eq 0 ]; then
            print_success "Backend deployed successfully"
            print_info "View your service at: https://dashboard.render.com/web/$SERVICE_ID"
        else
            print_error "Failed to deploy backend"
        fi
    fi

    cd ..
else
    print_warning "Skipping Render deployment"
fi

echo ""
print_success "=========================================="
print_success "  Deployment Complete!"
print_success "=========================================="
echo ""
print_info "Frontend URL: $VERCEL_URL"
if [ "$SKIP_RENDER" = false ] && [ -n "$SERVICE_ID" ]; then
    print_info "Backend Service: https://dashboard.render.com/web/$SERVICE_ID"
fi
echo ""
