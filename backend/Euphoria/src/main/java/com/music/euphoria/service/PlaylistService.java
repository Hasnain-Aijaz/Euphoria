package com.music.euphoria.service;

import com.music.euphoria.dto.CreatePlaylistRequest;
import com.music.euphoria.dto.PlaylistResponse;
import com.music.euphoria.entity.PlaylistSong;
import com.music.euphoria.entity.PlaylistSongId;
import com.music.euphoria.entity.Song;
import com.music.euphoria.entity.Playlist;
import com.music.euphoria.entity.User;
import com.music.euphoria.repository.PlaylistRepository;
import com.music.euphoria.repository.PlaylistSongRepository;
import com.music.euphoria.repository.SongRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;

import static org.springframework.http.HttpStatus.CONFLICT;
import static org.springframework.http.HttpStatus.FORBIDDEN;
import static org.springframework.http.HttpStatus.NOT_FOUND;

@Service
public class PlaylistService {
    private final PlaylistRepository playlistRepository;
    private final PlaylistSongRepository playlistSongRepository;
    private final SongRepository songRepository;
    private final CurrentUserService currentUserService;

    public PlaylistService(
            PlaylistRepository playlistRepository,
            PlaylistSongRepository playlistSongRepository,
            SongRepository songRepository,
            CurrentUserService currentUserService
    ) {
        this.playlistRepository = playlistRepository;
        this.playlistSongRepository = playlistSongRepository;
        this.songRepository = songRepository;
        this.currentUserService = currentUserService;
    }

    public Playlist createPlaylist(CreatePlaylistRequest request) {
        User currentUser = currentUserService.getCurrentUser();

        Playlist playlist = new Playlist();
        playlist.setUser(currentUser);
        playlist.setPlaylistName(request.getPlaylistName());
        playlist.setDescription(request.getDescription());
        playlist.setCreatedAt(LocalDateTime.now());

        return playlistRepository.save(playlist);
    }

    public PlaylistResponse createPlaylistResponse(CreatePlaylistRequest request) {
        Playlist playlist = createPlaylist(request);
        return toPlaylistResponse(playlist);
    }

    public List<PlaylistResponse> getMyPlaylists() {
        User currentUser = currentUserService.getCurrentUser();
        return playlistRepository.findByUserId(currentUser.getId())
                .stream()
                .map(this::toPlaylistResponse)
                .toList();
    }

    public PlaylistResponse addSongToPlaylist(int playlistId, int songId) {
        Playlist playlist = getOwnedPlaylist(playlistId);
        Song song = songRepository.findById(songId)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Song not found"));

        if (playlistSongRepository.existsByPlaylistIdAndSongId(playlistId, songId)) {
            throw new ResponseStatusException(CONFLICT, "Song already exists in playlist");
        }

        PlaylistSong playlistSong = new PlaylistSong();
        playlistSong.setId(new PlaylistSongId(playlistId, songId));
        playlistSong.setPlaylist(playlist);
        playlistSong.setSong(song);
        playlistSong.setAddedAt(LocalDateTime.now());
        playlistSongRepository.save(playlistSong);

        return toPlaylistResponse(playlist);
    }

    public PlaylistResponse removeSongFromPlaylist(int playlistId, int songId) {
        Playlist playlist = getOwnedPlaylist(playlistId);

        if (!playlistSongRepository.existsByPlaylistIdAndSongId(playlistId, songId)) {
            throw new ResponseStatusException(NOT_FOUND, "Song is not in this playlist");
        }

        playlistSongRepository.deleteByPlaylistIdAndSongId(playlistId, songId);
        return toPlaylistResponse(playlist);
    }

    public void deletePlaylist(int playlistId) {
        Playlist playlist = getOwnedPlaylist(playlistId);
        playlistRepository.delete(playlist);
    }

    private PlaylistResponse toPlaylistResponse(Playlist playlist) {
        User user = playlist.getUser();

        return new PlaylistResponse(
                playlist.getId(),
                user.getId(),
                user.getUsername(),
                playlist.getPlaylistName(),
                playlist.getDescription(),
                playlist.getCreatedAt()
        );
    }

    private Playlist getOwnedPlaylist(int playlistId) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Playlist not found"));

        User currentUser = currentUserService.getCurrentUser();
        if (playlist.getUser().getId() != currentUser.getId()) {
            throw new ResponseStatusException(FORBIDDEN, "You do not own this playlist");
        }

        return playlist;
    }
}
