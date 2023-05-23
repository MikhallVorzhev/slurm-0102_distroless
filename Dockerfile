# Start by building the application.

# Базовый образ Alpine для создания non-root пользователя
FROM alpine:3.18.0 AS intermediate

# Создаем non-root пользователя и группу
RUN addgroup -S simplegroup && \
    adduser -S -G simplegroup simpleuser

# Базовый образ Go для сборки
FROM golang:1.19-alpine as build

WORKDIR /go/src/app
COPY . .

RUN go mod download
RUN go build -o /go/bin/app.bin cmd/main.go

# Now copy it into our base image.
FROM gcr.io/distroless/base-debian11
COPY --from=build /go/bin/app /
CMD ["/app.bin"]
