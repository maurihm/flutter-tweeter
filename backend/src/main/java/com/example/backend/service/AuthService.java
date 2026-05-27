package com.example.backend.service;

import com.example.backend.model.User;
import com.example.backend.repository.UserRepository;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import org.mindrot.jbcrypt.BCrypt;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Service
public class AuthService {
    private final UserRepository userRepository;
    private final String jwtSecret;

    public AuthService(UserRepository userRepository) {
        this.userRepository = userRepository;
        this.jwtSecret = System.getenv().getOrDefault("JWT_SECRET", "please_change_this_secret");
    }

    public Map<String, Object> register(String username, String email, String password, String displayName) {
        if (userRepository.findByUsername(username).isPresent()) {
            throw new RuntimeException("Username already exists");
        }
        String hashed = BCrypt.hashpw(password, BCrypt.gensalt());
        User user = new User(username, hashed, email, displayName);
        user = userRepository.save(user);
        String token = generateToken(user);
        Map<String, Object> resp = new HashMap<>();
        resp.put("accessToken", token);
        resp.put("id", user.getId());
        resp.put("username", user.getUsername());
        resp.put("email", user.getEmail());
        resp.put("displayName", user.getDisplayName());
        return resp;
    }

    public Map<String, Object> signin(String username, String password) {
        User user = userRepository.findByUsername(username).orElseThrow(() -> new RuntimeException("Invalid credentials"));
        if (!BCrypt.checkpw(password, user.getPassword())) {
            throw new RuntimeException("Invalid credentials");
        }
        String token = generateToken(user);
        Map<String, Object> resp = new HashMap<>();
        resp.put("accessToken", token);
        resp.put("id", user.getId());
        resp.put("username", user.getUsername());
        resp.put("email", user.getEmail());
        resp.put("displayName", user.getDisplayName());
        return resp;
    }

    private String generateToken(User user) {
        long now = System.currentTimeMillis();
        long exp = now + 1000L * 60 * 60 * 24 * 7; // 7 days
        return Jwts.builder()
                .setSubject(String.valueOf(user.getId()))
                .claim("username", user.getUsername())
                .setIssuedAt(new Date(now))
                .setExpiration(new Date(exp))
                .signWith(SignatureAlgorithm.HS256, jwtSecret.getBytes())
                .compact();
    }

    public Long validateTokenAndGetUserId(String token) {
        if (token == null) return null;
        try {
            String subject = Jwts.parser().setSigningKey(jwtSecret.getBytes()).parseClaimsJws(token).getBody().getSubject();
            return Long.parseLong(subject);
        } catch (Exception e) {
            return null;
        }
    }
}
