package com.music.euphoria.service;

import com.music.euphoria.entity.Album;
import com.music.euphoria.entity.Artist;
import com.music.euphoria.repository.AlbumRepository;
import com.music.euphoria.repository.ArtistRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.util.List;

import static org.springframework.http.HttpStatus.NOT_FOUND;

@Service
public class AlbumService {
    private final AlbumRepository albumRepository;
    private final ArtistRepository artistRepository;
    private final MediaService mediaService;

    public AlbumService(AlbumRepository albumRepository, ArtistRepository artistRepository, MediaService mediaService) {
        this.albumRepository = albumRepository;
        this.artistRepository = artistRepository;
        this.mediaService = mediaService;
    }

    public Album createAlbum(String title, int artistId, MultipartFile coverImage) throws IOException {
        Artist artist = artistRepository.findById(artistId)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Artist not found"));

        String coverUrl = mediaService.uploadImage(coverImage);

        Album album = new Album();
        album.setTitle(title);
        album.setArtist(artist);
        album.setCoverImgUrl(coverUrl);

        return albumRepository.save(album);
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
