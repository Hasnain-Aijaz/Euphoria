package com.music.euphoria.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "albums")
public class Album {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    @JoinColumn(name = "artist_id", nullable = false)
    private Artist artist;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(name = "cover_img_url", length = 255)
    private String coverImgUrl;

    @Column(name = "release_date")
    private LocalDateTime releaseDate;
}
