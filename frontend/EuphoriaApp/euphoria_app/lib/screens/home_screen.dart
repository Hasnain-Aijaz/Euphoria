import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import 'package:euphoria/models/models.dart';
import '../services/api_service.dart';
import '../widgets/shared_widgets.dart';
import 'album_detail_screen.dart';
import 'artist_detail_screen.dart';
import 'now_playing_screen.dart';
import 'playlist_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;
  final Function(Song, {List<Song>? queue}) onPlaySong;
  final Function(Song) onShowNowPlaying;

  const HomeScreen({
    super.key,
    required this.onNavigate,
    required this.onPlaySong,
    required this.onShowNowPlaying,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedGenre = 'All';
  final List<String> _genres = ['All', 'Pop', 'Rock', 'Dance', 'R&B', 'Jazz', 'Lo-Fi'];
  
  List<Artist> _artists = [];
  List<Album> _albums = [];
  List<Song> _songs = [];
  User? _currentUser;
  bool _isLoading = true;
  Song? _featuredSong;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiService.fetchArtists(),
        ApiService.fetchAlbums(),
        ApiService.fetchSongs(),
        ApiService.getMe(),
      ]);

      if (mounted) {
        setState(() {
          _artists = results[0] as List<Artist>;
          _albums = results[1] as List<Album>;
          _songs = results[2] as List<Song>;
          _currentUser = results[3] as User?;
          
          if (_songs.isNotEmpty) {
            final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
            _featuredSong = _songs[dayOfYear % _songs.length];
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Not implemented yet!')),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.netflixRed));
    }

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // app bar
          SliverAppBar(
            floating: true,
            pinned: false,
            backgroundColor: AppTheme.black,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.netflixRed.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/euphoria_logo1.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'E U P H O R I A',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: AppTheme.textWhite, size: 26),
                onPressed: () => _showNotImplemented(context),
              ),
              GestureDetector(
                onTap: () => widget.onNavigate(3),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: AppTheme.netflixRed,
                    child: Text(
                      (_currentUser?.username ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getGreeting(), style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFE50914), Color(0xFF8B0000), Color(0xFF1A0040)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          _currentUser?.username ?? 'Listener',
                          style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _genres.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final genre = _genres[i];
                      return GenreChip(
                        label: genre,
                        selected: _selectedGenre == genre,
                        onTap: () => setState(() => _selectedGenre = genre),
                      );
                    },
                  ),
                ),

                if (_featuredSong != null) ...[
                  const SizedBox(height: 24),
                  _FeaturedBanner(
                    song: _featuredSong!,
                    onTap: () {
                      widget.onPlaySong(_featuredSong!, queue: _songs);
                      widget.onShowNowPlaying(_featuredSong!);
                    },
                  ),
                ],

                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _QuickChip(icon: Icons.favorite, label: 'Liked Songs', onTap: () => widget.onNavigate(2)),
                      _QuickChip(icon: Icons.history, label: 'Recent', onTap: () => widget.onNavigate(2)),
                      _QuickChip(icon: Icons.playlist_play, label: 'Playlists', onTap: () => widget.onNavigate(2)),
                    ],
                  ),
                ),

                if (_albums.isNotEmpty) ...[
                  SectionHeader(title: 'Trending Now', onSeeAll: () {}),
                  SizedBox(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _albums.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, i) {
                        final album = _albums[i];
                        return AlbumCard(
                          album: album,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AlbumDetailScreen(
                                album: album,
                                onPlaySong: widget.onPlaySong,
                                onShowNowPlaying: widget.onShowNowPlaying,
                              ),
                            ),
                          ),
                          );
                          },
                          ),
                          ),
                          ],

                          if (_artists.isNotEmpty) ...[
                          SectionHeader(title: 'Top Artists', onSeeAll: () {}),
                          SizedBox(
                          height: 200,
                          child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _artists.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 20),
                          itemBuilder: (context, i) {
                          final artist = _artists[i];
                          return ArtistCard(
                          artist: artist,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ArtistDetailScreen(
                                artist: artist,
                                onPlaySong: widget.onPlaySong,
                                onShowNowPlaying: widget.onShowNowPlaying,
                              ),
                            ),
                          ),
                          );
                          },
                          ),
                          ),
                          ],

                          if (_songs.isNotEmpty) ...[
                          SectionHeader(title: 'Recently Added'),
                          ..._songs.take(5).map(
                          (song) => SongTile(
                          song: song,
                          onTap: () {
                          widget.onPlaySong(song, queue: _songs);
                          widget.onShowNowPlaying(song);
                          },
                          ),
                          ),
                          ],
                const SizedBox(height: 180),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedBanner extends StatefulWidget {
  final Song song;
  final VoidCallback onTap;
  const _FeaturedBanner({required this.song, required this.onTap});

  @override
  State<_FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<_FeaturedBanner> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.zero,
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            boxShadow: _isHovered ? [BoxShadow(color: const Color(0xFF8B0000).withOpacity(0.3), blurRadius: 20, spreadRadius: 2)] : [],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isHovered ? [const Color(0xFFA50000), const Color(0xFF2A0050)] : [const Color(0xFF8B0000), const Color(0xFF1A0040)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isHovered ? 240 : 200,
                  child: Opacity(
                    opacity: _isHovered ? 0.7 : 0.5,
                    child: widget.song.thumbnailUrl != null ? CachedNetworkImage(imageUrl: widget.song.thumbnailUrl!, fit: BoxFit.cover) : const SizedBox(),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF8B0000), Colors.transparent], 
                      stops: [0.3, 0.8]
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppTheme.netflixRed, borderRadius: BorderRadius.circular(4)),
                      child: const Text('FEATURED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                    const SizedBox(height: 10),
                    Text(widget.song.title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(widget.song.artistName, style: const TextStyle(color: AppTheme.textLight, fontSize: 14)),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: widget.onTap,
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Play Now'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.netflixRed, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                    ),
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

class _QuickChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickChip({required this.icon, required this.label, this.onTap});

  @override
  State<_QuickChip> createState() => _QuickChipState();
}

class _QuickChipState extends State<_QuickChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withOpacity(0.1) : AppTheme.surfaceGrey,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _isHovered ? Colors.white.withOpacity(0.3) : AppTheme.borderGrey),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: AppTheme.netflixRed),
              const SizedBox(width: 6),
              Text(widget.label, style: TextStyle(color: _isHovered ? AppTheme.textWhite : AppTheme.textLight, fontSize: 12, fontWeight: _isHovered ? FontWeight.bold : FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
