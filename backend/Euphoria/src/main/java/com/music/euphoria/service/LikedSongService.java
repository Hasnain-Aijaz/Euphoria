package com.music.euphoria.service;

import com.music.euphoria.dto.LikedSongResponse;
import com.music.euphoria.dto.SongSummaryResponse;
import com.music.euphoria.entity.LikedSong;
import com.music.euphoria.entity.LikedSongId;
import com.music.euphoria.entity.Song;
import com.music.euphoria.entity.User;
import com.music.euphoria.repository.LikedSongRepository;
import com.music.euphoria.repository.SongRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;

import static org.springframework.http.HttpStatus.CONFLICT;
import static org.springframework.http.HttpStatus.NOT_FOUND;

@Service
public class LikedSongService {
    private final LikedSongRepository likedSongRepository;
    private final SongRepository songRepository;
    private final CurrentUserService currentUserService;

    public LikedSongService(
            LikedSongRepository likedSongRepository,
            SongRepository songRepository,
            CurrentUserService currentUserService
    ) {
        this.likedSongRepository = likedSongRepository;
        this.songRepository = songRepository;
        this.currentUserService = currentUserService;
    }

    public LikedSongResponse likeSong(int songId) {
        User currentUser = currentUserService.getCurrentUser();
        Song song = songRepository.findById(songId)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Song not found"));

        if (likedSongRepository.existsByUserIdAndSongId(currentUser.getId(), songId)) {
            throw new ResponseStatusException(CONFLICT, "Song already liked");
        }

        LikedSong likedSong = new LikedSong();
        likedSong.setId(new LikedSongId(currentUser.getId(), songId));
        likedSong.setUser(currentUser);
        likedSong.setSong(song);
        likedSong.setLikedAt(LocalDateTime.now());
        LikedSong saved = likedSongRepository.save(likedSong);

        return new LikedSongResponse(toSongSummary(saved.getSong()), saved.getLikedAt());
    }

    public void unlikeSong(int songId) {
        User currentUser = currentUserService.getCurrentUser();

        if (!likedSongRepository.existsByUserIdAndSongId(currentUser.getId(), songId)) {
            throw new ResponseStatusException(NOT_FOUND, "Song is not liked");
        }

        likedSongRepository.deleteByUserIdAndSongId(currentUser.getId(), songId);
    }

    public List<SongSummaryResponse> getMyLikedSongs() {
        User currentUser = currentUserService.getCurrentUser();
        return likedSongRepository.findByUserId(currentUser.getId())
                .stream()
                .map(LikedSong::getSong)
                .map(this::toSongSummary)
                .toList();
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
}
