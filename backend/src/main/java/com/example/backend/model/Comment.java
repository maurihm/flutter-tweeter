package com.example.backend.model;

import java.time.OffsetDateTime;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name = "comments")
public class Comment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "post_id", nullable = false)
    private CarPost post;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(nullable = false)
    private String authorUsername;

    @Column(nullable = false)
    private String authorDisplayName;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    private OffsetDateTime createdAt;

    public Comment() {}

    public Comment(CarPost post, Long userId, String authorUsername, String authorDisplayName, String content) {
        this.post = post;
        this.userId = userId;
        this.authorUsername = authorUsername;
        this.authorDisplayName = authorDisplayName;
        this.content = content;
        this.createdAt = OffsetDateTime.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public CarPost getPost() { return post; }
    public void setPost(CarPost post) { this.post = post; }
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
