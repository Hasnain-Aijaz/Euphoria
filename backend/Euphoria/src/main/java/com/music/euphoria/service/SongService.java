package com.music.euphoria.service;

import com.music.euphoria.dto.CreateSongRequest;
import com.music.euphoria.entity.Album;
import com.music.euphoria.entity.Artist;
import com.music.euphoria.entity.Song;
import com.music.euphoria.repository.AlbumRepository;
import com.music.euphoria.repository.ArtistRepository;
import com.music.euphoria.repository.SongRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;

import static org.springframework.http.HttpStatus.NOT_FOUND;

@Service
public class SongService {
    private final SongRepository songRepository;
    private final ArtistRepository artistRepository;
    private final AlbumRepository albumRepository;
    private final ListeningHistoryService listeningHistoryService;

    public SongService(
            SongRepository songRepository,
            ArtistRepository artistRepository,
            AlbumRepository albumRepository,
            ListeningHistoryService listeningHistoryService
    ) {
        this.songRepository = songRepository;
        this.artistRepository = artistRepository;
        this.albumRepository = albumRepository;
        this.listeningHistoryService = listeningHistoryService;
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

    public Song createSong(CreateSongRequest request) {
        Artist artist = artistRepository.findById(request.getArtistId())
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Artist not found"));

        Album album = null;

        if (request.getAlbumId() != null) {
            album = albumRepository.findById(request.getAlbumId())
                    .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Album not found"));
        }

        Song song = new Song();
        song.setTitle(request.getTitle());
        song.setArtist(artist);
        song.setAlbum(album);
        song.setGenre(request.getGenre());
        song.setDurationSeconds(request.getDurationSeconds());
        song.setAudioUrl(request.getAudioUrl());
        song.setThumbnailUrl(request.getThumbnailUrl());
        song.setPlayCount(0);
        song.setUploadedAt(LocalDateTime.now());

        return songRepository.save(song);
    }
}
