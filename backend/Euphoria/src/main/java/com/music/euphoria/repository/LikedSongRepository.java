package com.music.euphoria.repository;

import com.music.euphoria.entity.LikedSong;
import com.music.euphoria.entity.LikedSongId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LikedSongRepository extends JpaRepository<LikedSong, LikedSongId> {
    List<LikedSong> findByUserId(int userId);

    boolean existsByUserIdAndSongId(int userId, int songId);

    void deleteByUserIdAndSongId(int userId, int songId);
}
