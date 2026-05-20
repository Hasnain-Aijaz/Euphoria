package com.music.euphoria.controller;

import com.music.euphoria.dto.LikedSongResponse;
import com.music.euphoria.dto.SongSummaryResponse;
import com.music.euphoria.service.LikedSongService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/likes/songs")
public class LikedSongController {
    private final LikedSongService likedSongService;

    public LikedSongController(LikedSongService likedSongService) {
        this.likedSongService = likedSongService;
    }

    @PostMapping("/{songId}")
    public LikedSongResponse likeSong(@PathVariable int songId) {
        return likedSongService.likeSong(songId);
    }

    @DeleteMapping("/{songId}")
    public void unlikeSong(@PathVariable int songId) {
        likedSongService.unlikeSong(songId);
    }

    @GetMapping
    public List<SongSummaryResponse> getMyLikedSongs() {
        return likedSongService.getMyLikedSongs();
    }
}
