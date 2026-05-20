package com.music.euphoria.controller;

import com.music.euphoria.entity.Artist;
import com.music.euphoria.service.ArtistService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/artists")
public class ArtistController {
    private final ArtistService artistService;

    public ArtistController(ArtistService artistService) {
        this.artistService = artistService;
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
}
