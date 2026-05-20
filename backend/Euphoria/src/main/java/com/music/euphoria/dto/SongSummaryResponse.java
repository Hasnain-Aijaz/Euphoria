package com.music.euphoria.dto;

import java.time.LocalDateTime;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class SongSummaryResponse {
    private int id;
    private String title;
    private String artistName;
    private Integer albumId;
    private String albumTitle;
    private String genre;
    private int durationSeconds;
    private String audioUrl;
    private String thumbnailUrl;
    private int playCount;
    private LocalDateTime uploadedAt;
}
