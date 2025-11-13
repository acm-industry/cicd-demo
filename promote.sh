#!/bin/bash

# Promotion Script
# Promotes code from one environment to another using git merges

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
echo "   Environment Promotion Script"
echo "=========================================="
echo ""

# Check arguments
if [ $# -lt 2 ]; then
    print_error "Usage: ./promote.sh <source> <target>"
    echo ""
    echo "Examples:"
    echo "  ./promote.sh beta gamma      # Promote beta to gamma"
    echo "  ./promote.sh gamma prod      # Promote gamma to production"
    echo "  ./promote.sh beta prod       # Skip gamma, go to prod"
    echo ""
    exit 1
fi

SOURCE=$1
TARGET=$2

# Validate branch names
VALID_BRANCHES=("beta" "gamma" "prod" "production" "main")

if [[ ! " ${VALID_BRANCHES[@]} " =~ " ${SOURCE} " ]]; then
    print_error "Invalid source branch: $SOURCE"
    echo "Valid branches: ${VALID_BRANCHES[@]}"
    exit 1
fi

if [[ ! " ${VALID_BRANCHES[@]} " =~ " ${TARGET} " ]]; then
    print_error "Invalid target branch: $TARGET"
    echo "Valid branches: ${VALID_BRANCHES[@]}"
    exit 1
fi

if [ "$SOURCE" = "$TARGET" ]; then
    print_error "Source and target cannot be the same branch"
    exit 1
fi

print_info "Promoting from $SOURCE to $TARGET..."
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

# Check if branches exist
if ! git show-ref --verify --quiet "refs/heads/$SOURCE"; then
    print_error "Source branch '$SOURCE' does not exist locally"
    print_info "Creating from remote..."
    git checkout -b "$SOURCE" "origin/$SOURCE"
fi

if ! git show-ref --verify --quiet "refs/heads/$TARGET"; then
    print_error "Target branch '$TARGET' does not exist locally"
    print_info "Creating from remote..."
    git checkout -b "$TARGET" "origin/$TARGET"
fi

# Checkout source and pull latest
print_info "Updating source branch: $SOURCE"
git checkout "$SOURCE"
git pull origin "$SOURCE"

# Show what will be promoted
echo ""
print_info "Checking differences between $TARGET and $SOURCE..."
COMMIT_COUNT=$(git rev-list origin/$TARGET..origin/$SOURCE --count)

if [ "$COMMIT_COUNT" -eq 0 ]; then
    print_warning "No new commits to promote from $SOURCE to $TARGET"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
else
    print_info "$COMMIT_COUNT new commit(s) will be promoted:"
    echo ""
    git log --oneline origin/$TARGET..origin/$SOURCE
    echo ""
fi

# Confirm promotion
print_warning "You are about to promote $SOURCE to $TARGET"
echo ""
read -p "Are you sure? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Promotion cancelled"
    exit 0
fi

# Checkout target branch
print_info "Checking out target branch: $TARGET"
git checkout "$TARGET"
git pull origin "$TARGET"

# Merge source into target
print_info "Merging $SOURCE into $TARGET..."
if git merge "$SOURCE" -m "Promote $SOURCE to $TARGET"; then
    print_success "Merge complete"
else
    print_error "Merge failed. Please resolve conflicts manually."
    echo ""
    echo "To abort the merge: git merge --abort"
    echo "To resolve conflicts:"
    echo "  1. Fix conflicts in files"
    echo "  2. git add <resolved-files>"
    echo "  3. git commit"
    echo "  4. git push origin $TARGET"
    exit 1
fi

# Push to remote
print_info "Pushing $TARGET to remote..."
if git push origin "$TARGET"; then
    print_success "Pushed to origin/$TARGET"
else
    print_error "Push failed. Please check your permissions."
    exit 1
fi

echo ""
print_success "=========================================="
print_success "  Promotion Complete!"
print_success "=========================================="
echo ""
print_info "Promoted: $SOURCE → $TARGET"
print_info "Commits promoted: $COMMIT_COUNT"
echo ""
print_info "Deployment triggered automatically via GitHub Actions"
print_info "Monitor deployment at: https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/actions"
echo ""
print_info "Deployment URLs:"
case "$TARGET" in
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
