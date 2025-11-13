#!/bin/bash

# Rollback Script
# Safely rollback deployments using git revert

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Print functions
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
echo "   Rollback Script"
echo "=========================================="
echo ""

# Check arguments
if [ $# -lt 1 ]; then
    print_error "Usage: ./rollback.sh <environment> [number_of_commits]"
    echo ""
    echo "Examples:"
    echo "  ./rollback.sh prod          # Rollback last commit on prod"
    echo "  ./rollback.sh prod 3        # Rollback last 3 commits on prod"
    echo "  ./rollback.sh gamma         # Rollback last commit on gamma"
    echo ""
    exit 1
fi

ENVIRONMENT=$1
COMMITS=${2:-1}  # Default to 1 commit if not specified

# Validate environment
VALID_ENVIRONMENTS=("beta" "gamma" "prod" "production" "main")

if [[ ! " ${VALID_ENVIRONMENTS[@]} " =~ " ${ENVIRONMENT} " ]]; then
    print_error "Invalid environment: $ENVIRONMENT"
    echo "Valid environments: ${VALID_ENVIRONMENTS[@]}"
    exit 1
fi

# Validate commits number
if ! [[ "$COMMITS" =~ ^[0-9]+$ ]] || [ "$COMMITS" -lt 1 ]; then
    print_error "Invalid number of commits: $COMMITS"
    echo "Must be a positive integer"
    exit 1
fi

print_info "Rolling back $COMMITS commit(s) on $ENVIRONMENT..."
echo ""

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    print_error "You have uncommitted changes. Please commit or stash them first."
    git status
    exit 1
fi

# Fetch latest changes
print_info "Fetching latest changes from remote..."
git fetch origin

# Check if branch exists
if ! git show-ref --verify --quiet "refs/heads/$ENVIRONMENT"; then
    print_error "Branch '$ENVIRONMENT' does not exist locally"
    print_info "Creating from remote..."
    git checkout -b "$ENVIRONMENT" "origin/$ENVIRONMENT"
fi

# Checkout environment branch
print_info "Checking out $ENVIRONMENT branch..."
git checkout "$ENVIRONMENT"
git pull origin "$ENVIRONMENT"

# Show commits to be rolled back
echo ""
print_info "The following commit(s) will be rolled back:"
echo ""
git log --oneline -n "$COMMITS"
echo ""

# Confirm rollback
print_warning "⚠️  WARNING: You are about to rollback $ENVIRONMENT ⚠️"
print_warning "This will create new commit(s) that reverse the changes"
echo ""
read -p "Are you sure? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Rollback cancelled"
    exit 0
fi

# Perform rollback
print_info "Performing rollback..."

if [ "$COMMITS" -eq 1 ]; then
    # Single commit rollback
    if git revert HEAD --no-edit; then
        print_success "Rollback complete"
    else
        print_error "Rollback failed. Please resolve conflicts manually."
        echo ""
        echo "To abort the revert: git revert --abort"
        echo "To resolve conflicts:"
        echo "  1. Fix conflicts in files"
        echo "  2. git add <resolved-files>"
        echo "  3. git revert --continue"
        echo "  4. git push origin $ENVIRONMENT"
        exit 1
    fi
else
    # Multiple commits rollback
    if git revert HEAD~$((COMMITS-1))..HEAD --no-edit; then
        print_success "Rollback complete"
    else
        print_error "Rollback failed. Please resolve conflicts manually."
        echo ""
        echo "To abort the revert: git revert --abort"
        echo "To resolve conflicts:"
        echo "  1. Fix conflicts in files"
        echo "  2. git add <resolved-files>"
        echo "  3. git revert --continue"
        echo "  4. git push origin $ENVIRONMENT"
        exit 1
    fi
fi

# Push to remote
print_info "Pushing rollback to remote..."
if git push origin "$ENVIRONMENT"; then
    print_success "Pushed to origin/$ENVIRONMENT"
else
    print_error "Push failed. Please check your permissions."
    exit 1
fi

# Trigger full deployment to ensure environments reflect rollback
echo ""
print_info "Running deployment script for branch '$ENVIRONMENT'..."
if ./deploy.sh; then
    print_success "Deploy script completed for $ENVIRONMENT"
else
    print_error "deploy.sh failed. Please review the logs above."
    exit 1
fi

echo ""
print_success "=========================================="
print_success "  Rollback Complete!"
print_success "=========================================="
echo ""
print_info "Environment: $ENVIRONMENT"
print_info "Commits rolled back: $COMMITS"
echo ""
print_info "Redeployment triggered automatically via GitHub Actions"
print_info "Monitor deployment at: https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/actions"
echo ""
print_info "Deployment URLs:"
case "$ENVIRONMENT" in
    prod|production|main)
        print_info "  Frontend: Check Vercel Dashboard (production)"
        print_info "  Backend: https://cicd-demo-backend-prod.onrender.com"
        ;;
    gamma)
        print_info "  Frontend: Check Vercel Dashboard (gamma preview)"
        print_info "  Backend: https://cicd-demo-backend-gamma.onrender.com"
        ;;
    beta)
        print_info "  Frontend: Check Vercel Dashboard (beta preview)"
        print_info "  Backend: https://cicd-demo-backend-beta.onrender.com"
        ;;
esac
echo ""
print_warning "Next Steps:"
echo "  1. Monitor the deployment"
echo "  2. Verify the rollback fixed the issue"
echo "  3. Investigate root cause"
echo "  4. Create fix and redeploy"
echo ""
