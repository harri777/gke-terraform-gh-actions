FROM python:3.8.1-slim

RUN pip install pipenv==2020.11.15

WORKDIR /app

ARG AUTH_TOKEN
ARG REDIS_HOST

COPY Pipfile Pipfile.lock ./
RUN pipenv install --system --deploy

COPY tests/ ./tests
RUN pip install pytest-flask

COPY app/ .

EXPOSE 8000

CMD [ "python", "-m" , "flask", "run", "--host=0.0.0.0", "--port=8000" ]
