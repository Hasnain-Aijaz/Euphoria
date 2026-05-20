package com.music.euphoria.controller;

import com.music.euphoria.dto.CreatePlaylistRequest;
import com.music.euphoria.dto.PlaylistResponse;
import com.music.euphoria.service.PlaylistService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/playlists")
public class PlaylistController {
    private final PlaylistService playlistService;

    public PlaylistController(PlaylistService playlistService) {
        this.playlistService = playlistService;
    }

    @PostMapping
    public PlaylistResponse createPlaylist(@Valid @RequestBody CreatePlaylistRequest request) {
        return playlistService.createPlaylistResponse(request);
    }

    @GetMapping("/me")
    public List<PlaylistResponse> getMyPlaylists() {
        return playlistService.getMyPlaylists();
    }

    @PostMapping("/{playlistId}/songs/{songId}")
    public PlaylistResponse addSongToPlaylist(
            @PathVariable int playlistId,
            @PathVariable int songId
    ) {
        return playlistService.addSongToPlaylist(playlistId, songId);
    }

    @DeleteMapping("/{playlistId}/songs/{songId}")
    public PlaylistResponse removeSongFromPlaylist(
            @PathVariable int playlistId,
            @PathVariable int songId
    ) {
        return playlistService.removeSongFromPlaylist(playlistId, songId);
    }

    @DeleteMapping("/{playlistId}")
    public void deletePlaylist(@PathVariable int playlistId) {
        playlistService.deletePlaylist(playlistId);
    }
}
