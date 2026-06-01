package com.example.backend.model;

import java.time.OffsetDateTime;

public class CommentResponse {
    private Long id;
    private Long userId;
    private String authorUsername;
    private String authorDisplayName;
    private String content;
    private OffsetDateTime createdAt;

    public static CommentResponse from(Comment c) {
        CommentResponse r = new CommentResponse();
        r.setId(c.getId());
        r.setUserId(c.getUserId());
        r.setAuthorUsername(c.getAuthorUsername());
        r.setAuthorDisplayName(c.getAuthorDisplayName());
        r.setContent(c.getContent());
        r.setCreatedAt(c.getCreatedAt());
        return r;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getAuthorUsername() { return authorUsername; }
    public void setAuthorUsername(String authorUsername) { this.authorUsername = authorUsername; }
    public String getAuthorDisplayName() { return authorDisplayName; }
    public void setAuthorDisplayName(String authorDisplayName) { this.authorDisplayName = authorDisplayName; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
}
