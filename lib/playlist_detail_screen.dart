import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                                widget.playlistId == 'lyrics';
        final canAddSongs = !isSystemPlaylist;

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
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, musicService),
                  Expanded(
                    child: _isAddMusicMode
                        ? _buildAddMusicView(musicService)
                        : _buildPlaylistView(playlistSongs, musicService, canAddSongs),
                  ),
                  if (musicService.currentSong != null)
                    _buildBottomPlayer(musicService),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
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
              icon: const Icon(Icons.check, color: Colors.white, size: 28),
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
                    SnackBar(content: Text('Added ${_selectedSongs.length} songs')),
                  );
                }
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
              onPressed: () => _showPlaylistOptions(context, musicService),
            ),
        ],
      ),
    );
  }

  void _showPlaylistOptions(BuildContext context, MusicService musicService) {
    final isSystemPlaylist = widget.playlistId == 'recently' || 
                            widget.playlistId == 'lyrics' ||
                            widget.playlistId == 'favorites';

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
            if (!isSystemPlaylist) ...[
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text('Rename playlist', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog(context, musicService);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete playlist', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, musicService);
                },
              ),
            ],
            const SizedBox(height: 20),
          ],
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
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Rename Playlist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  hintText: 'Playlist name',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        final playlist = musicService.getPlaylistById(widget.playlistId);
                        if (playlist != null) {
                          playlist.name = controller.text;
                          Navigator.pop(context);
                          setState(() {});
                        }
                      }
                    },
                    child: const Text('Rename', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MusicService musicService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Delete Playlist', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${widget.playlistName}"?',
          style: const TextStyle(color: Colors.white),
        ),
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistView(List<Song> songs, MusicService musicService, bool canAddSongs) {
    return Column(
      children: [
        // Playlist Icon
        Container(
          margin: const EdgeInsets.symmetric(vertical: 30),
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A5F),
            borderRadius: BorderRadius.circular(24),
          ),
          child: _buildPlaylistIcon(),
        ),
        
        // Playlist Name
        Text(
          widget.playlistName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        Text(
          '${songs.length} Song${songs.length != 1 ? 's' : ''}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 16,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Add Music Button
        if (canAddSongs)
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isAddMusicMode = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Add Music',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        
        const SizedBox(height: 20),
        
        // Songs List
        if (songs.isNotEmpty)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_circle, color: Colors.white, size: 36),
                          onPressed: () {
                            if (songs.isNotEmpty) {
                              musicService.playSong(songs[0], queue: songs);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.shuffle, color: Colors.white, size: 28),
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
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        return _buildSongItem(songs[index], musicService, false);
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          const Expanded(
            child: Center(
              child: Text(
                'No songs in this playlist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaylistIcon() {
    IconData icon;
    
    switch (widget.playlistId) {
      case 'favorites':
        icon = Icons.favorite;
        break;
      case 'recently':
        icon = Icons.history;
        break;
      case 'lyrics':
        icon = Icons.lyrics;
        break;
      default:
        icon = Icons.playlist_play;
    }
    
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.pink,
              Colors.blue,
              Colors.purple,
              Colors.orange,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 100, color: Colors.white),
      ),
    );
  }

  Widget _buildAddMusicView(MusicService musicService) {
    final allSongs = musicService.allSongs;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Select All',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _toggleSelectAll(allSongs),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      color: _selectAll ? Colors.white : Colors.transparent,
                    ),
                    child: _selectAll
                        ? const Icon(Icons.check, size: 16, color: Colors.black)
                        : null,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: allSongs.length,
              itemBuilder: (context, index) {
                return _buildSongItem(allSongs[index], musicService, true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongItem(Song song, MusicService musicService, bool showCheckbox) {
    final isSelected = _selectedSongs.contains(song.id);
    
    return InkWell(
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PlayerScreen(),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                song.imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[800],
                  child: const Icon(Icons.music_note, color: Colors.white, size: 24),
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
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    song.artist,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (showCheckbox)
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedSongs.remove(song.id);
                    } else {
                      _selectedSongs.add(song.id);
                    }
                    _selectAll = _selectedSongs.length == musicService.allSongs.length;
                  });
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    color: isSelected ? Colors.white : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.black)
                      : null,
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  _showSongOptions(context, song, musicService);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showSongOptions(BuildContext context, Song song, MusicService musicService) {
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
              leading: const Icon(Icons.remove_circle_outline, color: Colors.red),
              title: const Text('Remove from playlist', style: TextStyle(color: Colors.red)),
              onTap: () {
                musicService.removeSongFromPlaylist(widget.playlistId, song.id);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPlayer(MusicService musicService) {
    final song = musicService.currentSong!;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PlayerScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xFFFA0B0B),
              const Color(0xFFFBBF00),
            ],
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 3),
              ),
              child: ClipOval(
                child: Image.asset(
                  song.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                song.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                musicService.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.black,
                size: 32,
              ),
              onPressed: () {
                musicService.togglePlayPause();
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.black, size: 24),
              onPressed: () {
                musicService.playNext();
              },
            ),
          ],
        ),
      ),
    );
  }
}