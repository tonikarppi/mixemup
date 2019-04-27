FROM python:3.7-alpine as builder

# Install required packages
RUN apk add --no-cache build-base

# Set up working directory.
ENV APP_PATH /app
WORKDIR $APP_PATH

# Set up user.
RUN adduser -D appuser
RUN chown appuser:appuser .
ENV APP_HOME /home/appuser
ENV PATH $APP_HOME/.local/bin:$PATH
USER appuser

# Set up Poetry.
ENV PATH $APP_HOME/.poetry/bin:$PATH
ENV PATH $APP_PATH/.venv/bin:$PATH
RUN wget -qO- https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python

# Install required python packages.
RUN pip install --user --no-cache-dir flake8 black pytest mypy

# Install project dependencies.
COPY pyproject.toml poetry.lock ./
RUN poetry install --no-dev

# Check syntax.
COPY mixemup.py test_mixemup.py .flake8 ./
RUN black --check mixemup.py test_mixemup.py 2>&1
RUN flake8 mixemup.py test_mixemup.py
RUN mypy mixemup.py

# Build project.
COPY README.md .
RUN poetry build

# Install wheel.
RUN pip install --user dist/*.whl

# Run tests.
COPY examples examples
RUN pytest

FROM python:3.7-alpine

# Set up working directory.
WORKDIR /app

# Install wheel.
COPY --from=builder /app/dist dist
RUN pip install dist/*.whl

ENTRYPOINT [ "mixemup" ]
