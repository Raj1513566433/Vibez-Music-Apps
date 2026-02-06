import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibez/album_detail_screen.dart';
import 'package:vibez/music_service.dart';


class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicService>(
      builder: (context, musicService, child) {
        final albums = musicService.getAlbums();
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: albums.isEmpty
              ? const Center(
                  child: Text(
                    'No albums found',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: albums.length,
                  itemBuilder: (context, index) {
                    return _buildAlbumItem(context, albums[index], musicService);
                  },
                ),
        );
      },
    );
  }

  Widget _buildAlbumItem(BuildContext context, String albumName, MusicService musicService) {
    final albumSongs = musicService.getSongsByAlbum(albumName);
    final firstSong = albumSongs.isNotEmpty ? albumSongs.first : null;
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlbumDetailScreen(albumName: albumName),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: firstSong != null
                  ? Image.asset(
                      firstSong.imagePath,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    albumName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${albumSongs.length} Song${albumSongs.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.album, color: Colors.white, size: 32),
    );
  }
}