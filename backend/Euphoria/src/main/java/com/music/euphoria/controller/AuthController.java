package com.music.euphoria.controller;

import com.music.euphoria.dto.LoginRequest;
import com.music.euphoria.dto.RegisterRequest;
import com.music.euphoria.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {
    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public String registerUser(@Valid @RequestBody RegisterRequest request) {
        authService.register(request);
        return "User Added Successfully";
    }

    @PostMapping("/login")
    public String login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request);
    }

}
