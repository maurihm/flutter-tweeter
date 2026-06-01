package com.example.backend.model;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;

public class PostResponse {
    private Long id;
    private String title;
    private String brand;
    private String model;
    private Integer year;
    private String photoUrl;
    private String description;
    private String authorUsername;
    private String authorDisplayName;
    private OffsetDateTime createdAt;
    private Map<String, Integer> reactions;
    private String userReaction;
    private List<CommentResponse> comments;

    public static PostResponse from(CarPost post, Map<String, Integer> reactions, String userReaction, List<CommentResponse> comments) {
        PostResponse response = new PostResponse();
        response.setId(post.getId());
        response.setTitle(post.getTitle());
        response.setBrand(post.getBrand());
        response.setModel(post.getModel());
        response.setYear(post.getYear());
        response.setPhotoUrl(post.getPhotoUrl());
        response.setDescription(post.getDescription());
        response.setAuthorUsername(post.getAuthorUsername());
        response.setAuthorDisplayName(post.getAuthorDisplayName());
        response.setCreatedAt(post.getCreatedAt());
        response.setReactions(reactions);
        response.setUserReaction(userReaction);
        response.setComments(comments);
        return response;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public Integer getYear() {
        return year;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getAuthorUsername() {
        return authorUsername;
    }

    public void setAuthorUsername(String authorUsername) {
        this.authorUsername = authorUsername;
    }

    public String getAuthorDisplayName() {
        return authorDisplayName;
    }

    public void setAuthorDisplayName(String authorDisplayName) {
        this.authorDisplayName = authorDisplayName;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(OffsetDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public Map<String, Integer> getReactions() {
        return reactions;
    }

    public void setReactions(Map<String, Integer> reactions) {
        this.reactions = reactions;
    }

    public String getUserReaction() {
        return userReaction;
    }

    public void setUserReaction(String userReaction) {
        this.userReaction = userReaction;
    }

    public List<CommentResponse> getComments() {
        return comments;
    }

    public void setComments(List<CommentResponse> comments) {
        this.comments = comments;
    }
}
