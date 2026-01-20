FROM node:20-alpine@sha256:e35970e6983407eb1c37b8c717f46a6a7a3c45ba0326b214389ec00f68cbd2e6 AS builder
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile 
COPY . .
RUN yarn build

FROM node:20-alpine@sha256:e35970e6983407eb1c37b8c717f46a6a7a3c45ba0326b214389ec00f68cbd2e6 
WORKDIR /app
COPY --from=builder /app/build /app/build
RUN yarn global add serve
RUN addgroup -S appgroup \
 && adduser -S appuser -G appgroup
EXPOSE 80
CMD [ "serve", "-s", "build", "-l", "80" ]
