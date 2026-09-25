FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
RUN npm ci --omit=dev \
    && npm install --no-save ts-node typescript
COPY server ./server
COPY --from=builder /app/public ./public

EXPOSE 8080
CMD ["npx", "ts-node", "--transpile-only", "server/index.ts"]
