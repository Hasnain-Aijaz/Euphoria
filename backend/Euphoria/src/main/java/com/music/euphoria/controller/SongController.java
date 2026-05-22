package com.music.euphoria.controller;

import com.music.euphoria.dto.CreateSongRequest;
import com.music.euphoria.entity.Song;
import com.music.euphoria.service.SongService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/songs")
public class SongController {
    private final SongService songService;

    public SongController(SongService songService) {
        this.songService = songService;
    }

    @GetMapping
    public List<Song> getAllSongs() {
        return songService.getAllSongs();
    }

    @PostMapping(consumes = {"multipart/form-data"})
    public Song createSong(
            @Valid @RequestPart("song") CreateSongRequest request,
            @RequestPart(value = "audio", required = false) org.springframework.web.multipart.MultipartFile audioFile,
            @RequestPart(value = "thumbnail", required = false) org.springframework.web.multipart.MultipartFile thumbnailFile
    ) {
        return songService.createSong(request, audioFile, thumbnailFile);
    }

    @GetMapping("/{id}")
    public Song getSongById(@PathVariable int id) {
        return songService.getSongById(id);
    }

    @GetMapping("/genre/{genre}")
    public List<Song> getSongsByGenre(@PathVariable String genre) {
        return songService.getSongsByGenre(genre);
    }
    @GetMapping("/artist/{artistId}")
    public List<Song> getSongsByArtistId(@PathVariable int artistId) {
        return songService.getSongsByArtist(artistId);
    }

    @GetMapping("/album/{albumId}")
    public List<Song> getSongsByAlbum(@PathVariable int albumId) {
        return songService.getSongsByAlbum(albumId);
    }

    @PostMapping("/{id}/play")
    public Song incrementPlayCount(@PathVariable int id) {
        Song playCount = songService.incrementPlayCount(id);
        return playCount;
    }

    @GetMapping("/search")
    public List<Song> searchSongs(@RequestParam String title) {
        return songService.searchSongs(title);
    }


}
