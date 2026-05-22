package com.music.euphoria.service;

import com.music.euphoria.entity.User;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    private final CurrentUserService currentUserService;

    public UserService(CurrentUserService currentUserService) {
        this.currentUserService = currentUserService;
    }

    public User getMe() {
        return currentUserService.getCurrentUser();
    }
}
