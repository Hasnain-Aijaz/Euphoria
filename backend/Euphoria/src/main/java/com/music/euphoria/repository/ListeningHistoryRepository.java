package com.music.euphoria.repository;

import com.music.euphoria.entity.ListeningHistory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ListeningHistoryRepository extends JpaRepository<ListeningHistory, Integer> {
    List<ListeningHistory> findByUserIdOrderByPlayedAtDesc(int userId);
}
