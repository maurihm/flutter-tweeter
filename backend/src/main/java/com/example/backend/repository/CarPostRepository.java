package com.example.backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.backend.model.CarPost;

@Repository
public interface CarPostRepository extends JpaRepository<CarPost, Long> {
    List<CarPost> findAllByOrderByCreatedAtDesc();
}
