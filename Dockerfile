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

CMD ["/bin/ash"]

FROM scratch

# Copy built files.
COPY --from=builder /app/dist /app/dist

CMD ["COPY THE FILES FROM /app/dist TO A HOST"]