package com.example.backend.model;

import java.time.OffsetDateTime;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "posts")
public class CarPost {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    private String brand;
    private String model;
    private Integer year;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String photoUrl;

    @Column(length = 4000)
    private String description;

    @Column(nullable = false)
    private String authorUsername;

    @Column(nullable = false)
    private String authorDisplayName;

    private OffsetDateTime createdAt;

    public CarPost() {}

    public CarPost(String title, String brand, String model, Integer year, String photoUrl, String description,
                   String authorUsername, String authorDisplayName) {
        this.title = title;
        this.brand = brand;
        this.model = model;
        this.year = year;
        this.photoUrl = photoUrl;
        this.description = description;
        this.authorUsername = authorUsername;
        this.authorDisplayName = authorDisplayName;
        this.createdAt = OffsetDateTime.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }
    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }
    public Integer getYear() { return year; }
    public void setYear(Integer year) { this.year = year; }
    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getAuthorUsername() { return authorUsername; }
    public void setAuthorUsername(String authorUsername) { this.authorUsername = authorUsername; }
    public String getAuthorDisplayName() { return authorDisplayName; }
    public void setAuthorDisplayName(String authorDisplayName) { this.authorDisplayName = authorDisplayName; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
}
