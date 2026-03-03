import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibez/music_service.dart';


class AlbumArtWidget extends StatefulWidget {
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
  State<AlbumArtWidget> createState() => _AlbumArtWidgetState();
}

class _AlbumArtWidgetState extends State<AlbumArtWidget> {
  Uint8List? _artData;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadArt();
  }

  @override
  void didUpdateWidget(AlbumArtWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songId != widget.songId) {
      _loaded = false;
      _loadArt();
    }
  }

  Future<void> _loadArt() async {
    final musicService = Provider.of<MusicService>(context, listen: false);
    try {
      final data = await musicService.getAlbumArt(int.tryParse(widget.songId) ?? 0);
      if (mounted) {
        setState(() {
          _artData = data;
          _loaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _artData = null;
          _loaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeSize = widget.size.isFinite ? widget.size : null;

    if (!_loaded) {
      return _buildPlaceholder(
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white54,
          ),
        ),
      );
    }

    if (_artData != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        child: Image.memory(
          _artData!,
          width: safeSize,
          height: safeSize,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder({Widget? child}) {
    final safeSize = widget.size.isFinite ? widget.size : null;
    final iconSize = (widget.size.isFinite ? widget.size * 0.5 : 24.0).clamp(12.0, 48.0);

    return Container(
      width: safeSize,
      height: safeSize,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      ),
      child: Center(
        child: child ?? Icon(
          Icons.music_note,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}