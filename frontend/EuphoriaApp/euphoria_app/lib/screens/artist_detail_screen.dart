import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:euphoria/models/models.dart';
import '../services/api_service.dart';
import '../widgets/shared_widgets.dart';
import 'now_playing_screen.dart';
import 'album_detail_screen.dart';

class ArtistDetailScreen extends StatefulWidget {
  final Artist artist;
  final Function(Song, {List<Song>? queue}) onPlaySong;
  final Function(Song) onShowNowPlaying;

  const ArtistDetailScreen({
    super.key,
    required this.artist,
    required this.onPlaySong,
    required this.onShowNowPlaying,
  });

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  bool _isFollowing = false;
  List<Song> _songs = [];
  List<Album> _albums = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArtistData();
  }

  Future<void> _loadArtistData() async {
    try {
      final results = await Future.wait([
        ApiService.fetchSongsByArtist(widget.artist.id),
        ApiService.fetchAlbumsByArtist(widget.artist.id),
      ]);
      if (mounted) {
        setState(() {
          _songs = results[0] as List<Song>;
          _albums = results[1] as List<Album>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final artist = widget.artist;

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: CustomScrollView(
            slivers: [
              // hero header
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppTheme.black,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppTheme.black,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'artist_${artist.id}',
                          child: artist.imgUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  fadeInDuration: const Duration(milliseconds: 200),
                                  imageUrl: artist.imgUrl,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                  errorWidget: (_, __, ___) => Container(color: AppTheme.surfaceGrey),
                                )
                              : Container(color: AppTheme.surfaceGrey),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black26,
                                Colors.transparent,
                                Colors.transparent,
                                AppTheme.black
                              ],
                              stops: [0.0, 0.2, 0.6, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 24,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                artist.name,
                                style: const TextStyle(
                                  color: AppTheme.textWhite,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 20.0,
                                      color: Colors.black,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // action row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _isFollowing
                                    ? AppTheme.netflixRed
                                    : AppTheme.textWhite,
                                side: BorderSide(
                                  color: _isFollowing
                                      ? AppTheme.netflixRed
                                      : AppTheme.borderGrey,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () =>
                                  setState(() => _isFollowing = !_isFollowing),
                              child: Text(_isFollowing ? 'Following' : 'Follow'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.netflixRed,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                            ),
                            onPressed: () {
                              if (_songs.isNotEmpty) {
                                widget.onPlaySong(_songs.first, queue: _songs);
                                widget.onShowNowPlaying(_songs.first);
                              }
                            },
                            icon: const Icon(Icons.play_arrow, size: 18),
                            label: const Text('Play All'),
                          ),
                        ],
                      ),
                    ),

                    // bio
                    if (artist.bio.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Text(
                          artist.bio,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // popular songs
                    if (_isLoading)
                      const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppTheme.netflixRed)))
                    else ...[
                      if (_songs.isNotEmpty) ...[
                        SectionHeader(title: 'Popular Songs'),
                        ..._songs.asMap().entries.map(
                              (e) => SongTile(
                                song: e.value,
                                index: e.key,
                                showPlayCount: true,
                                onTap: () {
                                  widget.onPlaySong(e.value, queue: _songs);
                                  widget.onShowNowPlaying(e.value);
                                },
                              ),
                            ),
                      ],

                      // albums
                      if (_albums.isNotEmpty) ...[
                        SectionHeader(title: 'Albums'),
                        SizedBox(
                          height: 180,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _albums.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, i) => AlbumCard(
                              album: _albums[i],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AlbumDetailScreen(
                                    album: _albums[i],
                                    onPlaySong: widget.onPlaySong,
                                    onShowNowPlaying: widget.onShowNowPlaying,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
