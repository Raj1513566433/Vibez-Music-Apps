import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibez/album_art_widget.dart';
import 'package:vibez/mini_player.dart';
import 'package:vibez/music_service.dart';
import 'package:vibez/player_screen.dart';
import 'package:vibez/song.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Song> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query, MusicService musicService) {
    setState(() {
      _isSearching = query.isNotEmpty;
      _searchResults = musicService.searchSongs(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<MusicService>(
      builder: (context, musicService, child) {
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
                  _buildSearchBar(musicService, screenWidth),
                  Expanded(
                    child: _buildResults(musicService, screenWidth),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Search',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(MusicService musicService, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: const Color(0xFFFF6B6B),
              decoration: InputDecoration(
                hintText: 'Songs, artists, albums...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('', musicService);
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                border: InputBorder.none,
              ),
              onChanged: (value) => _performSearch(value, musicService),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults(MusicService musicService, double screenWidth) {
    if (!_isSearching) {
      return _buildRecentSearches(musicService, screenWidth);
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 18),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          return _buildSongItem(_searchResults[index], musicService);
        },
      ),
    );
  }

  Widget _buildRecentSearches(MusicService musicService, double screenWidth) {
    final recentSongs = musicService.getPlaylistSongs('recently').take(10).toList();

    if (recentSongs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 80, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              'Discover your music',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              'Recent History',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: recentSongs.length,
              itemBuilder: (context, index) {
                return _buildSongItem(recentSongs[index], musicService);
              },
            ),
          ),
        ],
      ),
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
            MaterialPageRoute(builder: (context) => const PlayerScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isCurrentSong ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              AlbumArtWidget(
                songId: song.id,
                size: 52,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: TextStyle(
                        color: isCurrentSong ? const Color(0xFFFF6B6B) : Colors.white,
                        fontSize: 16,
                        fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${song.artist} • ${song.album}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                song.durationString,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}