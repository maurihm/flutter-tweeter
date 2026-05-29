package com.example.backend.repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.backend.model.PostReaction;

@Repository
public interface PostReactionRepository extends JpaRepository<PostReaction, Long> {
    Optional<PostReaction> findByPost_IdAndUserId(Long postId, Long userId);
    List<PostReaction> findAllByPost_IdIn(Collection<Long> postIds);
    void deleteByPost_Id(Long postId);
}
