package com.music.euphoria.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CreatePlaylistRequest {
    @NotBlank(message = "Playlist name is required")
    @Size(max = 100, message = "Playlist name must be 100 characters or less")
    private String playlistName;

    @Size(max = 255, message = "Description must be 255 characters or less")
    private String description;
}
