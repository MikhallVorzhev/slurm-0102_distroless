# Start by building the application.
ARG PORT="9000"
ARG HOST="0.0.0.0"
ARG DB_URL="postgres://user:pass@db:5432/app"

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "nonexistent" \
    --shell "/bin/nologin" \
    --no-create-home \
    --uid "$UID" \
    "$USER"

FROM golang:1.19-alpine as build

WORKDIR $GOPATH/src/app
COPY ["./go.mod","./go.sum","./"]
RUN go mod download && go mod verify

COPY ./ .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -o /go/bin/app.bin cmd/main.go



# Now copy it into our base image.
FROM gcr.io/distroless/base-debian11 as final

ENV PORT ${9000}
ENV HOST ${HOST}
ENV DB_URL ${DB_URL}


COPY --from=build /go/bin/app /
CMD ["/app.bin"]
