package com.example.backend.config;

import java.net.URI;

import javax.sql.DataSource;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

@Configuration
public class DataSourceConfig {
    @Bean
    public DataSource dataSource() {
        String databaseUrl = System.getenv("DATABASE_URL");
        if (databaseUrl == null || databaseUrl.isEmpty()) {
            // fallback to localhost
            HikariConfig config = new HikariConfig();
            config.setJdbcUrl("jdbc:postgresql://localhost:5432/defaultdb");
            config.setUsername("postgres");
            config.setPassword("");
            return new HikariDataSource(config);
        }

        try {
            // DATABASE_URL in form: postgres://user:pass@host:port/dbname?sslmode=require
            URI dbUri = new URI(databaseUrl);
            String userInfo = dbUri.getUserInfo();
            String username = null;
            String password = null;
            if (userInfo != null && userInfo.contains(":")) {
                String[] parts = userInfo.split(":", 2);
                username = parts[0];
                password = parts[1];
            }
            String host = dbUri.getHost();
            int port = dbUri.getPort();
            String path = dbUri.getPath();
            String dbName = path != null && path.length() > 1 ? path.substring(1) : "defaultdb";

            String query = dbUri.getQuery();
            String jdbcUrl = String.format("jdbc:postgresql://%s:%d/%s", host, port, dbName);
            if (query != null && !query.isEmpty()) {
                jdbcUrl += "?" + query;
            }

            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(jdbcUrl);
            if (username != null) config.setUsername(username);
            if (password != null) config.setPassword(password);
            // Aiven requires TLS; allow the URL query to include sslmode=require
            return new HikariDataSource(config);
        } catch (Exception e) {
            throw new RuntimeException("Invalid DATABASE_URL: " + e.getMessage(), e);
        }
    }
}

