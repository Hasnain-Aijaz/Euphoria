import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlaylistSelectionSheet extends StatefulWidget {
  final Song song;

  const PlaylistSelectionSheet({super.key, required this.song});

  @override
  State<PlaylistSelectionSheet> createState() => _PlaylistSelectionSheetState();
}

class _PlaylistSelectionSheetState extends State<PlaylistSelectionSheet> {
  List<Playlist> _playlists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final playlists = await ApiService.fetchMyPlaylists();
    if (mounted) {
      setState(() {
        _playlists = playlists;
        _isLoading = false;
      });
    }
  }

  Future<void> _addToPlaylist(Playlist playlist) async {
    final success = await ApiService.addSongToPlaylist(playlist.id, widget.song.id);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
              ? 'Added to ${playlist.name}' 
              : 'Failed to add to playlist',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: success ? Colors.green : AppTheme.netflixRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: AppTheme.cardGrey,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Add to Playlist',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(color: AppTheme.netflixRed),
              ),
            )
          else if (_playlists.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text(
                  'No playlists found',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _playlists.length,
                itemBuilder: (context, index) {
                  final playlist = _playlists[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: AppTheme.surfaceGrey,
                        child: playlist.songs.isNotEmpty && playlist.songs.first.thumbnailUrl != null
                            ? CachedNetworkImage(
                                imageUrl: playlist.songs.first.thumbnailUrl!,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.queue_music, color: AppTheme.textMuted),
                      ),
                    ),
                    title: Text(
                      playlist.name,
                      style: const TextStyle(color: AppTheme.textWhite),
                    ),
                    subtitle: Text(
                      '${playlist.songs.length} songs',
                      style: const TextStyle(color: AppTheme.textMuted),
                    ),
                    onTap: () => _addToPlaylist(playlist),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

void showPlaylistSelectionSheet(BuildContext context, Song song) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => PlaylistSelectionSheet(song: song),
  );
}
