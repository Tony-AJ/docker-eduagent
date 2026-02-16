FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# System deps
RUN apt update && apt install -y \
    curl \
    postgresql postgresql-contrib \
    supervisor

# Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt install -y nodejs

WORKDIR /app

# --------------------
# Backend
# --------------------
COPY server ./server
WORKDIR /app/server
RUN npm install

# --------------------
# Frontend (Vite root)
# --------------------
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install

COPY src ./src
COPY public ./public
COPY index.html .
COPY vite.config.js .
COPY eslint.config.js .

# --------------------
# PostgreSQL setup
# --------------------
USER postgres
RUN /etc/init.d/postgresql start && \
    psql -c "CREATE DATABASE eduagent;" && \
    psql -c "CREATE USER admin WITH PASSWORD 'admin123';" && \
    psql -c "GRANT ALL PRIVILEGES ON DATABASE eduagent TO admin;"

USER root

# Supervisor
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf

EXPOSE 3000 5000

CMD ["/usr/bin/supervisord"]
