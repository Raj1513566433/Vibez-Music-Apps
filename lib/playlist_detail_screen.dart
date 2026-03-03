import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibez/album_art_widget.dart';
import 'package:vibez/mini_player.dart';
import 'package:vibez/music_service.dart';
import 'package:vibez/player_screen.dart';
import 'package:vibez/song.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;
  final String playlistName;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  bool _isAddMusicMode = false;
  bool _selectAll = false;
  Set<String> _selectedSongs = {};

  void _toggleSelectAll(List<Song> allSongs) {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedSongs = allSongs.map((s) => s.id).toSet();
      } else {
        _selectedSongs.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicService>(
      builder: (context, musicService, child) {
        final playlistSongs = musicService.getPlaylistSongs(widget.playlistId);
        final isSystemPlaylist = widget.playlistId == 'recently' || 
                                widget.playlistId == 'lyrics' ||
                                widget.playlistId == 'favorites';
        final canAddSongs = !isSystemPlaylist;

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
                  _buildHeader(context, musicService),
                  Expanded(
                    child: _isAddMusicMode
                        ? _buildAddMusicView(musicService)
                        : _buildPlaylistView(playlistSongs, musicService, canAddSongs),
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

  Widget _buildHeader(BuildContext context, MusicService musicService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 24),
            onPressed: () {
              if (_isAddMusicMode) {
                setState(() {
                  _isAddMusicMode = false;
                  _selectedSongs.clear();
                  _selectAll = false;
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
          Expanded(
            child: Text(
              _isAddMusicMode ? 'Add Music' : widget.playlistName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_isAddMusicMode)
            IconButton(
              icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
              onPressed: () {
                if (_selectedSongs.isNotEmpty) {
                  musicService.addSongsToPlaylist(
                    widget.playlistId,
                    _selectedSongs.toList(),
                  );
                  setState(() {
                    _isAddMusicMode = false;
                    _selectedSongs.clear();
                    _selectAll = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added ${_selectedSongs.length} songs to ${widget.playlistName}')),
                  );
                }
              },
            )
          else if (!isSystemPlaylistHeader(widget.playlistId))
            IconButton(
              icon: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 28),
              onPressed: () => _showPlaylistOptions(context, musicService),
            ),
        ],
      ),
    );
  }

  bool isSystemPlaylistHeader(String id) {
    return id == 'recently' || id == 'lyrics' || id == 'favorites';
  }

  void _showPlaylistOptions(BuildContext context, MusicService musicService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
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
                  leading: const Icon(Icons.edit_rounded, color: Colors.white70),
                  title: const Text('Rename Playlist', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _showRenameDialog(context, musicService);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF6B6B)),
                  title: const Text('Delete Playlist', style: TextStyle(color: Color(0xFFFF6B6B))),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, musicService);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, MusicService musicService) {
    final controller = TextEditingController(text: widget.playlistName);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Rename Playlist',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      hintText: 'New Playlist name',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            musicService.renamePlaylist(widget.playlistId, controller.text);
                            Navigator.pop(context);
                            setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B).withValues(alpha: 0.9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Rename'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MusicService musicService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Delete Playlist', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "${widget.playlistName}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              musicService.deletePlaylist(widget.playlistId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistView(List<Song> songs, MusicService musicService, bool canAddSongs) {
    return Column(
      children: [
        // Playlist Header Art
        Container(
          margin: const EdgeInsets.symmetric(vertical: 24),
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: _buildPlaylistArt(songs),
        ),
        
        Text(
          widget.playlistName,
          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '${songs.length} songs',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16),
        ),
        
        const SizedBox(height: 24),
        
        if (canAddSongs)
          ElevatedButton.icon(
            onPressed: () => setState(() => _isAddMusicMode = true),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Songs'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
            ),
          ),
        
        const SizedBox(height: 24),
        
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                if (songs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFFFF6B6B), size: 48),
                          onPressed: () {
                            if (songs.isNotEmpty) {
                              musicService.playSong(songs[0], queue: songs);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.shuffle_rounded, color: Colors.white.withValues(alpha: 0.7), size: 28),
                          onPressed: () {
                            musicService.toggleShuffle();
                            if (songs.isNotEmpty) {
                              musicService.playSong(songs[0], queue: songs);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: songs.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: songs.length,
                          itemBuilder: (context, index) => _buildSongItem(songs[index], musicService, false),
                        )
                      : Center(child: Text('Playlist is empty', style: TextStyle(color: Colors.white.withValues(alpha: 0.4)))),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistArt(List<Song> songs) {
    if (widget.playlistId == 'favorites') {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFE91E63)]),
        ),
        child: const Icon(Icons.favorite_rounded, size: 80, color: Colors.white),
      );
    }
    
    if (songs.isNotEmpty) {
      return AlbumArtWidget(songId: songs.first.id, size: 180, borderRadius: BorderRadius.circular(24));
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.1),
      ),
      child: const Icon(Icons.library_music_rounded, size: 80, color: Colors.white24),
    );
  }

  Widget _buildAddMusicView(MusicService musicService) {
    final allSongs = musicService.allSongs;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_selectedSongs.length} selected', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => _toggleSelectAll(allSongs),
                  icon: Icon(_selectAll ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded),
                  label: const Text('Select All'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: allSongs.length,
              itemBuilder: (context, index) => _buildSongItem(allSongs[index], musicService, true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongItem(Song song, MusicService musicService, bool showCheckbox) {
    final isSelected = _selectedSongs.contains(song.id);
    final isCurrentSong = musicService.currentSong?.id == song.id;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (showCheckbox) {
            setState(() {
              if (isSelected) {
                _selectedSongs.remove(song.id);
              } else {
                _selectedSongs.add(song.id);
              }
              _selectAll = _selectedSongs.length == musicService.allSongs.length;
            });
          } else {
            musicService.playSong(song);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayerScreen()));
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCurrentSong ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              AlbumArtWidget(songId: song.id, size: 48, borderRadius: BorderRadius.circular(8)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: TextStyle(color: isCurrentSong ? const Color(0xFFFF6B6B) : Colors.white, fontSize: 16, fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(song.artist, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (showCheckbox)
                Checkbox(
                  value: isSelected,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedSongs.add(song.id);
                      } else {
                        _selectedSongs.remove(song.id);
                      }
                      _selectAll = _selectedSongs.length == musicService.allSongs.length;
                    });
                  },
                  activeColor: const Color(0xFFFF6B6B),
                  side: const BorderSide(color: Colors.white54),
                )
              else
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white54),
                  onPressed: () => _showSongOptions(context, song, musicService),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSongOptions(BuildContext context, Song song, MusicService musicService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
                ),
                ListTile(
                  leading: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFFF6B6B)),
                  title: const Text('Remove from Playlist', style: TextStyle(color: Color(0xFFFF6B6B))),
                  onTap: () {
                    musicService.removeSongFromPlaylist(widget.playlistId, song.id);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}