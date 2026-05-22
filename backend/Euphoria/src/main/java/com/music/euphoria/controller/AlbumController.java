package com.music.euphoria.controller;

import com.music.euphoria.entity.Album;
import com.music.euphoria.service.AlbumService;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/albums")
public class AlbumController {
    private final AlbumService albumService;

    public AlbumController(AlbumService albumService) {
        this.albumService = albumService;
    }

    @PostMapping(consumes = {"multipart/form-data"})
    public Album createAlbum(
            @RequestParam("title") String title,
            @RequestParam("artistId") int artistId,
            @RequestParam("cover") MultipartFile cover
    ) throws IOException {
        return albumService.createAlbum(title, artistId, cover);
    }

    @GetMapping
    public List<Album> getAllAlbums() {
        return albumService.getAllAlbums();
    }

    @GetMapping("/{id}")
    public Album getAlbumById(@PathVariable int id) {
        return albumService.getAlbumById(id);
    }

    @GetMapping("/search")
    public List<Album> searchAlbums(@RequestParam String title) {
        return albumService.searchAlbums(title);
    }

    @GetMapping("/artist/{artistId}")
    public List<Album> getAlbumsByArtist(@PathVariable int artistId) {
        return albumService.getAlbumsByArtist(artistId);
    }
}
