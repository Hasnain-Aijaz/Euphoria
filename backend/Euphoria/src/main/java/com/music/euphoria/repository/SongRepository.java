package com.music.euphoria.repository;

import com.music.euphoria.entity.Song;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SongRepository extends JpaRepository<Song, Integer> {
    List<Song> findByTitleContainingIgnoreCase(String title);

    List<Song> findByGenreIgnoreCase(String genre);

    List<Song> findByArtistId(int artistId);

    List<Song> findByAlbumId(int albumId);
}
