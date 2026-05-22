import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:euphoria/models/models.dart';
import '../widgets/shared_widgets.dart';
import 'now_playing_screen.dart';
import '../services/api_service.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;
  final Function(Song, {List<Song>? queue}) onPlaySong;
  final Function(Song) onShowNowPlaying;
  final Function(int) onNavigate;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
    required this.onPlaySong,
    required this.onShowNowPlaying,
    required this.onNavigate,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late List<Song> _songs;

  @override
  void initState() {
    super.initState();
    _songs = List.from(widget.playlist.songs);
  }

  Future<void> _removeSong(Song song) async {
    final success = await ApiService.removeSongFromPlaylist(widget.playlist.id, song.id);
    if (success && mounted) {
      setState(() {
        _songs.removeWhere((s) => s.id == song.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed ${song.title} from playlist')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: CustomScrollView(
            slivers: [
              // app bar
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppTheme.black,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF5B2D8E), Color(0xFF1A0040)],
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _songs.isNotEmpty
                                ? GridView.count(
                                    crossAxisCount: 2,
                                    padding: EdgeInsets.zero,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: _songs
                                        .take(4)
                                        .map(
                                          (s) => Container(
                                            color: AppTheme.surfaceGrey,
                                            child: s.thumbnailUrl != null && s.thumbnailUrl!.isNotEmpty
                                                ? CachedNetworkImage(
                                                    fadeInDuration: Duration.zero,
                                                    imageUrl: s.thumbnailUrl!,
                                                    fit: BoxFit.cover,
                                                    errorWidget: (_, __, ___) =>
                                                        const Icon(
                                                          Icons.music_note,
                                                          color: AppTheme.textMuted,
                                                        ),
                                                  )
                                                : const Icon(
                                                    Icons.music_note,
                                                    color: AppTheme.textMuted,
                                                  ),
                                          ),
                                        )
                                        .toList(),
                                  )
                                : Container(
                                    color: AppTheme.surfaceGrey,
                                    child: const Icon(
                                      Icons.queue_music,
                                      color: AppTheme.textMuted,
                                      size: 60,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.playlist.name,
                            style: const TextStyle(
                              color: AppTheme.textWhite,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.playlist.description ?? ''} • ${_songs.length} songs',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.netflixRed,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () {
                              if (_songs.isNotEmpty) {
                                widget.onPlaySong(_songs.first, queue: _songs);
                                widget.onShowNowPlaying(_songs.first);
                              }
                            },
                            icon: const Icon(Icons.play_arrow, size: 22),
                            label: const Text(
                              'Play',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(
                              Icons.favorite_border,
                              color: AppTheme.textMuted,
                            ),
                            onPressed: () {},
                          ),
                          const Spacer(),
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: AppTheme.textMuted,
                            ),
                            color: AppTheme.cardGrey,
                            onSelected: (value) {
                              if (value == 'delete') {
                                _showDeleteConfirmation(context);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, color: AppTheme.netflixRed, size: 20),
                                    SizedBox(width: 12),
                                    Text('Delete Playlist', style: TextStyle(color: AppTheme.netflixRed)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // tracks or empty state
                    if (_songs.isEmpty)
                      _buildEmptyState()
                    else ...[
                      ..._songs.asMap().entries.map(
                            (e) => SongTile(
                              song: e.value,
                              index: e.key,
                              onTap: () {
                                widget.onPlaySong(e.value, queue: _songs);
                                widget.onShowNowPlaying(e.value);
                              },
                              onRemove: () => _removeSong(e.value),
                            ),
                          ),
                      _buildAddMoreButton(),
                    ],

                    const SizedBox(height: 180),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardGrey,
        title: const Text('Delete Playlist', style: TextStyle(color: AppTheme.textWhite)),
        content: Text(
          'Are you sure you want to delete "${widget.playlist.name}"? This action cannot be undone.',
          style: const TextStyle(color: AppTheme.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.netflixRed),
            onPressed: () async {
              final success = await ApiService.deletePlaylist(widget.playlist.id);
              if (mounted) {
                Navigator.pop(ctx); // Close dialog
                if (success) {
                  Navigator.pop(context, true); // Return to library with 'true' to signal refresh
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Playlist "${widget.playlist.name}" deleted')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete playlist')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
        child: Column(
          children: [
            const Icon(
              Icons.music_note,
              color: AppTheme.textMuted,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your playlist is empty',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Find more songs to add to this playlist',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.textWhite,
                foregroundColor: AppTheme.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                widget.onNavigate(1); // Navigate to Search
              },
              child: const Text(
                'Add Songs',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.borderGrey),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          ),
          onPressed: () {
            Navigator.pop(context);
            widget.onNavigate(1); // Navigate to Search
          },
          child: const Text(
            'Add more songs',
            style: TextStyle(color: AppTheme.textWhite),
          ),
        ),
      ),
    );
  }
}

class LikedSongsScreen extends StatelessWidget {
  final List<Song> songs;
  final Function(Song, {List<Song>? queue}) onPlaySong;
  final Function(Song) onShowNowPlaying;
  const LikedSongsScreen({
    super.key,
    required this.songs,
    required this.onPlaySong,
    required this.onShowNowPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppTheme.black,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF5B2D8E), Color(0xFF1A0040)],
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite, color: Colors.white, size: 50),
                          SizedBox(height: 8),
                          Text(
                            'Liked Songs',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            '${songs.length} songs',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...songs.asMap().entries.map(
                          (e) => SongTile(
                            song: e.value,
                            index: e.key,
                            onTap: () {
                              onPlaySong(e.value, queue: songs);
                              onShowNowPlaying(e.value);
                            },
                          ),
                        ),
                    const SizedBox(height: 180),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  final List<Song> songs;
  final Function(Song, {List<Song>? queue}) onPlaySong;
  final Function(Song) onShowNowPlaying;
  const HistoryScreen({
    super.key,
    required this.songs,
    required this.onPlaySong,
    required this.onShowNowPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        title: const Text(
          'Recent History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: ListView(
            children: [
              ...songs.map(
                (s) => SongTile(
                  song: s,
                  onTap: () {
                    onPlaySong(s, queue: songs);
                    onShowNowPlaying(s);
                  },
                ),
              ),
              const SizedBox(height: 180),
            ],
          ),
        ),
      ),
    );
  }
}
