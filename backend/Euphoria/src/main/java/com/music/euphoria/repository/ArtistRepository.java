package com.music.euphoria.repository;

import com.music.euphoria.entity.Artist;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface ArtistRepository extends JpaRepository<Artist, Integer> {
    List<Artist> findByNameContainingIgnoreCase(String name);

    @Query("SELECT a FROM Artist a JOIN Song s ON s.artist.id = a.id GROUP BY a.id, a.name, a.bio, a.imgUrl ORDER BY SUM(s.playCount) DESC")
    List<Artist> findTopArtists();
}
