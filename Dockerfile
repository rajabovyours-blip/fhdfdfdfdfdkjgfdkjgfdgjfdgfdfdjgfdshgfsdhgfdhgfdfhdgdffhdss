# Build stage - use Ubuntu and install Flutter from source
FROM ubuntu:22.04 AS build

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Clone Flutter at EXACT version matching local dev environment
RUN git clone https://github.com/flutter/flutter.git -b 3.44.9 --depth 1 /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Pre-cache web SDK
RUN flutter precache --web
RUN flutter config --no-analytics

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN touch .env
ARG IS_ADMIN=false
RUN flutter build web --release --dart-define=IS_ADMIN=$IS_ADMIN

# Serve stage
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
