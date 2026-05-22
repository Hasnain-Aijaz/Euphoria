import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:euphoria/models/models.dart';
import '../services/api_service.dart';
import '../widgets/shared_widgets.dart';
import 'now_playing_screen.dart';
import 'artist_detail_screen.dart';

class AlbumDetailScreen extends StatefulWidget {
  final Album album;
  final Function(Song, {List<Song>? queue}) onPlaySong;
  final Function(Song) onShowNowPlaying;

  const AlbumDetailScreen({
    super.key,
    required this.album,
    required this.onPlaySong,
    required this.onShowNowPlaying,
  });

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final songs = await ApiService.fetchSongsByAlbum(widget.album.id);
    if (mounted) {
      setState(() {
        _songs = songs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final album = widget.album;
    final artist = album.artist;
    final totalDuration = _songs.fold(0, (sum, s) => sum + s.durationSeconds);
    final totalMin = totalDuration ~/ 60;

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: CustomScrollView(
        slivers: [
          // hero
          SliverAppBar(
            expandedHeight: 300,
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
                  // Blurred bg
                  Opacity(
                    opacity: 0.3,
                    child: album.coverImgUrl.isNotEmpty 
                      ? CachedNetworkImage(
                          fadeInDuration: Duration.zero,
                          imageUrl: album.coverImgUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(color: AppTheme.surfaceGrey),
                        )
                      : Container(color: AppTheme.surfaceGrey),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppTheme.black],
                        stops: [0.3, 1.0],
                      ),
                    ),
                  ),
                  // Album art centered
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Hero(
                        tag: 'album_${album.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 170,
                            height: 170,
                            child: album.coverImgUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  fadeInDuration: Duration.zero,
                                  imageUrl: album.coverImgUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    color: AppTheme.surfaceGrey,
                                    child: const Icon(Icons.album, color: AppTheme.textMuted, size: 60),
                                  ),
                                )
                              : Container(
                                  color: AppTheme.surfaceGrey,
                                  child: const Icon(Icons.album, color: AppTheme.textMuted, size: 60),
                                ),
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
                // album info
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album.title,
                        style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
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
                        child: Text(
                          artist.name,
                          style: const TextStyle(
                            color: AppTheme.netflixRed,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Album • ${_songs.length} songs • ${totalMin}m',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // action buttons
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
                            vertical: 10,
                          ),
                        ),
                        onPressed: () {
                          if (_songs.isNotEmpty) {
                            widget.onPlaySong(_songs.first, queue: _songs);
                            widget.onShowNowPlaying(_songs.first);
                          }
                        },
                        icon: const Icon(Icons.play_arrow, size: 20),
                        label: const Text(
                          'Play',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textWhite,
                          side: const BorderSide(color: AppTheme.borderGrey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Not implemented yet!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shuffle, size: 18),
                        label: const Text('Shuffle'),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.favorite_border,
                          color: AppTheme.textMuted,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // song list
                if (_isLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppTheme.netflixRed)))
                else if (_songs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No songs in this album yet.',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ),
                  )
                else
                  ..._songs.asMap().entries.map(
                        (e) => SongTile(
                          song: e.value,
                          index: e.key,
                          onTap: () {
                            widget.onPlaySong(e.value, queue: _songs);
                            widget.onShowNowPlaying(e.value);
                          },
                        ),
                      ),

                const SizedBox(height: 180),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
