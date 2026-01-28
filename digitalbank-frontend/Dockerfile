FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Create production environment file with correct API URLs
RUN echo "VITE_AUTH_API_URL=/api/auth" > .env.production && \
    echo "VITE_ACCOUNTS_API_URL=/api/accounts" >> .env.production && \
    echo "VITE_TRANSACTIONS_API_URL=/api/transactions" >> .env.production

# Build with production environment variables
RUN npm run build

FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
