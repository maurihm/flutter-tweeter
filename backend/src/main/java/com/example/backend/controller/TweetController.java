package com.example.backend.controller;

import com.example.backend.model.Tweet;
import com.example.backend.service.AuthService;
import com.example.backend.service.TweetService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/tweets")
public class TweetController {
    private final TweetService tweetService;
    private final AuthService authService;

    public TweetController(TweetService tweetService, AuthService authService) {
        this.tweetService = tweetService;
        this.authService = authService;
    }

    @GetMapping
    public ResponseEntity<List<Tweet>> getTweets() {
        return ResponseEntity.ok(tweetService.fetchTweets());
    }

    @PostMapping
    public ResponseEntity<?> createTweet(@RequestHeader(value = "Authorization", required = false) String authHeader,
                                         @RequestBody Map<String, Object> payload) {
        Long userId = extractUserId(authHeader);
        if (userId == null) return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        String content = (String) payload.getOrDefault("tweet", "");
        if (content == null || content.isEmpty()) return ResponseEntity.badRequest().body(Map.of("error", "Empty tweet"));
        Tweet t = tweetService.createTweet(userId, content);
        return ResponseEntity.status(201).body(t);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTweet(@RequestHeader(value = "Authorization", required = false) String authHeader,
                                         @PathVariable Long id) {
        Long userId = extractUserId(authHeader);
        if (userId == null) return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        tweetService.deleteTweet(id);
        return ResponseEntity.noContent().build();
    }

    private Long extractUserId(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) return null;
        String token = authHeader.substring(7);
        return authService.validateTokenAndGetUserId(token);
    }
}
