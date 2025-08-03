## Python Development Rules

### Code Style
- Follow PEP 8 with line length 88 (Black/Ruff default)
- Use type hints for all function signatures
- Prefer descriptive variable names over comments
- Use f-strings for formatting (Python 3.6+)

### Best Practices
```python
# ✅ Good
def calculate_total(items: list[Item]) -> Decimal:
    """Calculate total price including tax."""
    return sum(item.price for item in items) * Decimal("1.08")

# ❌ Avoid
def calc(x):
    # add tax
    total = 0
    for i in x:
        total += i.price
    return total * 1.08
```

### Import Organization (Ruff handles automatically)
1. Standard library imports
2. Third-party imports
3. Local application imports

### Error Handling
- Use specific exceptions, avoid bare `except:`
- Log errors appropriately
- Raise exceptions early (fail fast)
- Use context managers for resource handling

## Development Workflow - Python Specification-Driven

### Quick Commands
- `/spec` - Full specification workflow
- `/requirements` - Requirements only
- `/design` - Technical design
- `/tasks` - Task breakdown
- `/implement` - Start autonomous execution with Python agents

### Python-Specific Sub Agents
- `quality-checker-python` - Ruff, pytest, mypy integration
- `task-executor` - Handles pytest execution during implementation
- `task-decomposer` - Creates Python-appropriate task breakdowns

## Python Project Structure
```
project/
├── src/
│   └── project_name/
│       ├── __init__.py
│       ├── main.py
│       └── modules/
├── tests/
│   ├── conftest.py
│   └── test_*.py
├── .dev_docs/
│   ├── specs/
│   └── tasks/
├── .claude/
├── pyproject.toml
├── README.md
└── .gitignore
```

## Quality Standards - Python

### Tools (via Ruff + uv)
- **Linting/Formatting**: Ruff (all-in-one)
- **Type Checking**: mypy or pyright
- **Testing**: pytest with coverage
- **Security**: pip-audit, bandit (via Ruff rules)

### Metrics
- Test coverage: 80% minimum
- Cyclomatic complexity: <10 per function
- Type hint coverage: 100% for public APIs
- No security vulnerabilities in dependencies

## Testing Strategy

### Test Organization
```python
# tests/test_module.py
import pytest
from project_name.module import function_under_test

class TestFeatureName:
    """Group related tests."""

    def test_normal_case(self):
        """Test expected behavior."""
        assert function_under_test(valid_input) == expected_output

    def test_edge_case(self):
        """Test boundary conditions."""
        with pytest.raises(ValueError):
            function_under_test(invalid_input)
```

### Fixtures and Mocking
- Use pytest fixtures for reusable test data
- Mock external dependencies
- Use `pytest-mock` for complex mocking scenarios

## Common Patterns

### Dataclasses and Type Safety
```python
from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal

@dataclass
class Product:
    id: int
    name: str
    price: Decimal
    created_at: datetime

    def apply_discount(self, percentage: float) -> Decimal:
        """Apply percentage discount to price."""
        return self.price * (1 - Decimal(str(percentage / 100)))
```

### Context Managers
```python
from contextlib import contextmanager
import logging

@contextmanager
def database_transaction():
    """Ensure proper transaction handling."""
    conn = get_connection()
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()
```

### Async Patterns
```python
import asyncio
from typing import list

async def process_items(items: list[str]) -> list[Result]:
    """Process items concurrently."""
    tasks = [process_single_item(item) for item in items]
    return await asyncio.gather(*tasks)
```

## Environment Management (uv)
- Virtual environment is managed automatically by Claude hooks
- Dependencies defined in `pyproject.toml`
- Use `uv` for package management operations

## Quick Quality Check
```bash
# Run this single command for full quality check
ruff check . --fix && ruff format . && pytest --cov=. -x
```

## Performance Considerations
- Use generators for large datasets
- Profile before optimizing (`cProfile`, `line_profiler`)
- Consider `asyncio` for I/O-bound operations
- Use `multiprocessing` for CPU-bound operations

## Documentation
- Docstrings for all public functions/classes (Google style)
- Type hints serve as inline documentation
- README.md with setup and usage instructions
- API documentation with Sphinx (for libraries)

## Deployment Preparation
- Environment variables for configuration (never hardcode secrets)
- Use `python-dotenv` for local development
- Proper logging configuration
- Health check endpoints for web services

## Common Libraries Reference
- **Web**: FastAPI, Django, Flask
- **Data**: pandas, polars, numpy
- **Database**: SQLAlchemy, asyncpg, redis-py
- **Testing**: pytest, pytest-asyncio, pytest-mock
- **Utilities**: pydantic, python-dotenv, loguru

## Python-Specific Gotchas
- Mutable default arguments (use `None` and check)
- Late binding closures in loops
- Circular imports (use TYPE_CHECKING)
- GIL limitations for CPU-bound tasks