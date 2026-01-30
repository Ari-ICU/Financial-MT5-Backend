#==============================================================================
# Financial Backend API - Architecture Documentation
# Clean and Modular Structure Like MQL5 Expert Advisor
#==============================================================================

## 📐 Architecture Overview

This FastAPI backend follows the same clean architecture principles used in MQL5 
Expert Advisors, with clear separation of concerns and modular organization.

## 🏗️ Directory Structure

```
backend/
├── app.py                      # Main application entry point (like EA main file)
├── run.sh                      # Quick start script
├── requirements.txt            # Python dependencies
├── README.md                   # Documentation
├── env/
│   └── .env                   # Environment variables (API keys, config)
└── src/                       # Source code (organized by layer)
    ├── config/                # Configuration Layer
    │   ├── __init__.py
    │   └── settings.py        # App settings (like MQL5 input parameters)
    ├── models/                # Data Models Layer
    │   ├── __init__.py
    │   └── schemas.py         # Pydantic models (like MQL5 structures)
    ├── services/              # Business Logic Layer
    │   ├── __init__.py
    │   └── mt5_service.py     # MT5 operations (like MQL5 functions)
    ├── routes/                # API Routes Layer
    │   ├── __init__.py
    │   ├── health_routes.py   # Health check endpoints
    │   └── mt5_routes.py      # MT5 endpoints (like MQL5 event handlers)
    ├── middlewares/           # Middleware Layer
    │   ├── __init__.py
    │   └── error_handler.py   # Error handling (like MQL5 error management)
    └── utils/                 # Utilities Layer
        ├── __init__.py
        └── logger.py          # Logging (like MQL5 Print/Comment)
```

## 🎯 Layer Responsibilities (MQL5 Comparison)

### 1. Configuration Layer (config/)
**Like:** MQL5 input parameters and constants
**Purpose:** Centralized application settings
**Files:**
- `settings.py` - All configuration in one place

**Example:**
```python
# MQL5 Style
input string METAAPI_TOKEN = "xxx";
input string ACCOUNT_ID = "yyy";

# FastAPI Implementation
class Settings(BaseSettings):
    METAAPI_TOKEN: str
    METAAPI_ACCOUNT_ID: str
```

### 2. Models Layer (models/)
**Like:** MQL5 structures and data types
**Purpose:** Define data shapes and validation
**Files:**
- `schemas.py` - Request/response models

**Example:**
```python
# MQL5 Style
struct ConnectionRequest {
    string account_id;
};

# FastAPI Implementation
class MT5ConnectionRequest(BaseModel):
    account_id: str
```

### 3. Services Layer (services/)
**Like:** MQL5 functions and classes
**Purpose:** Business logic and operations
**Files:**
- `mt5_service.py` - MT5 connection and trading logic

**Example:**
```python
# MQL5 Style
bool ConnectToMT5(string accountId) {
    // Connection logic
}

# FastAPI Implementation
class MT5Service:
    @classmethod
    async def connect_account(cls, account_id: str):
        # Connection logic
```

### 4. Routes Layer (routes/)
**Like:** MQL5 event handlers (OnInit, OnTick, OnDeinit)
**Purpose:** API endpoint definitions
**Files:**
- `health_routes.py` - System health checks
- `mt5_routes.py` - MT5 operations

**Example:**
```python
# MQL5 Style
int OnInit() {
    // Initialization
}

# FastAPI Implementation
@router.post("/connect")
async def connect_to_mt5(request: MT5ConnectionRequest):
    # Initialization
```

### 5. Middlewares Layer (middlewares/)
**Like:** MQL5 error handling and preprocessing
**Purpose:** Request/response processing
**Files:**
- `error_handler.py` - Centralized error management

**Example:**
```python
# MQL5 Style
void HandleError(int error_code) {
    Print("Error: ", error_code);
}

# FastAPI Implementation
async def general_exception_handler(request, exc):
    logger.error(f"Error: {exc}")
```

### 6. Utils Layer (utils/)
**Like:** MQL5 helper functions
**Purpose:** Reusable utilities
**Files:**
- `logger.py` - Application logging

**Example:**
```python
# MQL5 Style
void Print(string message) {
    // Log message
}

# FastAPI Implementation
class AppLogger:
    @staticmethod
    def log_startup(logger, config):
        # Log startup info
```

## 🔄 Request Flow

```
Client Request
    ↓
[CORS Middleware]
    ↓
[Routes Layer] ← Validates request using [Models]
    ↓
[Services Layer] ← Executes business logic
    ↓
[External API] ← MetaAPI
    ↓
[Services Layer] ← Processes response
    ↓
[Routes Layer] ← Returns response using [Models]
    ↓
[Error Handler] ← If any errors occur
    ↓
Client Response
```

## 🎨 Design Principles (Following MQL5 Best Practices)

### 1. **Separation of Concerns**
- Each layer has a single, well-defined responsibility
- Like separating trading logic from order management in MQL5

### 2. **Modularity**
- Easy to add new features without touching existing code
- Like adding new strategies in separate MQL5 files

### 3. **Type Safety**
- Pydantic models ensure data validation
- Like MQL5 strict typing

### 4. **Clear Naming**
- Descriptive names for functions and classes
- Like MQL5 naming conventions

### 5. **Documentation**
- Every function has clear documentation
- Like MQL5 header comments

### 6. **Error Handling**
- Centralized error management
- Like MQL5 GetLastError() pattern

## 🚀 Adding New Features

### Step 1: Define Data Model
```python
# src/models/schemas.py
class NewFeatureRequest(BaseModel):
    param1: str
    param2: int
```

### Step 2: Implement Business Logic
```python
# src/services/new_service.py
class NewService:
    @classmethod
    async def process(cls, data):
        # Your logic here
        pass
```

### Step 3: Create Route
```python
# src/routes/new_routes.py
@router.post("/feature")
async def new_feature(request: NewFeatureRequest):
    return await NewService.process(request)
```

### Step 4: Register Route
```python
# app.py
from src.routes import new_routes
app.include_router(new_routes.router)
```

## 📊 API Endpoints

### Health Endpoints
- `GET /` - Root health check
- `GET /health` - Detailed health status

### MT5 Endpoints
- `POST /mt5/connect` - Connect to MT5 account
- `GET /mt5/status` - Get connection status
- `GET /mt5/account` - Get account information
- `DELETE /mt5/disconnect/{account_id}` - Disconnect account

## 🔐 Environment Variables

Required in `env/.env`:
```env
METAAPI_TOKEN=your_metaapi_token
METAAPI_ACCOUNT_ID=your_account_id
```

## 🛠️ Development

### Start Server
```bash
# Using run script
./run.sh

# Or directly
python3 app.py
```

### API Documentation
Open browser: `http://localhost:8000/docs`

### Testing Endpoints
```bash
# Health check
curl http://localhost:8000/

# MT5 status
curl http://localhost:8000/mt5/status

# Connect to MT5
curl -X POST http://localhost:8000/mt5/connect \
  -H "Content-Type: application/json" \
  -d '{"account_id": "your_account_id"}'
```

## 📝 Code Style Guidelines

### 1. File Headers
Every file starts with:
```python
#==============================================================================
# File Purpose
# Description
#==============================================================================
```

### 2. Section Comments
Large sections marked with:
```python
# =============================================================================
# Section Name
# =============================================================================
```

### 3. Function Documentation
Every function has docstring:
```python
def function_name(param: str) -> dict:
    """
    Brief description
    Like: MQL5EquivalentFunction() in MQL5
    
    Args:
        param: Parameter description
        
    Returns:
        Return value description
    """
    pass
```

### 4. Type Hints
All functions have type hints:
```python
async def process(data: dict) -> Optional[str]:
    pass
```

## 🎯 Best Practices

1. **Keep Services Pure** - Business logic should be independent of FastAPI
2. **Validate Early** - Use Pydantic models for all I/O
3. **Handle Errors** - Always use try/except with proper error responses
4. **Log Everything** - Use logger for debugging and monitoring
5. **Document Code** - Like commenting MQL5 code for strategy clarity
6. **Test Endpoints** - Verify each endpoint works as expected
7. **Secure Secrets** - Never commit `.env` file

## 🔍 Debugging Tips

1. **Check Logs** - Logger outputs detailed information
2. **Use /docs** - Interactive API documentation
3. **Test with curl** - Quick endpoint verification
4. **Monitor Server** - Watch uvicorn logs for issues

## 📚 Resources

- FastAPI Documentation: https://fastapi.tiangolo.com
- MetaAPI SDK: https://metaapi.cloud
- Pydantic: https://docs.pydantic.dev

---

**Built with ❤️ using FastAPI | Structured like MQL5 EA**
