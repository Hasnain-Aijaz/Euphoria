package com.music.euphoria.controller;

import com.music.euphoria.dto.LoginRequest;
import com.music.euphoria.dto.RegisterRequest;
import com.music.euphoria.service.AuthService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
public class AuthController {
    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public String registerUser(@RequestBody RegisterRequest request) {
        authService.register(request);
        return "User Added Successfully";
    }

    @PostMapping("/login")
    public String login(@RequestBody LoginRequest request) {
        authService.login(request);
        return "Logged In Successfully";
    }

}
