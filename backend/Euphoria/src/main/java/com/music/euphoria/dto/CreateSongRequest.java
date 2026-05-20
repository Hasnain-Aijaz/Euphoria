package com.music.euphoria.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CreateSongRequest {
    @NotBlank(message = "Title is required")
    private String title;

    @NotNull(message = "Artist id is required")
    private Integer artistId;

    private Integer albumId;

    private String genre;

    @NotNull(message = "Duration is required")
    @Min(value = 1, message = "Duration must be greater than 0")
    private Integer durationSeconds;

    @NotBlank(message = "Audio URL is required")
    private String audioUrl;

    private String thumbnailUrl;
}
