FROM golang:1.22-alpine AS builder

WORKDIR /app

# Install git (needed for Go modules sometimes)
RUN apk add --no-cache git

# Copy only mod files first (better caching)
COPY go.mod go.sum ./
RUN go mod download

# Copy rest of the code
COPY . .

# Build WITHOUT vendor
RUN go build -o stripe-mock

# Final image
FROM alpine:latest
RUN apk --no-cache add ca-certificates

COPY --from=builder /app/stripe-mock /bin/stripe-mock

ENTRYPOINT ["/bin/stripe-mock", "-http-port", "12111", "-https-port", "12112"]

EXPOSE 12111
EXPOSE 12112
