import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';
import 'theme/app_theme.dart';
import 'package:euphoria/models/models.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/library_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/now_playing_screen.dart';
import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'widgets/shared_widgets.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const EuphoriaApp());
}

class EuphoriaApp extends StatelessWidget {
  const EuphoriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Euphoria',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  int? _hoveredIndex;
  bool _isPlaying = false;
  bool _isSidebarExpanded = true;
  Song? _currentSong;
  List<Song> _queue = [];
  int _queueIndex = -1;
  Set<int> _likedSongIds = {};
  double _volume = 0.7;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setVolume(_volume);
    
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _onNextSong();
    });

    _loadLikedSongs();
  }

  Future<void> _loadLikedSongs() async {
    final ids = await ApiService.fetchLikedSongIds();
    if (mounted) {
      setState(() {
        _likedSongIds = ids.toSet();
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  Future<void> _onPlaySong(Song song, {List<Song>? queue}) async {
    if (queue != null) {
      _queue = queue;
      _queueIndex = _queue.indexWhere((s) => s.id == song.id);
    } else if (!_queue.any((s) => s.id == song.id)) {
      _queue = [song];
      _queueIndex = 0;
    } else {
      _queueIndex = _queue.indexWhere((s) => s.id == song.id);
    }

    if (_currentSong?.id == song.id) {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } else {
      setState(() {
        _currentSong = song;
        _isPlaying = true;
      });
      await _audioPlayer.play(UrlSource(song.audioUrl));
    }
  }

  Future<void> _onNextSong() async {
    if (_queue.isEmpty) return;
    _queueIndex = (_queueIndex + 1) % _queue.length;
    final nextSong = _queue[_queueIndex];
    setState(() {
      _currentSong = nextSong;
      _isPlaying = true;
    });
    await _audioPlayer.play(UrlSource(nextSong.audioUrl));
  }

  Future<void> _onPreviousSong() async {
    if (_queue.isEmpty) return;
    _queueIndex = (_queueIndex - 1 + _queue.length) % _queue.length;
    final prevSong = _queue[_queueIndex];
    setState(() {
      _currentSong = prevSong;
      _isPlaying = true;
    });
    await _audioPlayer.play(UrlSource(prevSong.audioUrl));
  }

  Future<void> _toggleLike() async {
    if (_currentSong == null) return;
    final songId = _currentSong!.id;
    final wasLiked = _likedSongIds.contains(songId);

    bool success;
    if (wasLiked) {
      success = await ApiService.unlikeSong(songId);
      if (success) {
        setState(() => _likedSongIds.remove(songId));
      }
    } else {
      success = await ApiService.likeSong(songId);
      if (success) {
        setState(() => _likedSongIds.add(songId));
      }
    }

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action failed. Please try again.')),
      );
    }
  }

  Future<void> _setVolume(double value) async {
    setState(() => _volume = value);
    await _audioPlayer.setVolume(value);
  }

  Future<void> _onSeek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else if (_currentSong != null) {
      await _audioPlayer.resume();
    }
  }

  void _showNowPlaying(Song song) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, _, __) => NowPlayingScreen(
          song: song,
          isPlaying: _isPlaying,
          onPlayPause: _togglePlayPause,
          onNext: _onNextSong,
          onPrevious: _onPreviousSong,
          isLiked: _likedSongIds.contains(song.id),
          onToggleLike: _toggleLike,
          volume: _volume,
          onVolumeChanged: _setVolume,
          position: _position,
          duration: _duration,
          onSeek: _onSeek,
        ),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? AppTheme.netflixRed
                  : AppTheme.textWhite.withOpacity(0.5),
              size: isSelected ? 26 : 24,
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                height: 4,
                width: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.netflixRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _isSidebarExpanded ? 260 : 80,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        border: Border(right: BorderSide(color: AppTheme.borderGrey, width: 1)),
      ),
      child: Column(
        children: [
          // Desktop Logo & Collapse Toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 40),
            child: Row(
              mainAxisAlignment: _isSidebarExpanded ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
              children: [
                if (_isSidebarExpanded)
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.netflixRed.withOpacity(0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset('assets/euphoria_logo1.png', fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Flexible(
                          child: Text(
                            'EUPHORIA',
                            style: TextStyle(
                              color: AppTheme.textWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.netflixRed.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/euphoria_logo1.png', fit: BoxFit.cover),
                    ),
                  ),
                if (_isSidebarExpanded) 
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: AppTheme.textMuted),
                    onPressed: () => setState(() => _isSidebarExpanded = false),
                  ),
              ],
            ),
          ),
          
          if (!_isSidebarExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: IconButton(
                icon: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                onPressed: () => setState(() => _isSidebarExpanded = true),
              ),
            ),

          // Sidebar Items
          _buildSidebarItem(Icons.home_outlined, Icons.home, 'Home', 0),
          _buildSidebarItem(Icons.search, Icons.search, 'Search', 1),
          _buildSidebarItem(Icons.library_music_outlined, Icons.library_music, 'Library', 2),
          _buildSidebarItem(Icons.person_outline, Icons.person, 'Profile', 3),
          const Spacer(),
          // Admin quick entry (Only icon if collapsed)
          if (_currentSong == null) // Temporary placeholder for admin check
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, IconData activeIcon, String label, int index) {
    bool isSelected = _currentIndex == index;
    bool isHovered = _hoveredIndex == index;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _onNavTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isSelected ? AppTheme.netflixRed : Colors.transparent,
                width: 4,
              ),
            ),
            color: isSelected 
                ? AppTheme.netflixRed.withOpacity(0.08) 
                : (isHovered ? Colors.white.withOpacity(0.05) : Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: _isSidebarExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: _isSidebarExpanded ? 24 : 0),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: (isSelected || isHovered) ? AppTheme.textWhite : AppTheme.textMuted,
                  size: (isSelected || isHovered) ? 26 : 24,
                ),
              ),
              if (_isSidebarExpanded)
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: (isSelected || isHovered) ? AppTheme.textWhite : AppTheme.textMuted,
                      fontWeight: (isSelected || isHovered) ? FontWeight.bold : FontWeight.w500,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onNavigate: _onNavTap,
        onPlaySong: _onPlaySong,
        onShowNowPlaying: _showNowPlaying,
      ),
      SearchScreen(
        onPlaySong: _onPlaySong,
        onShowNowPlaying: _showNowPlaying,
      ),
      LibraryScreen(
        onNavigate: _onNavTap,
        onPlaySong: _onPlaySong,
        onShowNowPlaying: _showNowPlaying,
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth >= 900;

          return PopScope(
            canPop: _currentIndex == 0,
            onPopInvoked: (didPop) {
              if (!didPop && _currentIndex != 0) {
                _onNavTap(0);
              }
            },
            child: Row(
              children: [
                if (isDesktop) _buildSidebar(),
                Expanded(
                  child: Stack(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: screens[_currentIndex],
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 900),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // mini player
                                if (_currentSong != null)
                                  MiniPlayer(
                                    song: _currentSong!,
                                    isPlaying: _isPlaying,
                                    onPlayPause: _togglePlayPause,
                                    onNext: _onNextSong,
                                    onPrevious: _onPreviousSong,
                                    isLiked: _likedSongIds.contains(_currentSong!.id),
                                    onToggleLike: _toggleLike,
                                    volume: _volume,
                                    onVolumeChanged: _setVolume,
                                    position: _position,
                                    duration: _duration,
                                    onTap: () => Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            NowPlayingScreen(
                                              song: _currentSong!,
                                              isPlaying: _isPlaying,
                                              onPlayPause: _togglePlayPause,
                                              onNext: _onNextSong,
                                              onPrevious: _onPreviousSong,
                                              isLiked: _likedSongIds.contains(_currentSong!.id),
                                              onToggleLike: _toggleLike,
                                              volume: _volume,
                                              onVolumeChanged: _setVolume,
                                              position: _position,
                                              duration: _duration,
                                              onSeek: _onSeek,
                                            ),
                                        transitionsBuilder: (_, anim, __, child) =>
                                            SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(0, 1),
                                                end: Offset.zero,
                                              ).animate(anim),
                                              child: child,
                                            ),
                                      ),
                                    ),
                                  ),

                                // bottom dock (Only on mobile)
                                if (!isDesktop)
                                  Container(
                                    margin: const EdgeInsets.only(
                                      left: 24,
                                      right: 24,
                                      bottom: 24,
                                      top: 8,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(35),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                        child: Container(
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(35),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.15),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
                                              _buildNavItem(Icons.search, Icons.search, 'Search', 1),
                                              _buildNavItem(Icons.library_music_outlined, Icons.library_music, 'Library', 2),
                                              _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 3),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                else 
                                  const SizedBox(height: 20), // Padding for desktop player
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
