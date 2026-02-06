import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:just_audio/just_audio.dart';
import 'package:vibez/music_service.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MusicService>(
      builder: (context, musicService, child) {
        final song = musicService.currentSong;
        
        if (song == null) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF400C04),
                    const Color(0xFFC02323),
                    const Color(0xFF984652),
                    const Color(0xFF96929E),
                  ],
                  stops: const [0.05, 0.30, 0.60, 1.0],
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
              image: DecorationImage(
                image: AssetImage('assets/images/splash.png'),
                fit: BoxFit.cover,
                alignment: Alignment(-0.3, 0.0),
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, song.title, musicService),
                    const Spacer(),
                    _buildAlbumArt(song.imagePath),
                    const SizedBox(height: 40),
                    _buildSongInfo(song.title, song.artist),
                    const Spacer(),
                    _buildControls(context, musicService),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String title, MusicService musicService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
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
          color: Colors.black.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                musicService.isFavorite(song.id) ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
              title: Text(
                musicService.isFavorite(song.id) ? 'Remove from favorites' : 'Add to favorites',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                musicService.toggleFavorite(song.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Colors.white),
              title: const Text('Add to playlist', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Show playlist selection
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
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

  Widget _buildAlbumArt(String imagePath) {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[800],
              child: const Icon(Icons.music_note, color: Colors.white, size: 80),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(String title, String artist) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            artist,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, MusicService musicService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Favorite button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                musicService.isFavorite(musicService.currentSong!.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: musicService.isFavorite(musicService.currentSong!.id)
                    ? Colors.red
                    : Colors.white,
                size: 32,
              ),
              onPressed: () {
                musicService.toggleFavorite(musicService.currentSong!.id);
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // Progress bar with time
          Row(
            children: [
              // Previous 10s button
              IconButton(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.replay, color: Colors.white, size: 32),
                    Positioned(
                      bottom: 0,
                      child: Text(
                        '10',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  musicService.seekRelative(const Duration(seconds: -10));
                },
              ),
              const SizedBox(width: 8),
              
              Expanded(
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: musicService.currentPosition.inSeconds.toDouble(),
                        min: 0,
                        max: musicService.totalDuration.inSeconds.toDouble() > 0
                            ? musicService.totalDuration.inSeconds.toDouble()
                            : 1,
                        onChanged: (value) {
                          musicService.seekTo(Duration(seconds: value.toInt()));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${_formatDuration(musicService.currentPosition)}/${_formatDuration(musicService.totalDuration)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              // Forward 10s button
              IconButton(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.forward, color: Colors.white, size: 32),
                    Positioned(
                      bottom: 0,
                      child: Text(
                        '10',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  musicService.seekRelative(const Duration(seconds: 10));
                },
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Shuffle button
              IconButton(
                icon: Icon(
                  Icons.shuffle,
                  color: musicService.isShuffle ? const Color(0xFFFA0B0B) : Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  musicService.toggleShuffle();
                },
              ),
              
              // Previous button
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.black, size: 36),
                  onPressed: () {
                    musicService.playPrevious();
                  },
                ),
              ),
              
              // Play/Pause button
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      musicService.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                      size: 48,
                    ),
                    onPressed: () {
                      musicService.togglePlayPause();
                    },
                  ),
                ),
              ),
              
              // Next button
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.black, size: 36),
                  onPressed: () {
                    musicService.playNext();
                  },
                ),
              ),
              
              // Repeat button
              IconButton(
                icon: Icon(
                  musicService.loopMode == LoopMode.one
                      ? Icons.repeat_one
                      : Icons.repeat,
                  color: musicService.loopMode != LoopMode.off
                      ? const Color(0xFFFA0B0B)
                      : Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  musicService.toggleLoopMode();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}