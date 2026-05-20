package com.music.euphoria.controller;

import com.music.euphoria.dto.ListeningHistoryResponse;
import com.music.euphoria.service.ListeningHistoryService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/history")
public class ListeningHistoryController {
    private final ListeningHistoryService listeningHistoryService;

    public ListeningHistoryController(ListeningHistoryService listeningHistoryService) {
        this.listeningHistoryService = listeningHistoryService;
    }

    @PostMapping("/songs/{songId}")
    public ListeningHistoryResponse recordPlay(@PathVariable int songId) {
        return listeningHistoryService.recordPlay(songId);
    }

    @GetMapping("/me")
    public List<ListeningHistoryResponse> getMyHistory() {
        return listeningHistoryService.getMyHistory();
    }
}
