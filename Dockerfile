FROM python:3.7-alpine as builder

# Set up working directory.
ENV APP_PATH /app
WORKDIR $APP_PATH

# Set up user.
RUN adduser -D appuser
RUN chown appuser:appuser .
ENV APP_HOME /home/appuser
USER appuser

# Set up Poetry.
ENV PATH $APP_HOME/.poetry/bin:$PATH
ENV PATH $APP_PATH/.venv/bin:$PATH
RUN wget -qO- https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python
RUN poetry config settings.virtualenvs.in-project true

# Install project dependencies.
COPY pyproject.toml poetry.lock ./
RUN poetry install --no-dev

# Build project.
COPY *.py README.md ./
RUN poetry build

FROM python:3.7-alpine as tester

# Install required packages
RUN apk add --no-cache build-base git

# Set up working directory.
WORKDIR /app

# Install required python packages.
RUN pip install --no-cache-dir pre-commit pytest mypy

# Install pre-commit hooks.
COPY .git .git
COPY .pre-commit-config.yaml .
RUN pre-commit install-hooks

# Install wheel.
COPY --from=builder /app/dist dist
RUN pip install dist/*.whl

# Run pre-commit checks.
COPY *.py .flake8 ./
RUN pre-commit run -a

# Run tests.
COPY examples examples
RUN pytest

FROM python:3.7-alpine

# Set up working directory.
WORKDIR /app

# Install wheel.
COPY --from=tester /app/dist /app/dist
RUN pip install dist/*.whl

ENTRYPOINT [ "mixemup" ]