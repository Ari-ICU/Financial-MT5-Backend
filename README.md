# Financial Backend API

Clean and modular FastAPI backend structured like MQL5 Expert Advisor.

## 📁 Project Structure

```
backend/
├── app.py                      # Main application (like EA main file)
├── requirements.txt            # Dependencies
├── env/
│   └── .env                   # Environment variables
└── src/
    ├── config/                # Configuration (like input parameters)
    │   └── settings.py
    ├── models/                # Data models (like structures)
    │   └── schemas.py
    ├── services/              # Business logic (like functions)
    │   └── mt5_service.py
    ├── routes/                # API endpoints (like event handlers)
    │   ├── health_routes.py
    │   └── mt5_routes.py
    ├── middlewares/           # Request/response processing
    │   └── error_handler.py
    └── utils/                 # Helper functions
        └── logger.py
```

## 🚀 Quick Start

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Configure Environment
Create `env/.env` file:
```env
METAAPI_TOKEN=your_token_here
METAAPI_ACCOUNT_ID=your_account_id_here
```

### 3. Run Development Server
```bash
python app.py
```

Or using uvicorn directly:
```bash
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

## 📚 API Endpoints

### Health Check
- `GET /` - Root health check
- `GET /health` - Detailed health check

### MT5 Operations
- `POST /mt5/connect` - Connect to MT5 account
- `GET /mt5/status` - Get connection status
- `GET /mt5/account` - Get account information
- `DELETE /mt5/disconnect/{account_id}` - Disconnect from MT5

## 🏗️ Code Organization (Like MQL5)

### Config Layer
Centralized configuration similar to MQL5 input parameters:
```python
# src/config/settings.py
METAAPI_TOKEN: str
METAAPI_ACCOUNT_ID: str
```

### Models Layer
Data structures similar to MQL5 structs:
```python
# src/models/schemas.py
class MT5ConnectionRequest(BaseModel):
    account_id: str
```

### Services Layer
Business logic similar to MQL5 functions:
```python
# src/services/mt5_service.py
class MT5Service:
    @classmethod
    async def connect_account(cls, account_id: str):
        # Like ConnectToMT5() in MQL5
        pass
```

### Routes Layer
API endpoints similar to MQL5 event handlers (OnInit, OnTick):
```python
# src/routes/mt5_routes.py
@router.post("/connect")
async def connect_to_mt5(request: MT5ConnectionRequest):
    # Like OnInit() in MQL5
    pass
```

## 🔧 Development

### Code Style
- Follow MQL5-like structure
- Clear separation of concerns
- Comprehensive documentation
- Type hints for all functions

### Adding New Features

1. **Models** - Define data structures in `src/models/schemas.py`
2. **Services** - Add business logic in `src/services/`
3. **Routes** - Create endpoints in `src/routes/`
4. **Register** - Include router in `app.py`

## 📝 License

MIT License
