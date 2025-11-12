# Promotions and Rollbacks Guide

This guide explains how to promote deployments between environments (beta → gamma → prod) and rollback to previous versions when needed.

## Table of Contents

1. [Overview](#overview)
2. [Environment Promotion Strategy](#environment-promotion-strategy)
3. [Promoting Deployments](#promoting-deployments)
4. [Rolling Back Deployments](#rolling-back-deployments)
5. [Automation Scripts](#automation-scripts)

---

## Overview

### Deployment Stages

This project uses a **three-tier deployment strategy**:

```
beta (staging) → gamma (pre-production) → prod (production)
```

- **Beta**: Testing new features, experimental changes
- **Gamma**: Final testing before production, matches prod environment
- **Prod**: Production environment, customer-facing

### Promotion vs Rollback

| Operation | Definition | Use Case |
|-----------|-----------|----------|
| **Promotion** | Move code from lower to higher environment | Deploy tested features to production |
| **Rollback** | Revert to a previous deployment | Fix broken production deploy |

---

## Environment Promotion Strategy

### Method 1: Git-Based Promotion (Recommended)

This approach uses **git merges** to promote code between branches.

#### Workflow:

```
1. Develop on feature branch
2. Merge to beta branch → deploys to beta environment
3. Test on beta
4. Merge beta to gamma → deploys to gamma environment
5. Test on gamma
6. Merge gamma to prod → deploys to prod environment
```

#### Advantages:
- ✅ Full git history preserved
- ✅ Easy to track what's in each environment
- ✅ Simple rollback (revert commits)
- ✅ Automated deployment via GitHub Actions

#### Process:

```bash
# Step 1: Deploy to beta
git checkout beta
git merge feature/my-feature
git push origin beta
# Automatic deployment to beta environment

# Step 2: Test on beta, then promote to gamma
git checkout gamma
git merge beta
git push origin gamma
# Automatic deployment to gamma environment

# Step 3: Test on gamma, then promote to prod
git checkout prod
git merge gamma
git push origin prod
# Automatic deployment to production
```

---

### Method 2: Vercel Promotion (Frontend Only)

Vercel allows promoting specific deployments to production.

#### Using Vercel CLI:

```bash
# List recent deployments
vercel ls

# Promote a specific deployment to production
vercel promote <deployment-url>
```

#### Using Vercel Dashboard:

1. Go to your project on Vercel
2. Click on "Deployments" tab
3. Find the deployment you want to promote
4. Click "Promote to Production"

#### Advantages:
- ✅ Instant promotion (no redeploy)
- ✅ Test exact build that will go to production
- ❌ Only works for frontend (Vercel)
- ❌ No automatic backend promotion

---

### Method 3: Render Promotion (Backend)

Render doesn't have built-in promotion, but you can trigger deployments from specific commits.

#### Using Render API:

```bash
# Deploy specific commit to production service
curl -X POST "https://api.render.com/v1/services/[PROD_SERVICE_ID]/deploys" \
  -H "Authorization: Bearer $RENDER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "commit": "abc123xyz"
  }'
```

#### Using Render CLI:

```bash
# Trigger deployment for production service
render deploys create [PROD_SERVICE_ID] --commit abc123xyz
```

---

## Promoting Deployments

### Automated Promotion Script

We provide a `promote.sh` script for streamlined promotions.

#### Usage:

```bash
# Promote from beta to gamma
./promote.sh beta gamma

# Promote from gamma to prod
./promote.sh gamma prod

# Promote directly to prod (skip gamma)
./promote.sh beta prod
```

#### What It Does:

1. Validates source and target branches
2. Checks for uncommitted changes
3. Merges source branch into target branch
4. Pushes to remote (triggers automatic deployment)
5. Shows deployment URLs

#### Example:

```bash
$ ./promote.sh gamma prod

[INFO] Promoting from gamma to prod...
[INFO] Fetching latest changes...
[INFO] Checking out prod branch...
[INFO] Merging gamma into prod...
[SUCCESS] Merge complete
[INFO] Pushing to remote...
[SUCCESS] Pushed to origin/prod
[INFO] Deployment triggered automatically via GitHub Actions
[INFO] Monitor deployment: https://github.com/your-repo/actions
```

---

## Rolling Back Deployments

### Method 1: Git Revert (Safe, Recommended)

Creates a **new commit** that undoes previous changes. Preserves history.

#### Using Git:

```bash
# Rollback the last commit on prod
git checkout prod
git revert HEAD
git push origin prod
# Triggers new deployment with reverted changes
```

#### Rollback Multiple Commits:

```bash
# Rollback last 3 commits
git revert HEAD~3..HEAD
git push origin prod
```

#### Advantages:
- ✅ Preserves full history
- ✅ Safe (doesn't delete commits)
- ✅ Can rollback specific commits
- ✅ Triggers automatic redeployment

---

### Method 2: Git Reset (Dangerous, Use Carefully)

**Rewrites history** by moving branch pointer back. **Use only if absolutely necessary.**

#### Process:

```bash
# Find commit to rollback to
git log --oneline

# Reset to specific commit (rewrites history)
git checkout prod
git reset --hard abc123xyz
git push origin prod --force
# Triggers redeployment from that commit
```

#### ⚠️ Warnings:
- ❌ Rewrites git history (loses commits)
- ❌ Requires force push (dangerous)
- ❌ Can cause issues for team members
- ⚠️ **Only use on deployment branches (prod, gamma, beta), never on main!**

---

### Method 3: Vercel Rollback (Instant, Frontend Only)

Vercel keeps history of all deployments and allows instant rollback.

#### Using Vercel Dashboard:

1. Go to your project → Deployments
2. Find previous working deployment
3. Click "Promote to Production"
4. Previous version is instantly live (no rebuild)

#### Using Vercel CLI:

```bash
# List deployments
vercel ls

# Promote previous deployment
vercel promote https://your-app-xyz.vercel.app
```

#### Advantages:
- ✅ Instant rollback (uses cached build)
- ✅ No code changes needed
- ✅ Easy to test multiple versions
- ❌ Only works for frontend

---

### Method 4: Render Rollback

Render keeps deployment history and allows rollback via dashboard.

#### Using Render Dashboard:

1. Go to your service
2. Click on "Deploys" tab
3. Find previous successful deployment
4. Click "Redeploy"

#### Using Render API:

```bash
# Get deployment history
curl "https://api.render.com/v1/services/[SERVICE_ID]/deploys" \
  -H "Authorization: Bearer $RENDER_API_KEY"

# Redeploy specific previous deployment
curl -X POST "https://api.render.com/v1/services/[SERVICE_ID]/deploys/[DEPLOY_ID]/redeploy" \
  -H "Authorization: Bearer $RENDER_API_KEY"
```

---

## Automation Scripts

### promote.sh

Automates promotion between environments using git merges.

```bash
./promote.sh <source> <target>
```

**Examples:**
```bash
./promote.sh beta gamma      # Promote beta to gamma
./promote.sh gamma prod      # Promote gamma to prod
./promote.sh beta prod       # Skip gamma, go straight to prod
```

**Features:**
- ✅ Validates branch names
- ✅ Checks for conflicts
- ✅ Automatic push and deployment
- ✅ Shows deployment status

---

### rollback.sh

Automates rollback using git revert.

```bash
./rollback.sh <environment> [commits]
```

**Examples:**
```bash
./rollback.sh prod           # Rollback last commit on prod
./rollback.sh prod 3         # Rollback last 3 commits on prod
./rollback.sh gamma          # Rollback last commit on gamma
```

**Features:**
- ✅ Safe rollback using git revert
- ✅ Preserves history
- ✅ Automatic redeployment
- ✅ Confirmation prompts

---

## Best Practices

### Before Promoting to Production

1. **Test thoroughly on gamma**
   ```bash
   # Run tests
   npm test
   pytest

   # Manual QA on gamma environment
   ```

2. **Review changes**
   ```bash
   # See what's being promoted
   git diff prod..gamma
   ```

3. **Check for breaking changes**
   - API compatibility
   - Database migrations
   - Environment variables

4. **Notify team**
   - Slack/Discord notification
   - Create release notes

### During Rollback

1. **Identify the issue**
   - Check logs on Vercel/Render
   - Identify failing commit

2. **Communicate**
   - Notify team immediately
   - Update status page

3. **Rollback quickly**
   ```bash
   # Fast rollback using Vercel Dashboard
   # OR
   ./rollback.sh prod
   ```

4. **Fix forward when possible**
   - Prefer hot fixes over rollbacks
   - Only rollback for critical issues

### After Rollback

1. **Root cause analysis**
   - What went wrong?
   - Why wasn't it caught in gamma?

2. **Fix the issue**
   - Create fix on feature branch
   - Test on beta
   - Test on gamma
   - Re-promote to prod

3. **Update processes**
   - Add missing tests
   - Improve staging environment

---

## Example Workflows

### Workflow 1: Normal Promotion Flow

```bash
# Day 1: Develop feature
git checkout -b feature/new-login
# ... make changes ...
git add .
git commit -m "Add new login feature"

# Day 2: Deploy to beta for testing
git checkout beta
git merge feature/new-login
git push origin beta
# Auto-deploys to beta environment

# Day 3: Promote to gamma after testing
git checkout gamma
git merge beta
git push origin gamma
# Auto-deploys to gamma environment

# Day 4: Promote to prod after final testing
git checkout prod
git merge gamma
git push origin prod
# Auto-deploys to production
```

### Workflow 2: Emergency Rollback

```bash
# Production is broken!
# Check deployment history
git log prod --oneline

# Option 1: Quick rollback (revert last commit)
git checkout prod
git revert HEAD
git push origin prod

# Option 2: Instant rollback (Vercel only)
vercel promote https://previous-working-deployment.vercel.app

# Option 3: Use automation script
./rollback.sh prod 1
```

### Workflow 3: Selective Promotion

```bash
# Only promote specific commits (cherry-pick)
git checkout prod
git cherry-pick abc123xyz  # Specific commit from gamma
git push origin prod
```

---

## Monitoring Deployments

### Vercel

```bash
# Check deployment status
vercel ls

# View deployment logs
vercel logs <deployment-url>
```

### Render

```bash
# List services
render services list

# View deployment logs
render deploys list [SERVICE_ID]
```

### GitHub Actions

- Check GitHub Actions tab: https://github.com/your-repo/actions
- Each push triggers workflow run
- View logs for deployment status

---

## Quick Reference

### Promotion Commands

```bash
# Git-based (recommended)
git checkout gamma && git merge beta && git push
git checkout prod && git merge gamma && git push

# Using script
./promote.sh beta gamma
./promote.sh gamma prod
```

### Rollback Commands

```bash
# Git revert (safe)
git revert HEAD && git push

# Using script
./rollback.sh prod

# Vercel (instant)
vercel promote <previous-deployment-url>
```

---

## Summary

| Method | Speed | Safety | Complexity | Recommendation |
|--------|-------|--------|------------|----------------|
| Git Merge (Promotion) | Medium | ✅ High | Low | **Best for promotions** |
| Git Revert (Rollback) | Medium | ✅ High | Low | **Best for rollbacks** |
| Git Reset | Fast | ❌ Low | Medium | Avoid unless necessary |
| Vercel Promote | Instant | ✅ High | Low | Great for frontend |
| Render Redeploy | Fast | ✅ High | Low | Great for backend |

**Recommended Strategy:**
- **Promotions**: Use `promote.sh` script (git merge)
- **Rollbacks**: Use `rollback.sh` script (git revert) or platform dashboards

---

For more information, see:
- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment guide
- [AUTHENTICATION.md](AUTHENTICATION.md) - Authentication guide
