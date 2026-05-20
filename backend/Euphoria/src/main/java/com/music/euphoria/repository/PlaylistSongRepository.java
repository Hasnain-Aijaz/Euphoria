package com.music.euphoria.repository;

import com.music.euphoria.entity.PlaylistSong;
import com.music.euphoria.entity.PlaylistSongId;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PlaylistSongRepository extends JpaRepository<PlaylistSong, PlaylistSongId> {
    boolean existsByPlaylistIdAndSongId(int playlistId, int songId);

    void deleteByPlaylistIdAndSongId(int playlistId, int songId);
}
