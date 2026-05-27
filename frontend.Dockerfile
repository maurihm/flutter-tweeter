FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

COPY . .

ARG API_BASE_URL
RUN flutter pub get
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

FROM nginx:1.27-alpine
WORKDIR /usr/share/nginx/html

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

ENV PORT=10000
EXPOSE 10000
