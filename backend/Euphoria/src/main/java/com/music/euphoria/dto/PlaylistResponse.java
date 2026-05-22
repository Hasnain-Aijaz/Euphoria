package com.music.euphoria.dto;

import java.time.LocalDateTime;
import java.util.List;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PlaylistResponse {
    private int id;
    private int userId;
    private String username;
    private String playlistName;
    private String description;
    private LocalDateTime createdAt;
    private List<SongSummaryResponse> songs;
}
