package com.music.euphoria.service;

import com.music.euphoria.dto.ListeningHistoryResponse;
import com.music.euphoria.dto.SongSummaryResponse;
import com.music.euphoria.entity.ListeningHistory;
import com.music.euphoria.entity.Song;
import com.music.euphoria.entity.User;
import com.music.euphoria.repository.ListeningHistoryRepository;
import com.music.euphoria.repository.SongRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;

import static org.springframework.http.HttpStatus.NOT_FOUND;

@Service
public class ListeningHistoryService {
    private final ListeningHistoryRepository listeningHistoryRepository;
    private final SongRepository songRepository;
    private final CurrentUserService currentUserService;

    public ListeningHistoryService(
            ListeningHistoryRepository listeningHistoryRepository,
            SongRepository songRepository,
            CurrentUserService currentUserService
    ) {
        this.listeningHistoryRepository = listeningHistoryRepository;
        this.songRepository = songRepository;
        this.currentUserService = currentUserService;
    }

    public ListeningHistoryResponse recordPlay(int songId) {
        User currentUser = currentUserService.getCurrentUser();
        Song song = songRepository.findById(songId)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Song not found"));

        ListeningHistory listeningHistory = new ListeningHistory();
        listeningHistory.setUser(currentUser);
        listeningHistory.setSong(song);
        listeningHistory.setPlayedAt(LocalDateTime.now());

        ListeningHistory saved = listeningHistoryRepository.save(listeningHistory);
        return new ListeningHistoryResponse(
                saved.getId(),
                toSongSummary(saved.getSong()),
                saved.getPlayedAt()
        );
    }

    public List<ListeningHistoryResponse> getMyHistory() {
        User currentUser = currentUserService.getCurrentUser();
        return listeningHistoryRepository.findByUserIdOrderByPlayedAtDesc(currentUser.getId())
                .stream()
                .map(history -> new ListeningHistoryResponse(
                        history.getId(),
                        toSongSummary(history.getSong()),
                        history.getPlayedAt()
                ))
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
