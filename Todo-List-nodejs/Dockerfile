FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install --production

COPY . .

FROM node:18-alpine

WORKDIR /app

COPY --from=builder /app .
# Expose the port 4000 as in application listens on this port
EXPOSE 4000
CMD ["node", "index.js"]
