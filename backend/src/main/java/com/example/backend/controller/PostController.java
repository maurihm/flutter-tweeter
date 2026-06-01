package com.example.backend.controller;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.backend.model.PostResponse;
import com.example.backend.model.ReactionType;
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
    public ResponseEntity<List<PostResponse>> getPosts(
            @RequestHeader(value = "Authorization", required = false) String authHeader) {
        Long userId = extractUserId(authHeader);
        return ResponseEntity.ok(carPostService.fetchPosts(userId));
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

        PostResponse post = carPostService.createPost(userId, title, brand, model, year, photoUrl, description);
        return ResponseEntity.status(201).body(post);
    }

    @PostMapping("/{id}/reactions")
    public ResponseEntity<?> reactToPost(@RequestHeader(value = "Authorization", required = false) String authHeader,
                                         @PathVariable Long id,
                                         @RequestBody Map<String, Object> payload) {
        Long userId = extractUserId(authHeader);
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        String typeRaw = payload.get("type") == null ? "" : payload.get("type").toString().trim();
        if (typeRaw.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Reaction type is required"));
        }

        ReactionType reactionType;
        try {
            reactionType = ReactionType.valueOf(typeRaw.toUpperCase());
        } catch (IllegalArgumentException ex) {
            String supported = java.util.Arrays.stream(ReactionType.values())
                    .map(Enum::name)
                    .collect(Collectors.joining(", "));
            return ResponseEntity.badRequest().body(Map.of("error", "Invalid reaction type. Allowed: " + supported));
        }

        PostResponse post = carPostService.reactToPost(id, userId, reactionType);
        return ResponseEntity.ok(post);
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

    @GetMapping("/{id}/comments")
    public ResponseEntity<?> getComments(@PathVariable Long id) {
        return ResponseEntity.ok(carPostService.fetchComments(id));
    }

    @PostMapping("/{id}/comments")
    public ResponseEntity<?> addComment(@RequestHeader(value = "Authorization", required = false) String authHeader,
                                        @PathVariable Long id,
                                        @RequestBody Map<String, Object> payload) {
        Long userId = extractUserId(authHeader);
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }
        String content = payload.get("content") == null ? "" : payload.get("content").toString();
        if (content.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Content is required"));
        }
        try {
            return ResponseEntity.status(201).body(carPostService.addComment(id, userId, content));
        } catch (RuntimeException ex) {
            return ResponseEntity.status(400).body(Map.of("error", ex.getMessage()));
        }
    }

    @DeleteMapping("/{postId}/comments/{commentId}")
    public ResponseEntity<?> deleteComment(@RequestHeader(value = "Authorization", required = false) String authHeader,
                                           @PathVariable Long postId,
                                           @PathVariable Long commentId) {
        Long userId = extractUserId(authHeader);
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }
        try {
            carPostService.deleteComment(postId, commentId, userId);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException ex) {
            return ResponseEntity.status(403).body(Map.of("error", ex.getMessage()));
        }
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
