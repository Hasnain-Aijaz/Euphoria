package com.music.euphoria.service;

import com.music.euphoria.entity.Album;
import com.music.euphoria.repository.AlbumRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

import static org.springframework.http.HttpStatus.NOT_FOUND;

@Service
public class AlbumService {
    private final AlbumRepository albumRepository;

    public AlbumService(AlbumRepository albumRepository) {
        this.albumRepository = albumRepository;
    }

    public List<Album> getAllAlbums() {
        return albumRepository.findAll();
    }

    public Album getAlbumById(int id) {
        return albumRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Album not found"));
    }

    public List<Album> searchAlbums(String title) {
        return albumRepository.findByTitleContainingIgnoreCase(title);
    }

    public List<Album> getAlbumsByArtist(int artistId) {
        return albumRepository.findByArtistId(artistId);
    }
}
