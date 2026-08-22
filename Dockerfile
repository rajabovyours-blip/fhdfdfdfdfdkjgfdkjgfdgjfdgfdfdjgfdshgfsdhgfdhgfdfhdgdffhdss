# Build stage
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS build

WORKDIR /app
COPY . .
RUN flutter pub get
RUN touch .env
RUN flutter build web --release

# Serve stage
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
