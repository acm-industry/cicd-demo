# CI/CD Demo Project

A full-stack web application demonstrating modern CI/CD practices with automated deployment pipelines. This project features a Next.js frontend deployed to Vercel and a Flask backend deployed to Render, with branch-based deployment automation.

## 🎯 Project Purpose

This project is designed for **training and educational purposes** to demonstrate:

- **Modern CI/CD Pipelines**: Automated deployment workflows using shell scripts and GitHub Actions
- **Branch-Based Deployments**: Different branches deploy to different environments (production vs preview)
- **Multi-Service Architecture**: Frontend and backend deployed to different platforms
- **Platform-Specific Configurations**: Working with Vercel and Render deployment requirements
- **Authentication in Automation**: Handling API tokens and authentication in deployment scripts
- **DevOps Best Practices**: Environment variables, configuration management, and deployment orchestration

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     CI/CD Pipeline                          │
│                                                             │
│  Git Push → Branch Detection → Deploy Frontend & Backend   │
└─────────────────────────────────────────────────────────────┘
                               ↓
              ┌────────────────┴────────────────┐
              ↓                                  ↓
     ┌────────────────┐                ┌────────────────┐
     │   Frontend      │                │   Backend      │
     │   (Next.js)     │ ←──────────→  │   (Flask)      │
     │                 │    API Calls   │                │
     │  Vercel         │                │  Render        │
     └────────────────┘                └────────────────┘
```

### Tech Stack

**Frontend:**
- Next.js 16.0.2
- React 19.2.0
- TypeScript
- Deployed on Vercel

**Backend:**
- Python 3.11+
- Flask 3.1.2
- Flask-CORS 6.0.1
- Deployed on Render

**CI/CD:**
- Bash shell scripts
- GitHub Actions
- Vercel CLI
- Render CLI/API

## 📁 Project Structure

```
cicd-demo/
├── frontend/                 # Next.js frontend application
│   ├── src/
│   │   ├── app/             # Next.js app router
│   │   │   ├── page.tsx     # Main page
│   │   │   ├── layout.tsx   # Root layout
│   │   │   └── globals.css  # Global styles
│   │   └── components/      # React components
│   │       ├── Header.tsx   # Header with logo
│   │       └── Body.tsx     # Main HTTP request form
│   ├── public/              # Static assets
│   ├── vercel.json          # Vercel configuration
│   ├── .env.example         # Environment variable template
│   └── package.json         # Dependencies
│
├── backend/                 # Flask backend application
│   ├── server.py           # Main Flask server
│   ├── setup.py            # Virtual environment setup
│   ├── requirements.txt    # Python dependencies
│   ├── render.yaml         # Render Blueprint config
│   ├── Procfile            # Process configuration
│   └── .env.example        # Environment variable template
│
├── .github/
│   └── workflows/
│       └── deploy.yml      # GitHub Actions workflow
│
├── deploy.sh               # Main deployment automation script
├── DEPLOYMENT.md           # Comprehensive deployment guide
└── README.md               # This file
```

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ and npm
- Python 3.11+
- Git
- Vercel account
- Render account

### Local Development

#### 1. Clone the repository

```bash
git clone https://github.com/acm-industry/cicd-demo.git
cd cicd-demo
```

#### 2. Setup Frontend

```bash
cd frontend
npm install
cp .env.example .env.local
# Edit .env.local with your backend URL
npm run dev
```

Frontend runs at http://localhost:3000

#### 3. Setup Backend

```bash
cd backend
python setup.py  # Creates virtual environment and installs dependencies

# Activate virtual environment
# On Windows:
.venv\Scripts\activate
# On Mac/Linux:
source .venv/bin/activate

# Run the server
python server.py
```

Backend runs at http://localhost:8080

## 🔄 Deployment

### Automated Deployment (Recommended)

Use the deployment script for one-command deployment:

```bash
# Make script executable (Mac/Linux/WSL)
chmod +x deploy.sh

# Deploy current branch
./deploy.sh
```

The script will:
1. Detect your current branch
2. Check for required tools (Vercel CLI, Render CLI)
3. Prompt for authentication if needed
4. Deploy frontend to Vercel
5. Deploy backend to Render

**See [DEPLOYMENT.md](DEPLOYMENT.md) for complete deployment instructions.**

### Branch Strategy

- **`main` branch**: Production deployments
- **Other branches**: Preview/staging deployments

### Manual Deployment

**Frontend:**
```bash
cd frontend
vercel deploy --prod  # For main branch
vercel deploy         # For preview branches
```

**Backend:**
```bash
cd backend
render services list
render deploys create <SERVICE_ID>
```

## 🧪 Features

### Frontend Features

- **HTTP Request Builder**: Interactive form to send HTTP requests
- **Multiple HTTP Methods**: Support for GET, POST, PUT, DELETE
- **Dynamic Port Configuration**: Test against different backend ports
- **Request Body Input**: Send custom request bodies
- **Response Display**: View server responses in real-time
- **Modern UI**: Clean, dark-themed interface with proper contrast

### Backend Features

- **RESTful API**: Multiple endpoints demonstrating different HTTP methods
- **CORS Enabled**: Cross-origin requests supported
- **Simple Database**: In-memory dictionary for data storage
- **Health Check**: `/get-test` endpoint for monitoring

#### API Endpoints

- `GET /get-test` - Returns "Hello" (health check)
- `POST /post-test` - Echo validation endpoint
- `PUT /item` - Add item to database
- `GET /item/<name>` - Retrieve item from database
- `DELETE /kill/<killed>` - Delete item from database

## 🔐 Environment Variables

### Frontend (.env.local)

```env
NEXT_PUBLIC_API_URL=http://localhost:8080
```

### Backend (.env)

```env
FLASK_ENV=development
PORT=8080
PYTHON_VERSION=3.11.0
CORS_ORIGINS=http://localhost:3000,https://your-frontend.vercel.app
```

## 🧰 Available Scripts

### Frontend

```bash
npm run dev      # Start development server
npm run build    # Build for production
npm run start    # Start production server
```

### Backend

```bash
python setup.py  # Setup virtual environment
python server.py # Start Flask server
```

### Deployment

```bash
./deploy.sh      # Deploy current branch
```

## 📚 Documentation

- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Complete deployment guide with authentication setup, troubleshooting, and best practices
- **[frontend/README.md](frontend/README.md)** - Frontend-specific documentation
- **[backend/README.md](backend/README.md)** - Backend-specific documentation

## 🎓 Learning Objectives

This project teaches:

1. **CI/CD Fundamentals**
   - Automated deployment pipelines
   - Branch-based deployment strategies
   - Environment management

2. **DevOps Practices**
   - Infrastructure as Code (vercel.json, render.yaml)
   - Configuration management
   - Secrets management

3. **Platform-Specific Deployment**
   - Vercel CLI and API
   - Render CLI and API
   - Platform authentication

4. **Full-Stack Development**
   - Frontend/Backend separation
   - API communication
   - CORS handling

5. **Shell Scripting**
   - Bash automation
   - Error handling
   - Cross-platform compatibility

## 🐛 Troubleshooting

Common issues and solutions:

**Issue**: "Vercel CLI not found"
```bash
npm install -g vercel
```

**Issue**: "CORS errors in frontend"
- Update `CORS_ORIGINS` in backend environment variables
- Include your frontend URL

**Issue**: "Cannot connect to backend"
- Check backend is running on correct port
- Verify `NEXT_PUBLIC_API_URL` in frontend .env.local

**Issue**: "Permission denied: ./deploy.sh"
```bash
chmod +x deploy.sh
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for more troubleshooting tips.

## 🤝 Contributing

This is a training project. To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is for educational purposes.

## 🔗 Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Vercel Documentation](https://vercel.com/docs)
- [Render Documentation](https://render.com/docs)
- [GitHub Actions Documentation](https://docs.github.com/actions)

## 👥 Authors

Created for ACM Industry Training

---

**Ready to deploy?** Check out [DEPLOYMENT.md](DEPLOYMENT.md) to get started! 🚀
