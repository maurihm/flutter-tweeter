package com.example.backend.service;

import com.example.backend.model.Tweet;
import com.example.backend.model.User;
import com.example.backend.repository.TweetRepository;
import com.example.backend.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TweetService {
    private final TweetRepository tweetRepository;
    private final UserRepository userRepository;

    public TweetService(TweetRepository tweetRepository, UserRepository userRepository) {
        this.tweetRepository = tweetRepository;
        this.userRepository = userRepository;
    }

    public List<Tweet> fetchTweets() {
        return tweetRepository.findAllByOrderByCreatedAtDesc();
    }

    public Tweet createTweet(Long userId, String content) {
        User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));
        Tweet t = new Tweet(content, user);
        return tweetRepository.save(t);
    }

    public void deleteTweet(Long id) {
        tweetRepository.deleteById(id);
    }
}
