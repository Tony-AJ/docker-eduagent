FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt update && apt install -y \
    curl \
    postgresql postgresql-contrib \
    supervisor

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt install -y nodejs

# Create app directory
WORKDIR /app

# Copy backend
COPY server ./backend
WORKDIR /app/backend
RUN npm install

# Copy frontend
WORKDIR /app
COPY src ./frontend/src
COPY public ./frontend/public
COPY index.html ./frontend/
COPY package.json ./frontend/
COPY package-lock.json ./frontend/
COPY vite.config.js ./frontend/
COPY eslint.config.js ./frontend/
WORKDIR /app/frontend
RUN npm install

# PostgreSQL setup
USER postgres
RUN /etc/init.d/postgresql start && \
    psql --command "CREATE DATABASE mydb;" && \
    psql --command "CREATE USER admin WITH PASSWORD 'admin123';" && \
    psql --command "ALTER USER admin CREATEDB;" && \
    psql --command "GRANT ALL PRIVILEGES ON DATABASE mydb TO admin;"

USER root

# Copy supervisor config
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# Expose ports
EXPOSE 3000 5000 5432

CMD ["/usr/bin/supervisord"]
