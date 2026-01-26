FROM node:20-alpine@sha256:a96707b4b49f864433433544a3584f6f4d128779e6b856153a04366b8dd01bb0 AS builder
WORKDIR /app
COPY app/package.json app/yarn.lock ./
RUN yarn install --frozen-lockfile 
COPY app/ .
RUN yarn build

FROM node:20-alpine@sha256:a96707b4b49f864433433544a3584f6f4d128779e6b856153a04366b8dd01bb0
WORKDIR /app
COPY --from=builder /app/build ./build
RUN yarn global add serve
RUN addgroup -S appgroup \
 && adduser -S appuser -G appgroup
EXPOSE 80
CMD [ "serve", "-s", "build", "-l", "80" ]
