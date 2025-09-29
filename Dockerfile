# Build stage
FROM elixir:1.18.4-alpine AS builder

# Install build dependencies
RUN apk add --no-cache build-base git

# Set build ENV
ENV MIX_ENV=prod

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Create the app directory
WORKDIR /app

# Copy mix files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get --only prod
RUN mix deps.compile

# Copy source code
COPY . .

# Build assets
RUN mix assets.deploy

# Build the release
RUN mix release

# Runtime stage
FROM alpine:3.19

# Install runtime dependencies
RUN apk add --no-cache \
    openssl \
    ncurses-libs \
    libgcc \
    libstdc++

# Create non-root user
RUN adduser -D -s /bin/sh app

# Set the working directory
WORKDIR /app

# Copy the release from builder stage
COPY --from=builder --chown=app:app /app/_build/prod/rel/financial_advisor_agent ./

# Switch to non-root user
USER app

# Expose port
EXPOSE 4000

# Set environment
ENV MIX_ENV=prod
ENV PORT=4000

# Start the application
CMD ["bin/financial_advisor_agent", "start"]
