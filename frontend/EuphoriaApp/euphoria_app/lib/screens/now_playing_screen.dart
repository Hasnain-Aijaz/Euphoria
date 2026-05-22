import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'package:euphoria/models/models.dart';
import '../widgets/playlist_selection_sheet.dart';

class NowPlayingScreen extends StatefulWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool isLiked;
  final VoidCallback? onToggleLike;
  final double volume;
  final Function(double)? onVolumeChanged;
  final Duration position;
  final Duration duration;
  final Function(Duration)? onSeek;

  const NowPlayingScreen({
    super.key,
    required this.song,
    this.isPlaying = false,
    this.onPlayPause,
    this.onNext,
    this.onPrevious,
    this.isLiked = false,
    this.onToggleLike,
    this.volume = 0.7,
    this.onVolumeChanged,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.onSeek,
  });

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  bool _isShuffle = false;
  int _repeatMode = 0; // 0=off, 1=all, 2=one
  double? _dragValue;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(NowPlayingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.song;
    final position = _dragValue != null 
        ? Duration(seconds: (widget.duration.inSeconds * _dragValue!).round())
        : widget.position;
    
    // Use widget.duration if it's greater than zero, otherwise fallback to song duration
    final duration = widget.duration.inSeconds > 0 
        ? widget.duration 
        : Duration(seconds: song.durationSeconds);

    final sliderValue = duration.inSeconds > 0
        ? (position.inSeconds / duration.inSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D0000), Color(0xFF0A0000), AppTheme.black],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // top bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppTheme.textWhite,
                              size: 32,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Expanded(
                            child: Text(
                              'NOW PLAYING',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.more_horiz,
                              color: AppTheme.textWhite,
                            ),
                            onPressed: () => _showOptionsSheet(context),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // album picture
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: AnimatedBuilder(
                        animation: _rotationController,
                        builder: (_, child) => Transform.rotate(
                          angle: _rotationController.value * 2 * 3.14159,
                          child: child,
                        ),
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.netflixRed.withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Hero(
                            tag: 'song_thumb_mini_${song.id}',
                            child: ClipOval(
                              child: (song.thumbnailUrl != null && song.thumbnailUrl!.isNotEmpty)
                                  ? CachedNetworkImage(
                                      fadeInDuration: Duration.zero,
                                      imageUrl: song.thumbnailUrl!,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Container(
                                        color: AppTheme.surfaceGrey,
                                        child: const Icon(
                                          Icons.music_note,
                                          color: AppTheme.textMuted,
                                          size: 80,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: AppTheme.surfaceGrey,
                                      child: const Icon(
                                        Icons.music_note,
                                        color: AppTheme.textMuted,
                                        size: 80,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 36),

                    // song info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  style: const TextStyle(
                                    color: AppTheme.textWhite,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
                                const SizedBox(height: 4),
                                Text(
                                  song.artistName,
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 15,
                                  ),
                                ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.2),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              widget.isLiked ? Icons.favorite : Icons.favorite_border,
                              color: widget.isLiked
                                  ? AppTheme.netflixRed
                                  : AppTheme.textMuted,
                              size: 26,
                            ),
                            onPressed: widget.onToggleLike,
                          ).animate().scale(duration: 300.ms, delay: 200.ms),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // progress bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppTheme.netflixRed,
                              inactiveTrackColor: AppTheme.borderGrey,
                              thumbColor: AppTheme.textWhite,
                              overlayColor: AppTheme.netflixRed.withOpacity(0.2),
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                            ),
                            child: Slider(
                              value: sliderValue,
                              onChanged: (v) => setState(() => _dragValue = v),
                              onChangeEnd: (v) {
                                if (widget.onSeek != null) {
                                  widget.onSeek!(Duration(seconds: (widget.duration.inSeconds * v).round()));
                                }
                                setState(() => _dragValue = null);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatSeconds(position.inSeconds),
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _formatSeconds(widget.duration.inSeconds),
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // controls
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Shuffle
                          IconButton(
                            icon: Icon(
                              Icons.shuffle,
                              color: _isShuffle
                                  ? AppTheme.netflixRed
                                  : AppTheme.textMuted,
                              size: 22,
                            ),
                            onPressed: () => setState(() => _isShuffle = !_isShuffle),
                          ),
                          // Previous
                          IconButton(
                            icon: const Icon(
                              Icons.skip_previous,
                              color: AppTheme.textWhite,
                              size: 36,
                            ),
                            onPressed: widget.onPrevious,
                          ),
                          // Play/Pause
                          GestureDetector(
                            onTap: widget.onPlayPause,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: AppTheme.netflixRed,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x66E50914),
                                    blurRadius: 20,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                          // Next
                          IconButton(
                            icon: const Icon(
                              Icons.skip_next,
                              color: AppTheme.textWhite,
                              size: 36,
                            ),
                            onPressed: widget.onNext,
                          ),
                          // Repeat
                          IconButton(
                            icon: Icon(
                              _repeatMode == 2 ? Icons.repeat_one : Icons.repeat,
                              color: _repeatMode > 0
                                  ? AppTheme.netflixRed
                                  : AppTheme.textMuted,
                              size: 22,
                            ),
                            onPressed: () =>
                                setState(() => _repeatMode = (_repeatMode + 1) % 3),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // volume row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        children: [
                          Icon(
                            widget.volume == 0 ? Icons.volume_off : Icons.volume_mute,
                            color: AppTheme.textMuted,
                            size: 18,
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppTheme.netflixRed,
                                inactiveTrackColor: AppTheme.borderGrey,
                                thumbColor: AppTheme.textWhite,
                                trackHeight: 2,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 5,
                                ),
                              ),
                              child: Slider(
                                value: widget.volume,
                                onChanged: widget.onVolumeChanged,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.volume_up,
                            color: AppTheme.textMuted,
                            size: 18,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),

                    const SizedBox(height: 12),

                    // action row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionButton(
                          icon: Icons.playlist_add,
                          label: 'Add to Playlist',
                          onTap: () => showPlaylistSelectionSheet(context, widget.song),
                        ),
                        const SizedBox(width: 24),
                        _ActionButton(
                          icon: Icons.share,
                          label: 'Share',
                          onTap: () {},
                        ),
                        const SizedBox(width: 24),
                        _ActionButton(
                          icon: Icons.info_outline,
                          label: 'Info',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatSeconds(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '$m:${sec.toString().padLeft(2, '0')}';
  }

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          _SheetOption(
            icon: Icons.playlist_add, 
            label: 'Add to Playlist',
            onTap: () {
              Navigator.pop(context);
              showPlaylistSelectionSheet(context, widget.song);
            },
          ),
          const _SheetOption(icon: Icons.album, label: 'Go to Album'),
          const _SheetOption(icon: Icons.person, label: 'Go to Artist'),
          const _SheetOption(icon: Icons.share, label: 'Share Song'),
          const _SheetOption(icon: Icons.download, label: 'Download'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: AppTheme.textWhite, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SheetOption({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textWhite),
      title: Text(label, style: const TextStyle(color: AppTheme.textWhite)),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }
}

