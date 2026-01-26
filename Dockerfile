FROM node:20-alpine@sha256:658d0f63e501824d6c23e06d4bb95c71e7d704537c9d9272f488ac03a370d448 AS builder
WORKDIR /app
COPY app/package.json app/yarn.lock ./
RUN yarn install --frozen-lockfile 
COPY app/ .
RUN yarn build

FROM node:20-alpine@sha256:658d0f63e501824d6c23e06d4bb95c71e7d704537c9d9272f488ac03a370d448
WORKDIR /app
COPY --from=builder /app/build ./build
RUN yarn global add serve
RUN addgroup -S appgroup \
 && adduser -S appuser -G appgroup
EXPOSE 80
CMD [ "serve", "-s", "build", "-l", "80" ]
