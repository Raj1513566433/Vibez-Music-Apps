import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibez/music_service.dart';


class AlbumArtWidget extends StatelessWidget {
  final String songId;
  final double size;
  final BorderRadius? borderRadius;

  const AlbumArtWidget({
    super.key,
    required this.songId,
    this.size = 50,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final musicService = Provider.of<MusicService>(context, listen: false);
    
    return FutureBuilder<Uint8List?>(
      future: musicService.getAlbumArt(int.tryParse(songId) ?? 0),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildPlaceholder(
            child: SizedBox(
              width: size * 0.3,
              height: size * 0.3,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white54,
              ),
            ),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            child: Image.memory(
              snapshot.data!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
            ),
          );
        }
        
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder({Widget? child}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Center(
        child: child ?? Icon(
          Icons.music_note,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}