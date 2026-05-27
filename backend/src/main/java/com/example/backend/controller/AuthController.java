package com.example.backend.controller;

import com.example.backend.service.AuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthController {
    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody Map<String, Object> payload) {
        String username = (String) payload.getOrDefault("username", "");
        String email = (String) payload.getOrDefault("email", "");
        String password = (String) payload.getOrDefault("password", "");
        String displayName = (String) payload.getOrDefault("displayName", "");
        Map<String, Object> resp = authService.register(username, email, password, displayName);
        return ResponseEntity.ok(resp);
    }

    @PostMapping("/signin")
    public ResponseEntity<?> signin(@RequestBody Map<String, Object> payload) {
        String username = (String) payload.getOrDefault("username", "");
        String password = (String) payload.getOrDefault("password", "");
        Map<String, Object> resp = authService.signin(username, password);
        return ResponseEntity.ok(resp);
    }
}
