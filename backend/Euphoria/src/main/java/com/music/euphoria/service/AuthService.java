package com.music.euphoria.service;


import com.music.euphoria.dto.LoginRequest;
import com.music.euphoria.entity.User;
import com.music.euphoria.repository.UserRepository;
import com.music.euphoria.dto.RegisterRequest;
import com.music.euphoria.security.JwtService;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import static org.springframework.http.HttpStatus.CONFLICT;
import static org.springframework.http.HttpStatus.UNAUTHORIZED;

@Service
public class AuthService {
    private final UserRepository userRepository;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;

    public AuthService(UserRepository userRepository, JwtService jwtService, PasswordEncoder passwordEncoder) {

        this.userRepository = userRepository;
        this.jwtService = jwtService;
        this.passwordEncoder = passwordEncoder;
    }

    public void register(RegisterRequest request) {
        Optional<User> existingUser =
                userRepository.findByEmail(request.getEmail());

        if(existingUser.isPresent()) {
            throw new ResponseStatusException(CONFLICT, "Email already exists");
        }

        Optional<User> existingUsername =
                userRepository.findByUsername(request.getUsername());

        if(existingUsername.isPresent()) {
            throw new ResponseStatusException(CONFLICT, "Username already exists");
        }

        String hashedPassword = passwordEncoder.encode(request.getPassword());

        User user = new User();
        user.setEmail(request.getEmail());
        user.setPasswordHash(hashedPassword);
        user.setUsername(request.getUsername());
        user.setCreatedAt(LocalDateTime.now());
        userRepository.save(user);
    }

    public String login(LoginRequest request) {
        Optional<User> user =
                userRepository.findByEmail(request.getEmail());

        if(user.isEmpty()) {
            throw new ResponseStatusException(UNAUTHORIZED, "Invalid email or password");
        }

        //Password
        User existingUser = user.get();

        // encoder.matches returns a boolean value.
        boolean passwordMatches = passwordEncoder.matches(request.getPassword(), existingUser.getPasswordHash()); // encoder.matches returns a boolean value.

        if(!passwordMatches) {
            throw new ResponseStatusException(UNAUTHORIZED, "Invalid email or password");
        }
        String token = jwtService.generateToken(existingUser.getEmail());
        return token;
    }


}
