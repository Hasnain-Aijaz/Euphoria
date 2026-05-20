package com.music.euphoria.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "liked_songs")
public class LikedSong {
    @EmbeddedId
    private LikedSongId id;

    @ManyToOne
    @MapsId("userId")
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne
    @MapsId("songId")
    @JoinColumn(name = "song_id", nullable = false)
    private Song song;

    @Column(name = "liked_at")
    private LocalDateTime likedAt;
}
