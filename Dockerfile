FROM node:20-alpine@sha256:f4c96a28c0b2d8981664e03f461c2677152cd9a756012ffa8e2c6727427c2bda AS builder
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile 
COPY . .
RUN yarn build

FROM node:20-alpine@sha256:f4c96a28c0b2d8981664e03f461c2677152cd9a756012ffa8e2c6727427c2bda
WORKDIR /app
COPY --from=builder /app/build /app/build
RUN yarn global add serve
RUN addgroup -S appgroup \
 && adduser -S appuser -G appgroup
EXPOSE 80
CMD [ "serve", "-s", "build", "-l", "80" ]
