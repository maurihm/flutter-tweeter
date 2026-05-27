package com.example.backend.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.backend.model.CarPost;
import com.example.backend.service.AuthService;
import com.example.backend.service.CarPostService;

@RestController
@RequestMapping("/posts")
public class PostController {
    private final CarPostService carPostService;
    private final AuthService authService;

    public PostController(CarPostService carPostService, AuthService authService) {
        this.carPostService = carPostService;
        this.authService = authService;
    }

    @GetMapping
    public ResponseEntity<List<CarPost>> getPosts() {
        return ResponseEntity.ok(carPostService.fetchPosts());
    }

    @PostMapping
    public ResponseEntity<?> createPost(@RequestHeader(value = "Authorization", required = false) String authHeader,
                                        @RequestBody Map<String, Object> payload) {
        Long userId = extractUserId(authHeader);
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        String title = (String) payload.getOrDefault("title", "");
        String photoUrl = (String) payload.getOrDefault("photoUrl", "");
        String brand = (String) payload.get("brand");
        String model = (String) payload.get("model");
        Integer year = parseInteger(payload.get("year"));
        String description = (String) payload.get("description");

        if (title.isBlank() || photoUrl.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Title and photoUrl are required"));
        }

        CarPost post = carPostService.createPost(userId, title, brand, model, year, photoUrl, description);
        return ResponseEntity.status(201).body(post);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deletePost(@RequestHeader(value = "Authorization", required = false) String authHeader,
                                        @PathVariable Long id) {
        Long userId = extractUserId(authHeader);
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        carPostService.deletePost(id);
        return ResponseEntity.noContent().build();
    }

    private Long extractUserId(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) return null;
        String token = authHeader.substring(7);
        return authService.validateTokenAndGetUserId(token);
    }

    private Integer parseInteger(Object value) {
        if (value == null) return null;
        if (value instanceof Integer) return (Integer) value;
        try {
            return Integer.parseInt(value.toString());
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}
