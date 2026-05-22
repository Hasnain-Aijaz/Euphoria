import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:euphoria/models/models.dart';
import '../services/api_service.dart';
import '../widgets/shared_widgets.dart';
import 'now_playing_screen.dart';
import 'playlist_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  final Function(int) onNavigate;
  final Function(Song, {List<Song>? queue}) onPlaySong;
  final Function(Song) onShowNowPlaying;
  const LibraryScreen({
    super.key,
    required this.onNavigate,
    required this.onPlaySong,
    required this.onShowNowPlaying,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<_PlaylistsTabState> _playlistsKey = GlobalKey<_PlaylistsTabState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        backgroundColor: AppTheme.black,
        title: const Text(
          'My Library',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.textWhite, size: 28),
            onPressed: () => _showCreatePlaylistDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.netflixRed,
          indicatorWeight: 2,
          labelColor: AppTheme.netflixRed,
          unselectedLabelColor: AppTheme.textMuted,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Playlists'),
            Tab(text: 'Liked'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PlaylistsTab(
            key: _playlistsKey,
            onNavigate: widget.onNavigate,
            onPlaySong: widget.onPlaySong,
            onShowNowPlaying: widget.onShowNowPlaying,
          ),
          _LikedTab(onPlaySong: widget.onPlaySong, onShowNowPlaying: widget.onShowNowPlaying),
          _HistoryTab(onPlaySong: widget.onPlaySong, onShowNowPlaying: widget.onShowNowPlaying),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardGrey,
        title: const Text(
          'Create Playlist',
          style: TextStyle(color: AppTheme.textWhite),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textWhite),
          decoration: InputDecoration(
            hintText: 'Playlist name',
            hintStyle: const TextStyle(color: AppTheme.textMuted),
            filled: true,
            fillColor: AppTheme.surfaceGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.netflixRed,
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final success = await ApiService.createPlaylist(name: name);
                if (success) {
                  _playlistsKey.currentState?._loadPlaylists();
                  if (context.mounted) Navigator.pop(ctx);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to create playlist')),
                    );
                  }
                }
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// playlist tab
class _PlaylistsTab extends StatefulWidget {
  final Function(int) onNavigate;
  final Function(Song, {List<Song>? queue}) onPlaySong;
  final Function(Song) onShowNowPlaying;
  const _PlaylistsTab({
    super.key,
    required this.onNavigate,
    required this.onPlaySong,
    required this.onShowNowPlaying,
  });

  @override
  State<_PlaylistsTab> createState() => _PlaylistsTabState();
}

class _PlaylistsTabState extends State<_PlaylistsTab> {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.netflixRed));

    return ListView(
      children: [
        _SpecialLibraryCard(
          icon: Icons.favorite,
          title: 'Liked Songs',
          subtitle: 'Your favorite tracks',
          gradient: const LinearGradient(colors: [Color(0xFF5B2D8E), Color(0xFF1A0040)]),
          onTap: () {},
        ),
        _SpecialLibraryCard(
          icon: Icons.history,
          title: 'Recently Played',
          subtitle: 'Tracks you played recently',
          gradient: const LinearGradient(colors: [Color(0xFF8B0000), Color(0xFF1A0040)]),
          onTap: () {},
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Your Playlists',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1),
          ),
        ),
        if (_playlists.isEmpty)
          const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No playlists yet', style: TextStyle(color: AppTheme.textMuted))))
        else
          ..._playlists.map((pl) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 50,
                height: 50,
                color: AppTheme.surfaceGrey,
                child: pl.songs.isNotEmpty && pl.songs.first.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: pl.songs.first.thumbnailUrl!,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.queue_music, color: AppTheme.textMuted),
              ),
            ),
            title: Text(
              pl.name,
              style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${pl.songs.length} songs',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
            onTap: () async {
              final result = await Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => PlaylistDetailScreen(
                    playlist: pl, 
                    onPlaySong: widget.onPlaySong, 
                    onShowNowPlaying: widget.onShowNowPlaying,
                    onNavigate: widget.onNavigate,
                  ),
                ),
              );
              
              if (result == true && mounted) {
                _loadPlaylists();
              }
            },
          )),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _SpecialLibraryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  const _SpecialLibraryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        height: 72,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.textWhite, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(subtitle, style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_fill, color: Colors.white, size: 36),
            ],
          ),
        ),
      ),
    );
  }
}

class _LikedTab extends StatefulWidget {
  final Function(Song, {List<Song>? queue}) onPlaySong;
  final Function(Song) onShowNowPlaying;
  const _LikedTab({required this.onPlaySong, required this.onShowNowPlaying});

  @override
  State<_LikedTab> createState() => _LikedTabState();
}

class _LikedTabState extends State<_LikedTab> {
  List<Song> _likedSongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLikedSongs();
  }

  Future<void> _loadLikedSongs() async {
    final songs = await ApiService.fetchLikedSongs();
    if (mounted) {
      setState(() {
        _likedSongs = songs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.netflixRed));

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          height: 90,
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF5B2D8E), Color(0xFF1A0040)]), borderRadius: BorderRadius.circular(12)),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, color: Colors.white, size: 32),
                SizedBox(height: 4),
                Text('Liked Songs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
        ),
        Expanded(
          child: _likedSongs.isEmpty 
            ? const Center(child: Text('No liked songs yet', style: TextStyle(color: AppTheme.textMuted)))
            : ListView.builder(
                itemCount: _likedSongs.length,
                itemBuilder: (context, i) => SongTile(
                  song: _likedSongs[i],
                  index: i,
                  onTap: () {
                    widget.onPlaySong(_likedSongs[i], queue: _likedSongs);
                    widget.onShowNowPlaying(_likedSongs[i]);
                  },
                ),
              ),
        ),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final Function(Song, {List<Song>? queue}) onPlaySong;
  final Function(Song) onShowNowPlaying;
  const _HistoryTab({required this.onPlaySong, required this.onShowNowPlaying});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Listening history is coming soon!', style: TextStyle(color: AppTheme.textMuted)));
  }
}
