package com.music.euphoria.service;

import com.music.euphoria.entity.Artist;
import com.music.euphoria.repository.ArtistRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

import static org.springframework.http.HttpStatus.NOT_FOUND;

@Service
public class ArtistService {
    private final ArtistRepository artistRepository;

    public ArtistService(ArtistRepository artistRepository) {
        this.artistRepository = artistRepository;
    }

    public List<Artist> getAllArtists() {
        return artistRepository.findAll();
    }

    public Artist getArtistById(int id) {
        return artistRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Artist not found"));
    }

    public List<Artist> searchArtists(String name) {
        return artistRepository.findByNameContainingIgnoreCase(name);
    }
}
