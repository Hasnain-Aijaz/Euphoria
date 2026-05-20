package com.music.euphoria.dto;

import java.time.LocalDateTime;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class LikedSongResponse {
    private SongSummaryResponse song;
    private LocalDateTime likedAt;
}
