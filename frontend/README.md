# Frontend - Next.js Application

HTTP Request Builder frontend built with Next.js, React, and TypeScript.

## Tech Stack

- **Framework**: Next.js 16.0.2 (App Router)
- **React**: 19.2.0
- **TypeScript**: ^5
- **Styling**: Inline styles with CSS modules
- **Deployment**: Vercel

## Project Structure

```
frontend/
├── src/
│   ├── app/
│   │   ├── page.tsx          # Main page - HTTP Request Builder
│   │   ├── layout.tsx         # Root layout with metadata
│   │   ├── globals.css        # Global styles
│   │   └── favicon.ico        # Favicon
│   └── components/
│       ├── Header.tsx         # Header component with logo
│       └── Body.tsx           # Main HTTP request form
├── public/
│   ├── industry_nav_logo.png # Logo file
│   └── *.svg                  # Various SVG assets
├── vercel.json                # Vercel deployment configuration
├── .env.example               # Environment variable template
├── package.json               # Dependencies and scripts
├── tsconfig.json              # TypeScript configuration
└── next.config.ts             # Next.js configuration
```

## Features

### HTTP Request Builder

- **Multiple HTTP Methods**: GET, POST, PUT, DELETE
- **Dynamic Port Configuration**: Test against different backend ports
- **Route Input**: Specify API endpoints
- **Request Body**: Send custom payloads
- **Real-time Response**: View server responses instantly
- **Modern UI**: Dark-themed interface with proper contrast

### Components

#### Header (`src/components/Header.tsx`)
- Fixed position header
- Logo and title display
- Horizontally aligned layout

#### Body (`src/components/Body.tsx`)
- HTTP request form with all inputs
- Method selector dropdown (black text on white background)
- Request body textarea
- Response display area
- Dark theme styling

## Getting Started

### Installation

```bash
# Install dependencies
npm install

# Copy environment template
cp .env.example .env.local

# Edit .env.local with your backend URL
```

### Development

```bash
# Start development server
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view in browser.

### Build

```bash
# Create production build
npm run build

# Start production server
npm run start
```

## Environment Variables

Create `.env.local` file:

```env
# Backend API URL
NEXT_PUBLIC_API_URL=http://localhost:8080
```

**For production**, set in Vercel Dashboard:
- `NEXT_PUBLIC_API_URL` = Your Render backend URL

## Deployment

### Manual Deployment to Vercel

```bash
# Preview deployment
vercel deploy

# Production deployment
vercel deploy --prod
```

### Automated Deployment

Use the root-level deployment script:

```bash
# From project root
./deploy.sh
```

Or push to deployment branches:
- `beta` → Beta environment
- `gamma` → Gamma environment
- `prod` → Production environment

See [../DEPLOYMENT.md](../DEPLOYMENT.md) for detailed deployment guide.

## Configuration Files

### `vercel.json`

Configures Vercel deployment:
- Build command: `npm run build`
- Framework: Next.js
- Output directory: `.next`
- Environment variables
- Git deployment settings

### `tsconfig.json`

TypeScript configuration:
- Target: ES2017
- Module: ESNext
- Path aliases: `@/*` → `./src/*`
- Strict mode enabled

### `next.config.ts`

Next.js configuration (minimal, uses defaults).

## Code Style

### Styling Approach

This project uses **inline styles** for component-specific styling:

```typescript
<div
  style={{
    backgroundColor: "#022d35",
    padding: "1.5rem",
    borderRadius: "0.5rem",
  }}
>
```

**Color Palette:**
- Background: `#011013` (dark blue-black)
- Cards: `#022d35` (dark teal)
- Text (on dark): `#E5E7EB` (light gray)
- Text (on light): `#000000` (black)
- Inputs: `#1f2937` (dark gray)
- Borders: `#4b5563` (medium gray)

### TypeScript

All components are written in TypeScript with proper type annotations:

```typescript
type HttpMethod = "GET" | "POST" | "PUT" | "DELETE";
```

## API Integration

### Making Requests

The frontend communicates with the backend using the Fetch API:

```typescript
const res = await fetch(
  `http://localhost:${port}${route}`,
  {
    method: method,
    body: message,
  }
);
```

### Environment Configuration

Backend URL is configured via environment variable:

```typescript
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080';
```

## Available Scripts

```bash
# Development server (hot reload)
npm run dev

# Production build
npm run build

# Start production server
npm run start

# Lint code
npm run lint
```

## Troubleshooting

### "Cannot connect to backend"

**Check:**
1. Backend is running: `python backend/server.py`
2. Backend port matches frontend configuration
3. `NEXT_PUBLIC_API_URL` is set correctly
4. CORS is enabled on backend

**Solution:**
```bash
# Check backend status
curl http://localhost:8080/get-test

# Should return: "Hello"
```

### "Environment variable not found"

**Next.js environment variable rules:**
- Must start with `NEXT_PUBLIC_` to be accessible in browser
- Must be set before build time
- Restart dev server after changing `.env.local`

**Solution:**
```bash
# Stop dev server (Ctrl+C)
# Edit .env.local
# Restart
npm run dev
```

### "Vercel deployment failed"

**Check:**
1. `vercel.json` is valid JSON
2. Build command succeeds locally: `npm run build`
3. All dependencies in `package.json`
4. Environment variables set in Vercel Dashboard

### "Dropdown text not visible"

The dropdown has explicit black text color:

```typescript
<select
  style={{
    color: "#000000",  // Always black
    backgroundColor: "#ffffff",  // White background
  }}
>
  <option style={{ color: "#000000" }}>
    {option}
  </option>
</select>
```

## Learn More

- [Next.js Documentation](https://nextjs.org/docs)
- [React Documentation](https://react.dev)
- [TypeScript Documentation](https://www.typescriptlang.org/docs)
- [Vercel Documentation](https://vercel.com/docs)

## Related Documentation

- [Main README](../README.md) - Project overview
- [DEPLOYMENT.md](../DEPLOYMENT.md) - Deployment guide
- [AUTHENTICATION.md](../AUTHENTICATION.md) - Authentication setup
- [Backend README](../backend/README.md) - Backend documentation
