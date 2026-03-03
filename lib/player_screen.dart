import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibez/album_art_widget.dart';
import 'package:vibez/music_service.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    // Start rotation if already playing
    final musicService = Provider.of<MusicService>(context, listen: false);
    if (musicService.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final artSize = (screenWidth * 0.7).clamp(200.0, 320.0);

    return Consumer<MusicService>(
      builder: (context, musicService, child) {
        final song = musicService.currentSong;

        // Sync rotation with playback
        if (musicService.isPlaying) {
          if (!_rotationController.isAnimating) {
            _rotationController.repeat();
          }
        } else {
          _rotationController.stop();
        }

        if (song == null) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF400C04),
                    Color(0xFFC02323),
                    Color(0xFF984652),
                    Color(0xFF96929E),
                  ],
                  stops: [0.05, 0.30, 0.60, 1.0],
                ),
              ),
              child: const Center(
                child: Text(
                  'No song playing',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A0005),
                  Color(0xFF400C04),
                  Color(0xFF2D1B36),
                  Color(0xFF0D0D1A),
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, song.title, musicService),
                  const Spacer(flex: 2),
                  _buildAlbumArt(song, artSize),
                  const SizedBox(height: 32),
                  _buildSongInfo(song.title, song.artist, screenWidth),
                  const Spacer(flex: 1),
                  _buildControls(context, musicService, screenWidth),
                  SizedBox(height: screenHeight * 0.04),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, String title, MusicService musicService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'NOW PLAYING',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 28),
            onPressed: () => _showOptions(context, musicService),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, MusicService musicService) {
    final song = musicService.currentSong!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(
                musicService.isFavorite(song.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: musicService.isFavorite(song.id)
                    ? const Color(0xFFFF6B6B)
                    : Colors.white,
              ),
              title: Text(
                musicService.isFavorite(song.id)
                    ? 'Remove from favorites'
                    : 'Add to favorites',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                musicService.toggleFavorite(song.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add_rounded, color: Colors.white),
              title: const Text('Add to playlist',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded, color: Colors.white),
              title: const Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Share: ${song.title}')),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumArt(dynamic song, double artSize) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFA0B0B).withValues(alpha: 0.25),
              blurRadius: 50,
              spreadRadius: 10,
            ),
          ],
        ),
        child: RotationTransition(
          turns: _rotationController,
          child: Container(
            width: artSize,
            height: artSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: AlbumArtWidget(
                songId: song.id,
                size: artSize,
                borderRadius: BorderRadius.circular(artSize / 2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(String title, String artist, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            artist,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildControls(
      BuildContext context, MusicService musicService, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
      child: Column(
        children: [
          // Favorite button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  musicService.isFavorite(musicService.currentSong!.id)
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: musicService.isFavorite(musicService.currentSong!.id)
                      ? const Color(0xFFFF6B6B)
                      : Colors.white.withValues(alpha: 0.7),
                  size: 28,
                ),
                onPressed: () {
                  musicService.toggleFavorite(musicService.currentSong!.id);
                },
              ),
              IconButton(
                icon: Icon(Icons.queue_music_rounded,
                    color: Colors.white.withValues(alpha: 0.7), size: 26),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: const Color(0xFFFF6B6B),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: musicService.currentPosition.inSeconds
                  .toDouble()
                  .clamp(
                      0, musicService.totalDuration.inSeconds.toDouble()),
              min: 0,
              max: musicService.totalDuration.inSeconds.toDouble() > 0
                  ? musicService.totalDuration.inSeconds.toDouble()
                  : 1,
              onChanged: (value) {
                musicService.seekTo(Duration(seconds: value.toInt()));
              },
            ),
          ),

          // Time labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(musicService.currentPosition),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDuration(musicService.totalDuration),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Shuffle
              IconButton(
                icon: Icon(
                  Icons.shuffle_rounded,
                  color: musicService.isShuffle
                      ? const Color(0xFFFF6B6B)
                      : Colors.white.withValues(alpha: 0.6),
                  size: 24,
                ),
                onPressed: () => musicService.toggleShuffle(),
              ),

              // Previous
              _buildCircleButton(
                icon: Icons.skip_previous_rounded,
                size: 56,
                iconSize: 30,
                onTap: () => musicService.playPrevious(),
              ),

              // Play/Pause
              _buildCircleButton(
                icon: musicService.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 72,
                iconSize: 40,
                isPrimary: true,
                onTap: () => musicService.togglePlayPause(),
              ),

              // Next
              _buildCircleButton(
                icon: Icons.skip_next_rounded,
                size: 56,
                iconSize: 30,
                onTap: () => musicService.playNext(),
              ),

              // Repeat
              IconButton(
                icon: Icon(
                  musicService.loopMode == LoopMode.one
                      ? Icons.repeat_one_rounded
                      : Icons.repeat_rounded,
                  color: musicService.loopMode != LoopMode.off
                      ? const Color(0xFFFF6B6B)
                      : Colors.white.withValues(alpha: 0.6),
                  size: 24,
                ),
                onPressed: () => musicService.toggleLoopMode(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required double size,
    required double iconSize,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.1),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isPrimary ? Colors.black : Colors.white,
          size: iconSize,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}