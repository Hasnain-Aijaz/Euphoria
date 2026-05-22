import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:euphoria/models/models.dart';
import '../services/api_service.dart';
import '../widgets/shared_widgets.dart';
import 'now_playing_screen.dart';
import 'artist_detail_screen.dart';
import 'album_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final Function(Song, {List<Song>? queue}) onPlaySong;
  final Function(Song) onShowNowPlaying;
  const SearchScreen({super.key, required this.onPlaySong, required this.onShowNowPlaying});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  String _selectedGenre = 'All';
  
  List<Song> _songs = [];
  List<Artist> _artists = [];
  List<Album> _albums = [];
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _query = query;
        if (_query.isNotEmpty) {
          _performSearch();
        } else {
          _songs = [];
          _artists = [];
          _albums = [];
        }
      });
    });
  }

  Future<void> _performSearch() async {
    setState(() => _isSearching = true);
    try {
      final results = await Future.wait([
        ApiService.searchSongs(_query),
        ApiService.searchArtists(_query),
        ApiService.searchAlbums(_query),
      ]);
      if (mounted) {
        setState(() {
          _songs = results[0] as List<Song>;
          _artists = results[1] as List<Artist>;
          _albums = results[2] as List<Album>;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _fetchSongsByGenre(String genre) async {
    setState(() {
      _selectedGenre = genre;
      _isLoading = true;
      _query = '';
      _controller.clear();
    });
    try {
      final songs = await ApiService.fetchSongsByGenre(genre);
      if (mounted) {
        setState(() {
          _songs = songs;
          _artists = [];
          _albums = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  static const List<String> _genres = [
    'All',
    'Pop',
    'Hip-Hop',
    'R&B',
    'Rock',
    'Jazz',
    'Electronic',
    'Country',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        backgroundColor: AppTheme.black,
        title: const Text(
          'Search',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _controller,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: AppTheme.textWhite),
                  decoration: InputDecoration(
                    hintText: 'Songs, artists, albums...',
                    hintStyle: const TextStyle(color: AppTheme.textMuted),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                    suffixIcon: _controller.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () => setState(() {
                              _query = '';
                              _controller.clear();
                              _songs = [];
                              _artists = [];
                              _albums = [];
                            }),
                            child: const Icon(
                              Icons.close,
                              color: AppTheme.textMuted,
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.surfaceGrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // genre chips
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _genres.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => GenreChip(
                    label: _genres[i],
                    selected: _selectedGenre == _genres[i],
                    onTap: () {
                      if (_genres[i] == 'All') {
                        setState(() {
                          _selectedGenre = 'All';
                          _songs = [];
                          _isLoading = false;
                        });
                      } else {
                        _fetchSongsByGenre(_genres[i]);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // results
              Expanded(
                child: _isLoading || _isSearching
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.netflixRed))
                  : _query.isEmpty && _selectedGenre == 'All'
                    ? _buildBrowseView()
                    : _buildResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrowseView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Browse Categories',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _CategoryTile(label: 'Pop', color: const Color(0xFF1DB954), onTap: () => _fetchSongsByGenre('Pop')),
              _CategoryTile(label: 'Hip-Hop', color: const Color(0xFF8B5CF6), onTap: () => _fetchSongsByGenre('Hip-Hop')),
              _CategoryTile(label: 'R&B', color: const Color(0xFFEC4899), onTap: () => _fetchSongsByGenre('R&B')),
              _CategoryTile(label: 'Rock', color: const Color(0xFFF59E0B), onTap: () => _fetchSongsByGenre('Rock')),
              _CategoryTile(label: 'Jazz', color: const Color(0xFF06B6D4), onTap: () => _fetchSongsByGenre('Jazz')),
              _CategoryTile(
                label: 'Electronic',
                color: const Color(0xFF10B981),
                onTap: () => _fetchSongsByGenre('Electronic'),
              ),
              _CategoryTile(label: 'Country', color: const Color(0xFFEF4444), onTap: () => _fetchSongsByGenre('Country')),
              _CategoryTile(label: 'Classical', color: const Color(0xFF3B82F6), onTap: () => _fetchSongsByGenre('Classical')),
            ],
          ),
          const SizedBox(height: 180),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView(
      children: [
        if (_artists.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Artists',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ..._artists.map(
            (a) => ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: Hero(
                tag: 'artist_${a.id}',
                child: ClipOval(
                  child: Container(
                    width: 50,
                    height: 50,
                    color: AppTheme.surfaceGrey,
                    child: a.imgUrl.isNotEmpty
                      ? CachedNetworkImage(
                          fadeInDuration: Duration.zero,
                          imageUrl: a.imgUrl,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.person, color: AppTheme.textMuted),
                        )
                      : const Icon(Icons.person, color: AppTheme.textMuted),
                  ),
                ),
              ),
              title: Text(
                a.name,
                style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Artist',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppTheme.textMuted,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArtistDetailScreen(
                    artist: a,
                    onPlaySong: widget.onPlaySong,
                    onShowNowPlaying: widget.onShowNowPlaying,
                  ),
                ),
              ),
            ),
          ),
        ],
        if (_albums.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Albums',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ..._albums.map(
            (a) => ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 50,
                  height: 50,
                  color: AppTheme.surfaceGrey,
                  child: a.coverImgUrl.isNotEmpty
                    ? CachedNetworkImage(
                        fadeInDuration: Duration.zero,
                        imageUrl: a.coverImgUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.album, color: AppTheme.textMuted),
                      )
                    : const Icon(Icons.album, color: AppTheme.textMuted),
                ),
              ),
              title: Text(
                a.title,
                style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                a.artist.name,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppTheme.textMuted,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AlbumDetailScreen(
                    album: a,
                    onPlaySong: widget.onPlaySong,
                    onShowNowPlaying: widget.onShowNowPlaying,
                  ),
                ),
              ),
            ),
          ),
        ],
        if (_songs.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Songs',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ..._songs.map(
            (s) => SongTile(
              song: s,
              onTap: () {
                widget.onPlaySong(s, queue: _songs);
                widget.onShowNowPlaying(s);
              },
            ),
          ),
        ],
        if (_songs.isEmpty &&
            _artists.isEmpty &&
            _albums.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const Icon(
                    Icons.search_off,
                    color: AppTheme.textMuted,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _query.isNotEmpty 
                      ? 'No results for "$_query"'
                      : 'No songs found in this genre',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 180),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryTile({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
