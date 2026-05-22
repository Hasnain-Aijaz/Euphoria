package com.music.euphoria.service;

import com.music.euphoria.dto.CreatePlaylistRequest;
import com.music.euphoria.dto.PlaylistResponse;
import com.music.euphoria.dto.SongSummaryResponse;
import com.music.euphoria.entity.PlaylistSong;
import com.music.euphoria.entity.PlaylistSongId;
import com.music.euphoria.entity.Song;
import com.music.euphoria.entity.Playlist;
import com.music.euphoria.entity.User;
import com.music.euphoria.repository.PlaylistRepository;
import com.music.euphoria.repository.PlaylistSongRepository;
import com.music.euphoria.repository.SongRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;

import static org.springframework.http.HttpStatus.CONFLICT;
import static org.springframework.http.HttpStatus.FORBIDDEN;
import static org.springframework.http.HttpStatus.NOT_FOUND;

@Service
@Transactional
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

        PlaylistSongId psId = new PlaylistSongId(playlistId, songId);
        if (playlistSongRepository.existsById(psId)) {
            throw new ResponseStatusException(CONFLICT, "Song already exists in playlist");
        }

        PlaylistSong playlistSong = new PlaylistSong();
        playlistSong.setId(psId);
        playlistSong.setPlaylist(playlist);
        playlistSong.setSong(song);
        playlistSong.setAddedAt(LocalDateTime.now());
        
        playlist.getPlaylistSongs().add(playlistSong);
        playlistRepository.save(playlist);

        return toPlaylistResponse(playlist);
    }

    public PlaylistResponse removeSongFromPlaylist(int playlistId, int songId) {
        Playlist playlist = getOwnedPlaylist(playlistId);

        // Find and remove from the collection to maintain state and trigger orphan removal
        boolean removed = playlist.getPlaylistSongs().removeIf(ps -> 
            ps.getPlaylist().getId() == playlistId && ps.getSong().getId() == songId
        );

        if (!removed) {
            throw new ResponseStatusException(NOT_FOUND, "Song is not in this playlist");
        }

        playlistRepository.save(playlist);
        return toPlaylistResponse(playlist);
    }

    public void deletePlaylist(int playlistId) {
        Playlist playlist = getOwnedPlaylist(playlistId);
        playlistRepository.delete(playlist);
    }

    private PlaylistResponse toPlaylistResponse(Playlist playlist) {
        User user = playlist.getUser();

        List<SongSummaryResponse> songs = playlist.getPlaylistSongs()
                .stream()
                .map(PlaylistSong::getSong)
                .map(this::toSongSummary)
                .toList();

        return new PlaylistResponse(
                playlist.getId(),
                user.getId(),
                user.getUsername(),
                playlist.getPlaylistName(),
                playlist.getDescription(),
                playlist.getCreatedAt(),
                songs
        );
    }

    private SongSummaryResponse toSongSummary(Song song) {
        String artistName = song.getArtist() != null ? song.getArtist().getName() : null;
        Integer albumId = song.getAlbum() != null ? song.getAlbum().getId() : null;
        String albumTitle = song.getAlbum() != null ? song.getAlbum().getTitle() : null;

        return new SongSummaryResponse(
                song.getId(),
                song.getTitle(),
                artistName,
                albumId,
                albumTitle,
                song.getGenre(),
                song.getDurationSeconds(),
                song.getAudioUrl(),
                song.getThumbnailUrl(),
                song.getPlayCount(),
                song.getUploadedAt()
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
