package com.example.backend.repository;

import java.util.Collection;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.backend.model.Comment;

@Repository
public interface CommentRepository extends JpaRepository<Comment, Long> {
    List<Comment> findAllByPost_IdOrderByCreatedAtAsc(Long postId);
    List<Comment> findAllByPost_IdIn(Collection<Long> postIds);
    void deleteByPost_Id(Long postId);
}
