package com.music.euphoria.controller;

import com.music.euphoria.entity.Artist;
import com.music.euphoria.service.ArtistService;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/artists")
public class ArtistController {
    private final ArtistService artistService;

    public ArtistController(ArtistService artistService) {
        this.artistService = artistService;
    }

    @PostMapping(consumes = {"multipart/form-data"})
    public Artist createArtist(
            @RequestParam("name") String name,
            @RequestParam(value = "bio", required = false) String bio,
            @RequestParam("image") MultipartFile image
    ) throws java.io.IOException {
        return artistService.createArtist(name, bio, image);
    }

    @GetMapping
    public List<Artist> getAllArtists() {
        return artistService.getAllArtists();
    }

    @GetMapping("/{id}")
    public Artist getArtistById(@PathVariable int id) {
        return artistService.getArtistById(id);
    }

    @GetMapping("/search")
    public List<Artist> searchArtists(@RequestParam String name) {
        return artistService.searchArtists(name);
    }

    @GetMapping("/top")
    public List<Artist> getTopArtists() {
        return artistService.getTopArtists();
    }
}
