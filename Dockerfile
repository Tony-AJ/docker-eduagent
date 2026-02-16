# Use official Node image
FROM node:20

# Create app directory
WORKDIR /app

# Copy backend package.json
COPY server/package*.json ./server/

# Install backend dependencies
WORKDIR /app/server
RUN npm install

# Copy backend source code
COPY server .

# Expose backend port
EXPOSE 5000

# Start backend
CMD ["node", "index.js"]
