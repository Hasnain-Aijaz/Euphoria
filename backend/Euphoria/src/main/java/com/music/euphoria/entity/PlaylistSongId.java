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
public class PlaylistSongId implements Serializable {
    @Column(name = "playlist_id")
    private int playlistId;

    @Column(name = "song_id")
    private int songId;
}
