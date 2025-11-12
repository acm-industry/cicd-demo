# Backend - Flask API

RESTful API backend built with Flask and Python.

## Tech Stack

- **Framework**: Flask 3.1.2
- **CORS**: flask-cors 6.0.1
- **Python**: 3.11+
- **Deployment**: Render

## Project Structure

```
backend/
├── server.py           # Main Flask application
├── setup.py            # Virtual environment setup script
├── requirements.txt    # Python dependencies
├── render.yaml         # Render Blueprint configuration
├── Procfile            # Process configuration for Render
├── .env.example        # Environment variable template
├── .gitignore         # Git ignore rules
└── README.md           # This file
```

## Features

### RESTful API Endpoints

- **GET `/get-test`**: Health check endpoint, returns "Hello"
- **POST `/post-test`**: Echo validation endpoint
- **PUT `/item`**: Add item to in-memory database
- **GET `/item/<name>`**: Retrieve item from database
- **DELETE `/kill/<killed>`**: Delete item from database

### CORS Support

Full CORS support enabled for cross-origin requests from the frontend.

### In-Memory Database

Simple dictionary-based storage for demonstration purposes.

## Getting Started

### Installation

#### Option 1: Automated Setup (Recommended)

```bash
# Run setup script (creates venv and installs dependencies)
python setup.py
```

#### Option 2: Manual Setup

```bash
# Create virtual environment
python -m venv .venv

# Activate virtual environment
# On Windows:
.venv\Scripts\activate
# On Mac/Linux:
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### Development

```bash
# Activate virtual environment (if not already activated)
# Windows:
.venv\Scripts\activate
# Mac/Linux:
source .venv/bin/activate

# Run server
python server.py
```

Server runs at [http://localhost:8080](http://localhost:8080)

### Testing Endpoints

```bash
# Health check
curl http://localhost:8080/get-test

# Add item
curl -X PUT http://localhost:8080/item \
  -H "Content-Type: text/plain" \
  -d "test item"

# Get item
curl http://localhost:8080/item/item_key

# Delete item
curl -X DELETE http://localhost:8080/kill/item_key
```

## API Documentation

### `GET /get-test`

Health check endpoint.

**Response:**
```
Hello
```

**Status Code:** 200

---

### `POST /post-test`

Echo validation endpoint - returns the request body.

**Request Body:** Any text

**Response:** Same as request body

**Status Code:** 200

---

### `PUT /item`

Add item to database.

**Request Body:** Item value (text)

**Response:**
```json
{
  "status": "successfully added",
  "item_key": "generated_key"
}
```

**Status Code:** 200

**Example:**
```bash
curl -X PUT http://localhost:8080/item \
  -H "Content-Type: text/plain" \
  -d "My awesome item"
```

---

### `GET /item/<name>`

Retrieve item from database by key.

**Parameters:**
- `name` (path): Item key

**Response:** Item value or "post not found"

**Status Code:** 200

**Example:**
```bash
curl http://localhost:8080/item/item_12345
```

---

### `DELETE /kill/<killed>`

Delete item from database.

**Parameters:**
- `killed` (path): Item key to delete

**Response:**
```json
{
  "status": "successfully killed",
  "killed": "item_key"
}
```

**Status Code:** 200

**Example:**
```bash
curl -X DELETE http://localhost:8080/kill/item_12345
```

## Environment Variables

Create `.env` file from template:

```bash
cp .env.example .env
```

**Available Variables:**

```env
# Flask environment (development or production)
FLASK_ENV=development

# Port to run the server on
PORT=8080

# Python version (for Render deployment)
PYTHON_VERSION=3.11.0

# CORS allowed origins (comma-separated)
CORS_ORIGINS=http://localhost:3000,https://your-frontend.vercel.app
```

## Deployment

### Manual Deployment to Render

1. Create new Web Service on [Render Dashboard](https://dashboard.render.com/create?type=web)
2. Connect your GitHub repository
3. Configure service:
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `python server.py`
   - **Environment**: Python 3
4. Add environment variables from `.env.example`
5. Deploy

### Automated Deployment

Use the root-level deployment script:

```bash
# From project root
./deploy.sh
```

Or push to deployment branches:
- `beta` → Beta environment (`cicd-demo-backend-beta`)
- `gamma` → Gamma environment (`cicd-demo-backend-gamma`)
- `prod` → Production environment (`cicd-demo-backend-prod`)

See [../DEPLOYMENT.md](../DEPLOYMENT.md) for detailed deployment guide.

## Configuration Files

### `requirements.txt`

Python dependencies:
```
Flask==3.1.2
flask-cors==6.0.1
Werkzeug==3.1.3
Jinja2==3.1.6
```

### `render.yaml`

Render Blueprint configuration for automated service creation:
- Service type: Web
- Runtime: Python
- Build command: `pip install -r requirements.txt`
- Start command: `python server.py`
- Environment variables
- Health check path: `/get-test`

### `Procfile`

Process configuration for Render:
```
web: python server.py
```

### `setup.py`

Automated setup script:
- Creates virtual environment
- Installs dependencies from `requirements.txt`
- Cross-platform compatible (Windows/Mac/Linux)

## Code Structure

### Main Application (`server.py`)

```python
from flask import Flask
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS

# In-memory database
posts = {}

@app.route('/get-test', methods=['GET'])
def get_test():
    return "Hello"

# ... more endpoints ...

if __name__ == '__main__':
    app.run(host='localhost', port=8080)
```

## Development Tips

### Virtual Environment

Always activate the virtual environment before working:

```bash
# Windows
.venv\Scripts\activate

# Mac/Linux
source .venv/bin/activate

# Verify activation (should show .venv path)
which python
```

### Adding Dependencies

```bash
# Install new package
pip install package-name

# Update requirements.txt
pip freeze > requirements.txt
```

### CORS Configuration

To allow additional origins:

```python
# In server.py
CORS(app, origins=["http://localhost:3000", "https://your-domain.com"])
```

## Troubleshooting

### "Module not found" Error

**Solution:**
```bash
# Ensure virtual environment is activated
source .venv/bin/activate  # Mac/Linux
.venv\Scripts\activate     # Windows

# Reinstall dependencies
pip install -r requirements.txt
```

### "Port already in use"

**Check what's using port 8080:**
```bash
# Windows
netstat -ano | findstr :8080

# Mac/Linux
lsof -i :8080
```

**Solution:**
- Kill the process using the port
- Or change port in `server.py`

### "CORS errors in frontend"

**Check:**
1. CORS is enabled in `server.py`
2. Frontend origin is allowed
3. Backend is running

**Solution:**
```python
# Explicit CORS configuration
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={
    r"/*": {
        "origins": ["http://localhost:3000", "https://your-frontend.vercel.app"],
        "methods": ["GET", "POST", "PUT", "DELETE"],
        "allow_headers": ["Content-Type"]
    }
})
```

### "Render deployment failed"

**Check:**
1. `requirements.txt` is up to date
2. Python version matches (3.11+)
3. Start command is correct: `python server.py`
4. Environment variables are set

## Testing

### Manual Testing

Use the frontend HTTP Request Builder or curl:

```bash
# GET request
curl http://localhost:8080/get-test

# POST request
curl -X POST http://localhost:8080/post-test \
  -H "Content-Type: text/plain" \
  -d "test data"

# PUT request
curl -X PUT http://localhost:8080/item \
  -d "my item"

# GET item
curl http://localhost:8080/item/item_123

# DELETE request
curl -X DELETE http://localhost:8080/kill/item_123
```

### Automated Testing (Future Enhancement)

```python
# tests/test_server.py (example)
import unittest
from server import app

class TestAPI(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()

    def test_get_test(self):
        response = self.app.get('/get-test')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data.decode(), "Hello")
```

## Learn More

- [Flask Documentation](https://flask.palletsprojects.com/)
- [Flask-CORS Documentation](https://flask-cors.readthedocs.io/)
- [Render Documentation](https://render.com/docs)
- [Python Virtual Environments](https://docs.python.org/3/tutorial/venv.html)

## Related Documentation

- [Main README](../README.md) - Project overview
- [DEPLOYMENT.md](../DEPLOYMENT.md) - Deployment guide
- [AUTHENTICATION.md](../AUTHENTICATION.md) - Authentication setup
- [Frontend README](../frontend/README.md) - Frontend documentation
