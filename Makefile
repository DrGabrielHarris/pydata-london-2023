.EXPORT_ALL_VARIABLES:
.PHONY: venv install update pre-commit check clean

GLOBAL_PYTHON = $(shell py -3.9 -c 'import sys; print(sys.executable)')
LOCAL_PYTHON = .venv\\Scripts\\python.exe

setup: venv install pre-commit

## Create an empty environment
venv: $(GLOBAL_PYTHON)
	@echo "Creating .venv..."
	- deactivate
	${GLOBAL_PYTHON} -m venv .venv

## Install dependencies
install: ${LOCAL_PYTHON}
	@echo "Installing dependencies..."
	${LOCAL_PYTHON} -m pip install --upgrade pip
	${LOCAL_PYTHON} -m pip install pip-tools
	.venv\\Scripts\\pip-compile pyproject.toml --output-file requirements.txt --resolver=backtracking --allow-unsafe
	.venv\\Scripts\\pip-compile pyproject.toml --output-file requirements-dev.txt --resolver=backtracking --allow-unsafe --extra dev
	.venv\\Scripts\\pip-sync requirements-dev.txt --pip-args "--no-cache-dir"

## Setting up pre-commit hooks
pre-commit: ${LOCAL_PYTHON}
	@echo "Setting up pre-commit..."
	pre-commit install
	pre-commit autoupdate

## Update dependencies
update: ${LOCAL_PYTHON}
	@echo "Updating dependencies..."
	${LOCAL_PYTHON} -m pip install --upgrade pip
	.venv\\Scripts\\pip-sync requirements-dev.txt --pip-args "--no-cache-dir"

## Running checks
checks: ${LOCAL_PYTHON}
	@echo "Running checks..."
	ruff check --fix .
	isort .
	black .
	pydocstyle .
	sqlfluff fix .
	sqlfluff lint .

## clean all temporary files
clean:
	if exist .git\\hooks ( rmdir .git\\hooks /q /s )
	- deactivate
	if exist .venv\\ ( rmdir .venv /q /s )
