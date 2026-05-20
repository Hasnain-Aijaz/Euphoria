package com.music.euphoria.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.io.Serializable;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
@Embeddable
public class LikedSongId implements Serializable {
    @Column(name = "user_id")
    private int userId;

    @Column(name = "song_id")
    private int songId;
}
