.EXPORT_ALL_VARIABLES:
.PHONY: venv install update upgrade pre-commit check clean

GLOBAL_PYTHON = $(shell py -3.9 -c 'import sys; print(sys.executable)')
LOCAL_PYTHON = .venv\\Scripts\\python.exe
LOCAL_PIP_COMPILE = .venv\\Scripts\\pip-compile.exe
LOCAL_PIP_SYNC = .venv\\Scripts\\pip-sync.exe

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
	${LOCAL_PIP_COMPILE} pyproject.toml --output-file requirements.txt --resolver=backtracking --allow-unsafe
	${LOCAL_PIP_COMPILE} pyproject.toml --output-file requirements-dev.txt --resolver=backtracking --allow-unsafe --extra dev
	${LOCAL_PIP_SYNC} requirements-dev.txt --pip-args "--no-cache-dir"

## Update dependencies
update: ${LOCAL_PYTHON} ${LOCAL_PIP_SYNC}
	@echo "Updating dependencies..."
	${LOCAL_PYTHON} -m pip install --upgrade pip
	${LOCAL_PIP_SYNC} requirements-dev.txt --pip-args "--no-cache-dir"

## Upgrade dependencies
upgrade: ${LOCAL_PYTHON} ${LOCAL_PIP_COMPILE}
	@echo "Upgrading dependencies..."
	${LOCAL_PYTHON} -m pip install --upgrade pip
	${LOCAL_PIP_COMPILE} --upgrade requirements-dev.txt --pip-args "--no-cache-dir"

## Setting up pre-commit hooks
pre-commit:
	@echo "Setting up pre-commit..."
	pre-commit install
	pre-commit autoupdate

## Running checks
check: ${LOCAL_PYTHON}
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
