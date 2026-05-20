package com.music.euphoria.dto;

import java.time.LocalDateTime;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ListeningHistoryResponse {
    private int id;
    private SongSummaryResponse song;
    private LocalDateTime playedAt;
}
