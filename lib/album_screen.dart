import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibez/album_art_widget.dart';
import 'package:vibez/album_detail_screen.dart';
import 'package:vibez/music_service.dart';

class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicService>(
      builder: (context, musicService, child) {
        final albums = musicService.getAlbums();
        
        if (albums.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.album_outlined, size: 64, color: Colors.white.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text(
                  'No albums found',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 18),
                ),
              ],
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Row(
                  children: [
                    Icon(Icons.album_rounded, color: Colors.white.withValues(alpha: 0.7), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${albums.length} albums',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = (constraints.maxWidth - 48) / 2;
                    final artSize = itemWidth;

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: albums.length,
                      itemBuilder: (context, index) {
                        return _buildAlbumCard(context, albums[index], musicService, artSize);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlbumCard(BuildContext context, String albumName, MusicService musicService, double artSize) {
    final albumSongs = musicService.getSongsByAlbum(albumName);
    final firstSong = albumSongs.isNotEmpty ? albumSongs.first : null;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlbumDetailScreen(albumName: albumName),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: firstSong != null
                    ? AlbumArtWidget(
                        songId: firstSong.id,
                        size: artSize,
                        borderRadius: BorderRadius.circular(20),
                      )
                    : _buildPlaceholder(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            albumName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${albumSongs.length} songs',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[800]!, Colors.grey[900]!],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.album_rounded, color: Colors.white38, size: 48),
    );
  }
}