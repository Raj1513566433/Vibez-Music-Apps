import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibez/album_art_widget.dart';
import 'package:vibez/mini_player.dart';
import 'package:vibez/music_service.dart';
import 'package:vibez/player_screen.dart';
import 'package:vibez/song.dart';

class AlbumDetailScreen extends StatelessWidget {
  final String albumName;

  const AlbumDetailScreen({super.key, required this.albumName});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final coverSize = (screenWidth * 0.45).clamp(140.0, 220.0);

    return Consumer<MusicService>(
      builder: (context, musicService, child) {
        final songs = musicService.getSongsByAlbum(albumName);
        final firstSong = songs.isNotEmpty ? songs.first : null;

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
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildAlbumCover(firstSong, coverSize),
                  Expanded(
                    child: _buildSongList(songs, musicService, context),
                  ),
                  const MiniPlayer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Album',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded,
                color: Colors.white, size: 26),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumCover(Song? song, double coverSize) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: coverSize,
            height: coverSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: song != null
                  ? AlbumArtWidget(
                      songId: song.id,
                      size: coverSize,
                      borderRadius: BorderRadius.circular(20),
                    )
                  : _buildPlaceholder(coverSize),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              albumName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (song != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                song.artist,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(Icons.album_rounded, size: size * 0.5, color: Colors.white),
    );
  }

  Widget _buildSongList(
      List<Song> songs, MusicService musicService, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (songs.isNotEmpty) {
                      musicService.playSong(songs[0], queue: songs);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Color(0xFFFF6B6B), size: 28),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    musicService.toggleShuffle();
                    if (songs.isNotEmpty) {
                      musicService.playSong(songs[0], queue: songs);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.shuffle_rounded,
                        color: Colors.white.withValues(alpha: 0.7), size: 22),
                  ),
                ),
                const Spacer(),
                Text(
                  '${songs.length} song${songs.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                return _buildSongItem(songs[index], musicService, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongItem(
      Song song, MusicService musicService, BuildContext context) {
    final isCurrentSong = musicService.currentSong?.id == song.id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          musicService.playSong(song);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PlayerScreen(),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isCurrentSong
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              AlbumArtWidget(
                songId: song.id,
                size: 46,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: TextStyle(
                        color: isCurrentSong
                            ? const Color(0xFFFF6B6B)
                            : Colors.white,
                        fontSize: 15,
                        fontWeight: isCurrentSong
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.artist,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                song.durationString,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}