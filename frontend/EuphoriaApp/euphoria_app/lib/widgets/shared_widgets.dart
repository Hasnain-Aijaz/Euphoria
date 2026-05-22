import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import 'package:euphoria/models/models.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'playlist_selection_sheet.dart';

// song tile
class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool showPlayCount;
  final int? index;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.onRemove,
    this.showPlayCount = false,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: Colors.white.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              if (index != null) ...[
                SizedBox(
                  width: 24,
                  child: Text(
                    '${index! + 1}',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Hero(
                tag: 'song_thumb_${song.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 48,
                    height: 48,
                    color: AppTheme.surfaceGrey,
                    child: song.thumbnailUrl != null && song.thumbnailUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            fadeInDuration: Duration.zero,
                            imageUrl: song.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.music_note,
                              color: AppTheme.textMuted,
                              size: 24,
                            ),
                            placeholder: (_, __) => const Icon(
                              Icons.music_note,
                              color: AppTheme.textMuted,
                              size: 24,
                            ),
                          )
                        : const Icon(
                            Icons.music_note,
                            color: AppTheme.textMuted,
                            size: 24,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      showPlayCount
                          ? '${song.artistName} • ${_formatCount(song.playCount)} plays'
                          : '${song.artistName} • ${song.genre}',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                song.durationFormatted,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppTheme.textMuted, size: 20),
                color: AppTheme.cardGrey,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'add_to_playlist',
                    child: Row(
                      children: [
                        Icon(Icons.playlist_add, color: AppTheme.textWhite, size: 20),
                        SizedBox(width: 12),
                        Text('Add to Playlist', style: TextStyle(color: AppTheme.textWhite)),
                      ],
                    ),
                  ),
                  if (onRemove != null)
                    const PopupMenuItem(
                      value: 'remove_from_playlist',
                      child: Row(
                        children: [
                          Icon(Icons.playlist_remove, color: AppTheme.textWhite, size: 20),
                          SizedBox(width: 12),
                          Text('Remove from Playlist', style: TextStyle(color: AppTheme.textWhite)),
                        ],
                      ),
                    ),
                ],
                onSelected: (value) {
                  if (value == 'add_to_playlist') {
                    showPlaylistSelectionSheet(context, song);
                  } else if (value == 'remove_from_playlist') {
                    onRemove?.call();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(0)}K';
    return count.toString();
  }
}

// album card
class AlbumCard extends StatefulWidget {
  final Album album;
  final VoidCallback? onTap;
  final double size;

  const AlbumCard({
    super.key,
    required this.album,
    this.onTap,
    this.size = 140,
  });

  @override
  State<AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<AlbumCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double imageSize = widget.size - 24;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: widget.size,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'album_${widget.album.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: imageSize,
                    height: imageSize,
                    color: AppTheme.surfaceGrey,
                    child: Stack(
                      children: [
                        if (widget.album.coverImgUrl.isNotEmpty)
                          CachedNetworkImage(
                            fadeInDuration: Duration.zero,
                            imageUrl: widget.album.coverImgUrl,
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.album,
                              color: AppTheme.textMuted,
                              size: 40,
                            ),
                            placeholder: (_, __) => const Icon(
                              Icons.album,
                              color: AppTheme.textMuted,
                              size: 40,
                            ),
                          )
                        else
                          const Center(
                            child: Icon(
                              Icons.album,
                              color: AppTheme.textMuted,
                              size: 40,
                            ),
                          ),
                        // Spotify-style play button overlay
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          bottom: _isHovered ? 8 : -40,
                          right: 8,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _isHovered ? 1.0 : 0.0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppTheme.netflixRed,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.album.title,
                style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.album.artist.name,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// artist card
class ArtistCard extends StatefulWidget {
  final Artist artist;
  final VoidCallback? onTap;

  const ArtistCard({super.key, required this.artist, this.onTap});

  @override
  State<ArtistCard> createState() => _ArtistCardState();
}

class _ArtistCardState extends State<ArtistCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 140, // Increased width slightly to prevent name overflow
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'artist_${widget.artist.id}',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: _isHovered ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ] : [],
                  ),
                  child: ClipOval(
                    child: Container(
                      color: AppTheme.surfaceGrey,
                      child: widget.artist.imgUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.artist.imgUrl,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.person,
                                color: AppTheme.textMuted,
                                size: 40,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              color: AppTheme.textMuted,
                              size: 40,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.artist.name,
                style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              const Text(
                'Artist',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// section header
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onSeeAll != null)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onSeeAll,
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: AppTheme.netflixRed,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// genre chip
class GenreChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const GenreChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  State<GenreChip> createState() => _GenreChipState();
}

class _GenreChipState extends State<GenreChip> {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.selected 
                ? AppTheme.netflixRed 
                : (_isHovered ? Colors.white.withOpacity(0.1) : AppTheme.surfaceGrey),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.selected 
                  ? AppTheme.netflixRed 
                  : (_isHovered ? Colors.white.withOpacity(0.3) : AppTheme.borderGrey),
              width: 1,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: (widget.selected || _isHovered) ? AppTheme.textWhite : AppTheme.textLight,
              fontSize: 13,
              fontWeight: (widget.selected || _isHovered) ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// mini player
class MiniPlayer extends StatefulWidget {
  final Song song;
  final VoidCallback? onTap;
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

  const MiniPlayer({
    super.key,
    required this.song,
    this.onTap,
    this.isPlaying = true,
    this.onPlayPause,
    this.onNext,
    this.onPrevious,
    this.isLiked = false,
    this.onToggleLike,
    this.volume = 0.7,
    this.onVolumeChanged,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  bool _showVolume = false;

  @override
  Widget build(BuildContext context) {
    final progress = widget.duration.inSeconds > 0
        ? widget.position.inSeconds / widget.duration.inSeconds
        : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: _showVolume ? 240 : 72,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Main Player Container
          GestureDetector(
            onTap: widget.onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Progress bar at bottom
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.netflixRed),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Hero(
                              tag: 'song_thumb_mini_${widget.song.id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  color: AppTheme.surfaceGrey,
                                  child: widget.song.thumbnailUrl != null && widget.song.thumbnailUrl!.isNotEmpty
                                      ? CachedNetworkImage(
                                          fadeInDuration: Duration.zero,
                                          imageUrl: widget.song.thumbnailUrl!,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) => const Icon(
                                            Icons.music_note,
                                            color: AppTheme.textMuted,
                                            size: 24,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.music_note,
                                          color: AppTheme.textMuted,
                                          size: 24,
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.song.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textWhite,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    widget.song.artistName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Controls
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    widget.isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: widget.isLiked ? AppTheme.netflixRed : AppTheme.textMuted,
                                    size: 22,
                                  ),
                                  onPressed: widget.onToggleLike,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_previous, color: AppTheme.textWhite, size: 24),
                                  onPressed: widget.onPrevious,
                                ),
                                GestureDetector(
                                  onTap: widget.onPlayPause,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.textWhite,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      widget.isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: AppTheme.black,
                                      size: 26,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_next, color: AppTheme.textWhite, size: 24),
                                  onPressed: widget.onNext,
                                ),
                                
                                // Volume Control Toggle Button
                                IconButton(
                                  icon: Icon(
                                    widget.volume == 0 ? Icons.volume_off : (widget.volume < 0.5 ? Icons.volume_down : Icons.volume_up),
                                    color: _showVolume ? AppTheme.netflixRed : AppTheme.textMuted,
                                    size: 22,
                                  ),
                                  onPressed: () => setState(() => _showVolume = !_showVolume),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Floating Volume Slider
          if (_showVolume)
            Positioned(
              bottom: 80,
              right: 12,
              child: Container(
                height: 150,
                width: 44,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.netflixRed,
                      inactiveTrackColor: Colors.white.withOpacity(0.1),
                      thumbColor: Colors.white,
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      overlayColor: AppTheme.netflixRed.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: widget.volume,
                      onChanged: (v) {
                        widget.onVolumeChanged?.call(v);
                      },
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2, curve: Curves.easeOutCubic).scale(begin: const Offset(0.8, 0.8)),
            ),
        ],
      ),
    ).animate().slideY(begin: 1, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}

// playlist card
class PlaylistCard extends StatefulWidget {
  final Playlist playlist;
  final VoidCallback? onTap;
  final double size;

  const PlaylistCard({
    super.key,
    required this.playlist,
    this.onTap,
    this.size = 140,
  });

  @override
  State<PlaylistCard> createState() => _PlaylistCardState();
}

class _PlaylistCardState extends State<PlaylistCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double imageSize = widget.size - 24;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: widget.size,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: Stack(
                    children: [
                      if (playlist.songs.isNotEmpty)
                        GridView.count(
                          crossAxisCount: 2,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: playlist.songs
                              .take(4)
                              .map(
                                (s) => Container(
                                  color: AppTheme.surfaceGrey,
                                  child: s.thumbnailUrl != null && s.thumbnailUrl!.isNotEmpty
                                      ? CachedNetworkImage(
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
                      else
                        Container(
                          width: imageSize,
                          height: imageSize,
                          color: AppTheme.surfaceGrey,
                          child: const Icon(
                            Icons.queue_music,
                            color: AppTheme.textMuted,
                            size: 40,
                          ),
                        ),
                      // Spotify-style play button overlay
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        bottom: _isHovered ? 8 : -40,
                        right: 8,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isHovered ? 1.0 : 0.0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.netflixRed,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                playlist.name,
                style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${playlist.songs.length} songs',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Playlist get playlist => widget.playlist;
}
