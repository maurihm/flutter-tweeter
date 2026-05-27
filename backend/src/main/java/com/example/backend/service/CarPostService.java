package com.example.backend.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.backend.model.CarPost;
import com.example.backend.model.User;
import com.example.backend.repository.CarPostRepository;
import com.example.backend.repository.UserRepository;

@Service
public class CarPostService {
    private final CarPostRepository carPostRepository;
    private final UserRepository userRepository;

    public CarPostService(CarPostRepository carPostRepository, UserRepository userRepository) {
        this.carPostRepository = carPostRepository;
        this.userRepository = userRepository;
    }

    public List<CarPost> fetchPosts() {
        return carPostRepository.findAllByOrderByCreatedAtDesc();
    }

    public CarPost createPost(Long userId, String title, String brand, String model, Integer year, String photoUrl,
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
        return carPostRepository.save(post);
    }

    public void deletePost(Long id) {
        carPostRepository.deleteById(id);
    }
}
