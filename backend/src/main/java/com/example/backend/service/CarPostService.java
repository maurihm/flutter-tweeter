package com.example.backend.service;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.example.backend.model.CarPost;
import com.example.backend.model.PostReaction;
import com.example.backend.model.PostResponse;
import com.example.backend.model.ReactionType;
import com.example.backend.model.User;
import com.example.backend.repository.CarPostRepository;
import com.example.backend.repository.PostReactionRepository;
import com.example.backend.repository.UserRepository;

@Service
public class CarPostService {
    private final CarPostRepository carPostRepository;
    private final UserRepository userRepository;
    private final PostReactionRepository postReactionRepository;

    public CarPostService(CarPostRepository carPostRepository,
                          UserRepository userRepository,
                          PostReactionRepository postReactionRepository) {
        this.carPostRepository = carPostRepository;
        this.userRepository = userRepository;
        this.postReactionRepository = postReactionRepository;
    }

    public List<PostResponse> fetchPosts(Long currentUserId) {
        List<CarPost> posts = carPostRepository.findAllByOrderByCreatedAtDesc();
        return enrichWithReactions(posts, currentUserId);
    }

    public PostResponse createPost(Long userId,
                                   String title,
                                   String brand,
                                   String model,
                                   Integer year,
                                   String photoUrl,
                                   String description) {
        User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));
        CarPost post = new CarPost(
                title,
                brand,
                model,
                year,
                photoUrl,
                description,
                user.getUsername(),
                user.getDisplayName() == null || user.getDisplayName().isBlank()
                        ? user.getUsername()
                        : user.getDisplayName()
        );
        CarPost saved = carPostRepository.save(post);
        return PostResponse.from(saved, newReactionMap(), null);
    }

    public PostResponse reactToPost(Long postId, Long userId, ReactionType reactionType) {
        CarPost post = carPostRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        Optional<PostReaction> existingReaction = postReactionRepository.findByPost_IdAndUserId(postId, userId);
        if (existingReaction.isPresent()) {
            PostReaction current = existingReaction.get();
            if (current.getType() == reactionType) {
                postReactionRepository.delete(current);
            } else {
                current.setType(reactionType);
                current.setReactedAt(OffsetDateTime.now());
                postReactionRepository.save(current);
            }
        } else {
            postReactionRepository.save(new PostReaction(post, userId, reactionType));
        }

        List<PostResponse> enriched = enrichWithReactions(List.of(post), userId);
        return enriched.isEmpty()
                ? PostResponse.from(post, newReactionMap(), null)
                : enriched.get(0);
    }

    public void deletePost(Long id) {
        postReactionRepository.deleteByPost_Id(id);
        carPostRepository.deleteById(id);
    }

    private List<PostResponse> enrichWithReactions(List<CarPost> posts, Long currentUserId) {
        if (posts.isEmpty()) {
            return List.of();
        }

        List<Long> postIds = posts.stream().map(CarPost::getId).collect(Collectors.toList());
        List<PostReaction> reactions = postReactionRepository.findAllByPost_IdIn(postIds);

        Map<Long, Map<String, Integer>> countsByPostId = new LinkedHashMap<>();
        Map<Long, String> userReactionByPostId = new LinkedHashMap<>();

        for (PostReaction reaction : reactions) {
            Long postId = reaction.getPost().getId();
            Map<String, Integer> postCounts = countsByPostId.computeIfAbsent(postId, ignored -> newReactionMap());
            String key = reaction.getType().name();
            postCounts.put(key, postCounts.getOrDefault(key, 0) + 1);

            if (currentUserId != null && currentUserId.equals(reaction.getUserId())) {
                userReactionByPostId.put(postId, key);
            }
        }

        List<PostResponse> response = new ArrayList<>();
        for (CarPost post : posts) {
            Map<String, Integer> reactionsMap = countsByPostId.getOrDefault(post.getId(), newReactionMap());
            String userReaction = userReactionByPostId.get(post.getId());
            response.add(PostResponse.from(post, reactionsMap, userReaction));
        }
        return response;
    }

    private Map<String, Integer> newReactionMap() {
        Map<String, Integer> reactions = new LinkedHashMap<>();
        for (ReactionType type : ReactionType.values()) {
            reactions.put(type.name(), 0);
        }
        return reactions;
    }
}
