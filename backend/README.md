Spring Boot backend for Flutter Tweeter

Quick start

1. Build:
   ```bash
   cd backend
   mvn -B package -DskipTests
   ```
2. Run locally (set DATABASE_URL and JWT_SECRET):
   ```bash
   export DATABASE_URL="postgres://user:pass@host:port/dbname?sslmode=require"
   export JWT_SECRET="change_this_secret"
   java -jar target/flutter-tweeter-backend-0.1.0.jar
   ```

Render deployment notes
- Set `DATABASE_URL` to the Aiven URI.
- Set `JWT_SECRET` to a secure random value.
- Build command: `mvn -B package -DskipTests`
- Start command: `java -jar target/flutter-tweeter-backend-0.1.0.jar`
