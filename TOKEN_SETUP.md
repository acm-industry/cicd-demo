# Token Setup Guide

This project supports **three methods** for managing authentication tokens. Choose the one that works best for you.

## Method 1: .env File (Recommended for Local Development)

### Setup

1. Copy the example file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and add your tokens:
   ```env
   VERCEL_TOKEN=your_vercel_token_here
   VERCEL_ORG_ID=your_org_id
   VERCEL_PROJECT_ID=your_project_id
   RENDER_API_KEY=your_render_key_here
   ```

3. Get your tokens:
   - Vercel: https://vercel.com/account/tokens
   - Render: https://dashboard.render.com/u/settings#api-keys

4. Get Vercel IDs:
   ```bash
   cd frontend
   vercel link
   cat .vercel/project.json
   # Copy orgId and projectId to .env
   ```

### How It Works

- The deployment scripts automatically load `.env` file
- Values are exported as environment variables
- `.env` is gitignored (never committed)
- Safe for local development

### Advantages

✅ Easy to manage - all tokens in one file
✅ No need to set environment variables each time
✅ Gitignored by default
✅ Works across all scripts (deploy, promote, rollback)

### Example .env File

```env
# Vercel Authentication
VERCEL_TOKEN=abc123xyz789verceltoken
VERCEL_ORG_ID=team_abc123
VERCEL_PROJECT_ID=prj_xyz789

# Render Authentication
RENDER_API_KEY=rnd_abc123xyz789renderkey
```

---

## Method 2: Environment Variables (Recommended for CI/CD)

### Setup

Set environment variables in your shell:

**Mac/Linux/WSL:**
```bash
export VERCEL_TOKEN=your_token
export RENDER_API_KEY=your_key

# Make permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export VERCEL_TOKEN=your_token' >> ~/.bashrc
echo 'export RENDER_API_KEY=your_key' >> ~/.bashrc
```

**Windows PowerShell:**
```powershell
$env:VERCEL_TOKEN="your_token"
$env:RENDER_API_KEY="your_key"

# Make permanent (System Properties → Environment Variables)
```

**Windows Command Prompt:**
```cmd
set VERCEL_TOKEN=your_token
set RENDER_API_KEY=your_key

# Make permanent (System Properties → Environment Variables)
```

### How It Works

- Environment variables override `.env` file
- Set once per terminal session
- Used by CI/CD systems (GitHub Actions)

### Advantages

✅ Higher priority than .env file
✅ Standard practice for CI/CD
✅ No file management needed
✅ Supported by all platforms

---

## Method 3: Interactive Login (Easiest for First Time)

### Setup

Just run the deployment script:

```bash
./deploy.sh
```

### How It Works

1. Script checks for tokens in `.env` or environment variables
2. If not found, prompts for interactive login:
   - **Vercel**: Opens browser for OAuth
   - **Render**: Asks to set API key manually
3. Credentials saved locally by CLIs

### Advantages

✅ No token management needed
✅ Browser-based authentication
✅ Good for trying the project first time

### Disadvantages

❌ Requires manual login each time (without .env)
❌ Render still needs API key set
❌ Not suitable for automation

---

## Priority Order

The scripts load tokens in this order:

```
1. .env file (if exists)
   ↓
2. Environment variables (override .env)
   ↓
3. Interactive login (fallback)
```

This means:
- `.env` is loaded first automatically
- Environment variables override `.env` values
- Interactive login only if no tokens found

### Example:

```bash
# If .env has VERCEL_TOKEN=token1
# And you run: export VERCEL_TOKEN=token2
# The script will use token2 (environment variable wins)
```

---

## For Different Scenarios

### Local Development (Recommended: .env)

```bash
# One-time setup
cp .env.example .env
# Edit .env with your tokens

# Deploy anytime
./deploy.sh
```

### Team Development (Recommended: .env + .gitignore)

```bash
# Each developer:
# 1. Creates their own .env file
# 2. Adds their own tokens
# 3. .env is gitignored (not shared)
```

### CI/CD Pipeline (Recommended: Environment Variables)

```yaml
# GitHub Actions
env:
  VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
  RENDER_API_KEY: ${{ secrets.RENDER_API_KEY }}
```

### First-Time Users (Recommended: Interactive)

```bash
# Just run the script
./deploy.sh

# Follow the prompts
# Then optionally create .env for next time
```

---

## Security Best Practices

### ✅ DO

1. **Use .env for local development**
   ```bash
   cp .env.example .env
   # Edit and add tokens
   ```

2. **Verify .env is gitignored**
   ```bash
   cat .gitignore  # Should include .env
   ```

3. **Use GitHub Secrets for CI/CD**
   - Repository → Settings → Secrets and variables → Actions

4. **Regenerate tokens if exposed**
   - Vercel: https://vercel.com/account/tokens
   - Render: https://dashboard.render.com/u/settings#api-keys

5. **Use different tokens per environment**
   - Development tokens (local .env)
   - CI/CD tokens (GitHub Secrets)

### ❌ DON'T

1. **Never commit .env to git**
   ```bash
   # BAD!
   git add .env
   git commit -m "Add tokens"
   ```

2. **Never hardcode tokens in scripts**
   ```bash
   # BAD!
   VERCEL_TOKEN="abc123"  # Hardcoded
   ```

3. **Never share .env files**
   - Each developer should have their own tokens

4. **Never log tokens**
   ```bash
   # BAD!
   echo "Token: $VERCEL_TOKEN"
   ```

5. **Never use production tokens in development**
   - Create separate projects/services for testing

---

## Troubleshooting

### "Environment variables not loading"

**Check .env file syntax:**
```bash
# Correct format (no spaces around =)
VERCEL_TOKEN=abc123

# Wrong format
VERCEL_TOKEN = abc123  # NO spaces!
```

### ".env file found but tokens not working"

**Verify tokens are correct:**
```bash
cat .env  # Check values
echo $VERCEL_TOKEN  # Verify loaded
```

### "Token works locally but not in CI/CD"

**Check GitHub Secrets:**
1. Go to repository Settings
2. Secrets and variables → Actions
3. Verify all secrets are set
4. Re-create if needed

### "Multiple .env files"

The scripts only load `.env` in the project root:
```
cicd-demo/
├── .env              ← Loaded by deploy.sh
├── frontend/.env     ← NOT loaded by deploy.sh
└── backend/.env      ← NOT loaded by deploy.sh
```

---

## Quick Reference

| Method | Best For | Priority | Setup Time |
|--------|----------|----------|------------|
| .env file | Local dev | 1 (lowest) | 2 min |
| Environment vars | CI/CD | 2 (medium) | 5 min |
| Interactive login | First time | 3 (fallback) | 1 min |

**Recommendation**: Use `.env` for local development and environment variables for CI/CD.

---

## Related Documentation

- [SETUP.md](SETUP.md) - Quick setup guide
- [AUTHENTICATION.md](AUTHENTICATION.md) - Detailed authentication guide
- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment guide

---

**Need help?** Check [SETUP.md](SETUP.md) for step-by-step instructions.
