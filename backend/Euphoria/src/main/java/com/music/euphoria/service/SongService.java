package com.music.euphoria.service;

import com.music.euphoria.dto.CreateSongRequest;
import com.music.euphoria.entity.Album;
import com.music.euphoria.entity.Artist;
import com.music.euphoria.entity.Song;
import com.music.euphoria.repository.AlbumRepository;
import com.music.euphoria.repository.ArtistRepository;
import com.music.euphoria.repository.SongRepository;
import com.mpatric.mp3agic.Mp3File;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.util.List;

import static org.springframework.http.HttpStatus.NOT_FOUND;

@Service
public class SongService {
    private final SongRepository songRepository;
    private final ArtistRepository artistRepository;
    private final AlbumRepository albumRepository;
    private final ListeningHistoryService listeningHistoryService;
    private final MediaService mediaService;

    public SongService(
            SongRepository songRepository,
            ArtistRepository artistRepository,
            AlbumRepository albumRepository,
            ListeningHistoryService listeningHistoryService,
            MediaService mediaService
    ) {
        this.songRepository = songRepository;
        this.artistRepository = artistRepository;
        this.albumRepository = albumRepository;
        this.listeningHistoryService = listeningHistoryService;
        this.mediaService = mediaService;
    }

    public List<Song> getAllSongs() {
        return songRepository.findAll();
    }

    public List<Song> searchSongs(String title) {
        return songRepository.findByTitleContainingIgnoreCase(title);
    }

    public Song getSongById(int id) {
        return songRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Song not found"));
    }

    public List<Song> getSongsByGenre(String genre) {
        return songRepository.findByGenreIgnoreCase(genre);
    }

    public List<Song> getSongsByArtist(int artistId) {
        return songRepository.findByArtistId(artistId);
    }

    public List<Song> getSongsByAlbum(int albumId) {
        return songRepository.findByAlbumId(albumId);
    }

    public Song incrementPlayCount(int songId) {
        Song song = getSongById(songId);
        song.setPlayCount(song.getPlayCount() + 1);
        Song updatedSong = songRepository.save(song);
        listeningHistoryService.recordPlay(songId);
        return updatedSong;
    }

    public Song createSong(CreateSongRequest request, org.springframework.web.multipart.MultipartFile audioFile, org.springframework.web.multipart.MultipartFile thumbnailFile) {
        Artist artist = artistRepository.findById(request.getArtistId())
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Artist not found"));

        Album album = null;

        if (request.getAlbumId() != null) {
            album = albumRepository.findById(request.getAlbumId())
                    .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Album not found"));
        }

        String audioUrl = null;
        String thumbnailUrl = null;
        int durationSeconds = request.getDurationSeconds();

        try {
            if (audioFile != null && !audioFile.isEmpty()) {
                audioUrl = mediaService.uploadAudio(audioFile);
                
                // Extract duration using mp3agic
                Path tempFile = Files.createTempFile("song-", audioFile.getOriginalFilename());
                try {
                    audioFile.transferTo(tempFile.toFile());
                    Mp3File mp3file = new Mp3File(tempFile.toFile());
                    durationSeconds = (int) mp3file.getLengthInSeconds();
                } catch (Exception e) {
                    // Log error and fallback to request duration or 0
                    System.err.println("Could not extract duration: " + e.getMessage());
                } finally {
                    Files.deleteIfExists(tempFile);
                }
            } else {
                audioUrl = request.getAudioUrl();
            }

            if (thumbnailFile != null && !thumbnailFile.isEmpty()) {
                thumbnailUrl = mediaService.uploadImage(thumbnailFile);
            } else {
                thumbnailUrl = request.getThumbnailUrl();
            }
        } catch (java.io.IOException e) {
            throw new ResponseStatusException(org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR, "Failed to upload media");
        }

        if (audioUrl == null) {
            throw new ResponseStatusException(org.springframework.http.HttpStatus.BAD_REQUEST, "Audio file or URL is required");
        }

        Song song = new Song();
        song.setTitle(request.getTitle());
        song.setArtist(artist);
        song.setAlbum(album);
        song.setGenre(request.getGenre());
        song.setDurationSeconds(durationSeconds);
        song.setAudioUrl(audioUrl);
        song.setThumbnailUrl(thumbnailUrl);
        song.setPlayCount(0);
        song.setUploadedAt(LocalDateTime.now());

        return songRepository.save(song);
    }
}
