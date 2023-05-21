# Start by building the application.
FROM golang:1.19-alpine as build

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

WORKDIR /go/src/app
COPY . .

RUN go mod download && \
    CGO_ENABLED=0 go build -o /go/bin/app.bin cmd/main.go && \
    chmod +x /go/bin/app.bin

# Now copy it into our base image.
FROM gcr.io/distroless/base-debian11

ENV APP_PORT=9000 \
  APP_HOST=0.0.0.0 \
  APP_DB_URL=postgres://user:pass@localhost:5432/app

EXPOSE 9000

COPY --from=build /go/bin/app.bin /go/bin/app.bin
COPY --from=build /etc/passwd /etc/passwd

USER appuser
CMD ["/go/bin/app.bin"]
