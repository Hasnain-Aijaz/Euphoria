package com.music.euphoria.service;

import com.music.euphoria.entity.Artist;
import com.music.euphoria.repository.ArtistRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.util.List;

@Service
public class ArtistService {
    private final ArtistRepository artistRepository;
    private final MediaService mediaService;

    public ArtistService(ArtistRepository artistRepository, MediaService mediaService) {
        this.artistRepository = artistRepository;
        this.mediaService = mediaService;
    }

    public Artist createArtist(String name, String bio, MultipartFile image) throws IOException {
        String imgUrl = mediaService.uploadImage(image);
        Artist artist = new Artist();
        artist.setName(name);
        artist.setBio(bio);
        artist.setImgUrl(imgUrl);
        return artistRepository.save(artist);
    }

    public List<Artist> getAllArtists() {
        return artistRepository.findAll();
    }

    public Artist getArtistById(int id) {
        return artistRepository.findById(id).orElse(null);
    }

    public List<Artist> searchArtists(String name) {
        return artistRepository.findByNameContainingIgnoreCase(name);
    }

    public List<Artist> getTopArtists() {
        return artistRepository.findTopArtists();
    }
}
