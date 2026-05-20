package com.music.euphoria.repository;

import com.music.euphoria.entity.Album;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AlbumRepository extends JpaRepository<Album, Integer> {
    List<Album> findByTitleContainingIgnoreCase(String title);

    List<Album> findByArtistId(int artistId);
}
