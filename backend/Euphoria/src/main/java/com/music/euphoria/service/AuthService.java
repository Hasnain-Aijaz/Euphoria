package com.music.euphoria.service;


import com.music.euphoria.dto.LoginRequest;
import com.music.euphoria.entity.User;
import com.music.euphoria.repository.UserRepository;
import com.music.euphoria.dto.RegisterRequest;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {
    private final UserRepository userRepository;

    public AuthService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public void register(RegisterRequest request) {
        Optional<User> existingUser =
                userRepository.findByEmail(request.getEmail());

        if(existingUser.isPresent()) {
            throw new RuntimeException("Email already exists");
        }

        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

        String hashedPassword = encoder.encode(request.getPassword());

        User user = new User();
        user.setEmail(request.getEmail());
        user.setPasswordHash(hashedPassword);
        user.setUsername(request.getUsername());
        user.setCreatedAt(LocalDateTime.now());
        userRepository.save(user);
    }

    public void login(LoginRequest request) {
        Optional<User> user =
                userRepository.findByEmail(request.getEmail());

        if(user.isEmpty()) {
            throw new RuntimeException("No user found with this email");
        }

        //Password
        User existingUser = user.get();

        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

        // encoder.matches returns a boolean value.
        boolean passwordMatches = encoder.matches(request.getPassword(), existingUser.getPasswordHash()); // encoder.matches returns a boolean value.

        if(!passwordMatches) {
            throw new RuntimeException("Incorrect Password");
        }

    }


}
