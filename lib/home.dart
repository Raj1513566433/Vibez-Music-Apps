import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibez/album_art_widget.dart';
import 'package:vibez/album_screen.dart';
import 'package:vibez/artist_screen.dart';
import 'package:vibez/mini_player.dart';
import 'package:vibez/music_service.dart';
import 'package:vibez/player_screen.dart';
import 'package:vibez/playlist_detail_screen.dart';
import 'package:vibez/search_screen.dart';
import 'package:vibez/song.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = ['Songs', 'Playlist', 'Album', 'Artist'];

  void _showSongOptions(BuildContext context, Song song) {
    final musicService = Provider.of<MusicService>(context, listen: false);

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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      AlbumArtWidget(
                        songId: song.id,
                        size: 56,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              song.artist,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildOptionItem(
                  Icons.skip_next_rounded,
                  'Play next',
                  () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to queue')),
                    );
                  },
                ),
                _buildOptionItem(
                  musicService.isFavorite(song.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  musicService.isFavorite(song.id)
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  () {
                    musicService.toggleFavorite(song.id);
                    Navigator.pop(context);
                  },
                ),
                _buildOptionItem(
                  Icons.playlist_add_rounded,
                  'Add to playlist',
                  () {
                    Navigator.pop(context);
                    _showAddToPlaylistDialog(context, song);
                  },
                ),
                _buildOptionItem(
                  Icons.share_rounded,
                  'Share',
                  () {
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
        ),
      ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, Song song) {
    final musicService = Provider.of<MusicService>(context, listen: false);

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
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add to Playlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...musicService.playlists
                      .where((p) => !p.isSystemPlaylist)
                      .map((playlist) => ListTile(
                            leading: const Icon(Icons.playlist_play,
                                color: Colors.white70),
                            title: Text(
                              playlist.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              musicService
                                  .addSongsToPlaylist(playlist.id, [song.id]);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Added to ${playlist.name}')),
                              );
                            },
                          )),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
              _buildHeader(screenWidth),
              _buildTabBar(screenWidth),
              Expanded(
                child: _buildContent(screenWidth, screenHeight),
              ),
              const MiniPlayer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Vibez',
            style: TextStyle(
              fontSize: 36,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Knewave',
              letterSpacing: 1.2,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon:
                  const Icon(Icons.search_rounded, color: Colors.white, size: 26),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 8,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? Border.all(
                        color: Colors.white.withValues(alpha: 0.3), width: 1)
                    : null,
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        }),
      ),
      ),
    );
  }

  Widget _buildContent(double screenWidth, double screenHeight) {
    if (_selectedTabIndex == 0) {
      return _buildSongList(screenWidth);
    } else if (_selectedTabIndex == 1) {
      return _buildPlaylistTab(screenWidth);
    } else if (_selectedTabIndex == 2) {
      return const AlbumScreen();
    } else if (_selectedTabIndex == 3) {
      return const ArtistScreen();
    } else {
      return Center(
        child: Text(
          '${_tabs[_selectedTabIndex]} - Coming Soon',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
  }

  Widget _buildSongList(double screenWidth) {
    return Consumer<MusicService>(
      builder: (context, musicService, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.library_music_rounded,
                            color: Colors.white.withValues(alpha: 0.7), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${musicService.allSongs.length} songs',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // Shuffle all button
                    GestureDetector(
                      onTap: () {
                        if (musicService.allSongs.isNotEmpty) {
                          musicService.toggleShuffle();
                          musicService.playSong(musicService.allSongs[0], queue: musicService.allSongs);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shuffle_rounded, color: Color(0xFFFF6B6B), size: 18),
                            SizedBox(width: 6),
                            Text('Shuffle', style: TextStyle(color: Color(0xFFFF6B6B), fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: musicService.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: musicService.allSongs.length,
                        itemBuilder: (context, index) {
                          return _buildSongItem(
                              musicService.allSongs[index], musicService);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSongItem(Song song, MusicService musicService) {
    final isCurrentSong = musicService.currentSong?.id == song.id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          musicService.playSong(song);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PlayerScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isCurrentSong
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Album art with playing indicator
              Stack(
                children: [
                  AlbumArtWidget(
                    songId: song.id,
                    size: 50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  if (isCurrentSong && musicService.isPlaying)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.equalizer_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: TextStyle(
                        color:
                            isCurrentSong ? const Color(0xFFFF6B6B) : Colors.white,
                        fontSize: 15,
                        fontWeight:
                            isCurrentSong ? FontWeight.w700 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      song.artist,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
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
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.more_horiz_rounded,
                    color: Colors.white.withValues(alpha: 0.5), size: 22),
                onPressed: () => _showSongOptions(context, song),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistTab(double screenWidth) {
    return Consumer<MusicService>(
      builder: (context, musicService, child) {
        final playlists = [
          {'id': 'new', 'name': 'New Playlist', 'count': '', 'isNew': true},
          {
            'id': 'favorites',
            'name': 'Favorites',
            'count':
                '${musicService.getFavoriteSongs().length} Song${musicService.getFavoriteSongs().length != 1 ? 's' : ''}',
            'isNew': false
          },
          ...musicService.playlists.map((p) => {
                'id': p.id,
                'name': p.name,
                'count':
                    '${musicService.getPlaylistSongs(p.id).length} Song${musicService.getPlaylistSongs(p.id).length != 1 ? 's' : ''}',
                'isNew': false,
              }),
        ];

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              return _buildPlaylistItem(playlists[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaylistItem(Map<String, dynamic> playlist) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (playlist['isNew'] == true) {
            _showCreatePlaylistDialog();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaylistDetailScreen(
                  playlistId: playlist['id'],
                  playlistName: playlist['name'],
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: playlist['isNew'] == true
                      ? null
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E3A5F), Color(0xFF2B5876)],
                        ),
                  color: playlist['isNew'] == true
                      ? Colors.white.withValues(alpha: 0.1)
                      : null,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  playlist['isNew'] == true
                      ? Icons.add_rounded
                      : Icons.playlist_play_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist['name']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (playlist['count']!.toString().isNotEmpty)
                      Text(
                        playlist['count']!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black87,
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
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'New Playlist',
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
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      hintText: 'Playlist name',
                      hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            final musicService = Provider.of<MusicService>(
                                context,
                                listen: false);
                            musicService.createPlaylist(controller.text);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Playlist "${controller.text}" created')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFFA0B0B).withValues(alpha: 0.9),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
}