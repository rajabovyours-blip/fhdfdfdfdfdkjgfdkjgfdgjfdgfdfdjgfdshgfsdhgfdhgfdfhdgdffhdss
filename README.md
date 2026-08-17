# Milliy Metr Backend

The Milliy Metr backend is built with FastAPI, PostgreSQL, and Redis.

## Getting Started on Windows

For detailed, step-by-step instructions on setting up your environment, running migrations, and executing tests on Windows, please refer to the [Runtime Setup Guide](BACKEND_RUNTIME_SETUP_GUIDE.md).

### Quick Start

1. `copy .env.example .env`
2. `python -m venv venv` and `.\venv\Scripts\activate`
3. `pip install -r requirements.txt`
4. `docker-compose up -d`
5. `$env:PYTHONPATH="C:\Users\rajab\OneDrive\Desktop\MilliyMetr\backend"`
6. `alembic upgrade head`
7. `python scripts\seed.py`
8. `uvicorn app.main:app --reload`

### Testing
Run `pytest` to execute the automated test suite securely against the isolated test database.
