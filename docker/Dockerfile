FROM node:22-alpine3.20 AS dependencies
WORKDIR /app
COPY app/package.json ./package.json
RUN npm install --omit=dev

FROM node:22-alpine3.20 AS runtime
ENV NODE_ENV=production
ENV APP_PORT=3000
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=dependencies --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --chown=appuser:appgroup app/server.js ./server.js
USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:3000/health || exit 1
CMD ["node", "server.js"]
