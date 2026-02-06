import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibez/playlist.dart';
import 'dart:convert';

import 'package:vibez/song.dart';

class MusicService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  
  List<Song> _allSongs = [];
  List<Playlist> _playlists = [];
  Song? _currentSong;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isShuffle = false;
  LoopMode _loopMode = LoopMode.off;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  List<Song> _currentQueue = [];
  Set<String> _favoriteSongIds = {};
  bool _isLoading = false;
  bool _hasPermission = false; // ADD THIS
  
  // Getters
  AudioPlayer get audioPlayer => _audioPlayer;
  List<Song> get allSongs => _allSongs;
  List<Playlist> get playlists => _playlists;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isShuffle => _isShuffle;
  LoopMode get loopMode => _loopMode;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  List<Song> get currentQueue => _currentQueue;
  Set<String> get favoriteSongIds => _favoriteSongIds;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission; // ADD THIS
  
  MusicService() {
    _initializeService();
  }
  
  Future<void> _initializeService() async {
    // Check permission first
    _hasPermission = await checkPermission();
    notifyListeners();
    
    if (_hasPermission) {
      // Load songs from device storage
      await loadSongsFromDevice();
      
      // Load playlists from storage
      await _loadPlaylists();
      
      // Load favorites from storage
      await _loadFavorites();
    }
    
    // Setup audio player listeners
    _audioPlayer.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });
    
    _audioPlayer.durationStream.listen((duration) {
      _totalDuration = duration ?? Duration.zero;
      notifyListeners();
    });
    
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      
      // Auto play next song when current song ends
      if (state.processingState == ProcessingState.completed) {
        playNext();
      }
      
      notifyListeners();
    });
  }
  
  // Check if permission is granted
  Future<bool> checkPermission() async {
    try {
      return await _audioQuery.checkAndRequest();
    } catch (e) {
      debugPrint('Error checking permission: $e');
      return false;
    }
  }
  
  // Request storage permission
  Future<bool> requestPermission() async {
    try {
      _hasPermission = await _audioQuery.permissionsRequest();
      notifyListeners();
      return _hasPermission;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }
  
  // Refresh songs - ADD THIS METHOD
  Future<void> refreshSongs() async {
    _hasPermission = await requestPermission();
    
    if (_hasPermission) {
      await loadSongsFromDevice();
      await _loadPlaylists();
      await _loadFavorites();
    }
    
    notifyListeners();
  }
  
  // Load songs from device storage
  Future<void> loadSongsFromDevice() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Query all songs from device
      final List<SongModel> deviceSongs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      
      // Convert SongModel to Song
      _allSongs = deviceSongs.map((songModel) {
        return Song(
          id: songModel.id.toString(),
          title: songModel.title,
          artist: songModel.artist ?? 'Unknown Artist',
          album: songModel.album ?? 'Unknown Album',
          imagePath: '', // Will load dynamically using getAlbumArt
          audioPath: songModel.uri ?? '',
          duration: Duration(milliseconds: songModel.duration ?? 0),
        );
      }).toList();
      
      _currentQueue = List.from(_allSongs);
      
      _isLoading = false;
      notifyListeners();
      
      debugPrint('Loaded ${_allSongs.length} songs from device');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading songs: $e');
    }
  }
  
  // Get album art for a song
  Future<Uint8List?> getAlbumArt(int songId) async {
    try {
      return await _audioQuery.queryArtwork(
        songId,
        ArtworkType.AUDIO,
        quality: 100,
      );
    } catch (e) {
      debugPrint('Error getting album art: $e');
      return null;
    }
  }
  
  Future<void> _loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final String? playlistsJson = prefs.getString('playlists');
    
    if (playlistsJson != null) {
      final List<dynamic> decoded = json.decode(playlistsJson);
      _playlists = decoded.map((json) => Playlist.fromJson(json)).toList();
    } else {
      // Create default playlists
      _playlists = [
        Playlist(
          id: 'recently',
          name: 'Recently',
          songIds: [],
          isSystemPlaylist: true,
        ),
        Playlist(
          id: 'lyrics',
          name: 'Songs With Lyrics',
          songIds: [],
          isSystemPlaylist: true,
        ),
      ];
    }
    notifyListeners();
  }
  
  Future<void> _savePlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = json.encode(
      _playlists.map((p) => p.toJson()).toList(),
    );
    await prefs.setString('playlists', playlistsJson);
  }
  
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favorites = prefs.getStringList('favorites');
    if (favorites != null) {
      _favoriteSongIds = favorites.toSet();
    }
    notifyListeners();
  }
  
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favoriteSongIds.toList());
  }
  
  // Playback controls
  Future<void> playSong(Song song, {List<Song>? queue}) async {
    _currentSong = song;
    
    if (queue != null) {
      _currentQueue = queue;
      _currentIndex = queue.indexWhere((s) => s.id == song.id);
    } else {
      _currentIndex = _allSongs.indexWhere((s) => s.id == song.id);
    }
    
    // Add to recently played
    await _addToRecentlyPlayed(song);
    
    try {
      // Play actual audio file from device
      await _audioPlayer.setFilePath(song.audioPath);
      await _audioPlayer.play();
      _isPlaying = true;
    } catch (e) {
      debugPrint('Error playing song: $e');
      _isPlaying = false;
    }
    
    notifyListeners();
  }
  
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }
  
  Future<void> playNext() async {
    if (_currentQueue.isEmpty) return;
    
    if (_isShuffle) {
      final random = DateTime.now().millisecondsSinceEpoch % _currentQueue.length;
      _currentIndex = random;
    } else {
      _currentIndex = (_currentIndex + 1) % _currentQueue.length;
    }
    
    await playSong(_currentQueue[_currentIndex], queue: _currentQueue);
  }
  
  Future<void> playPrevious() async {
    if (_currentQueue.isEmpty) return;
    
    _currentIndex = (_currentIndex - 1 + _currentQueue.length) % _currentQueue.length;
    await playSong(_currentQueue[_currentIndex], queue: _currentQueue);
  }
  
  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }
  
  Future<void> seekRelative(Duration offset) async {
    final newPosition = _currentPosition + offset;
    if (newPosition < Duration.zero) {
      await seekTo(Duration.zero);
    } else if (newPosition > _totalDuration) {
      await seekTo(_totalDuration);
    } else {
      await seekTo(newPosition);
    }
  }
  
  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }
  
  void toggleLoopMode() {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        _audioPlayer.setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        _audioPlayer.setLoopMode(LoopMode.off);
        break;
    }
    notifyListeners();
  }
  
  // Favorites management
  bool isFavorite(String songId) {
    return _favoriteSongIds.contains(songId);
  }
  
  Future<void> toggleFavorite(String songId) async {
    if (_favoriteSongIds.contains(songId)) {
      _favoriteSongIds.remove(songId);
    } else {
      _favoriteSongIds.add(songId);
    }
    await _saveFavorites();
    notifyListeners();
  }
  
  List<Song> getFavoriteSongs() {
    return _allSongs.where((song) => _favoriteSongIds.contains(song.id)).toList();
  }
  
  // Playlist management
  Future<void> createPlaylist(String name) async {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songIds: [],
      isSystemPlaylist: false,
    );
    
    _playlists.add(playlist);
    await _savePlaylists();
    notifyListeners();
  }
  
  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((p) => p.id == playlistId && !p.isSystemPlaylist);
    await _savePlaylists();
    notifyListeners();
  }
  
  Future<void> addSongsToPlaylist(String playlistId, List<String> songIds) async {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    
    for (var songId in songIds) {
      if (!playlist.songIds.contains(songId)) {
        playlist.songIds.add(songId);
      }
    }
    
    await _savePlaylists();
    notifyListeners();
  }
  
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    playlist.songIds.remove(songId);
    await _savePlaylists();
    notifyListeners();
  }
  
  List<Song> getPlaylistSongs(String playlistId) {
    if (playlistId == 'favorites') {
      return getFavoriteSongs();
    }
    
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    return _allSongs.where((song) => playlist.songIds.contains(song.id)).toList();
  }
  
  Playlist? getPlaylistById(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Future<void> _addToRecentlyPlayed(Song song) async {
    final recentlyPlaylist = _playlists.firstWhere(
      (p) => p.id == 'recently',
      orElse: () => Playlist(
        id: 'recently',
        name: 'Recently',
        songIds: [],
        isSystemPlaylist: true,
      ),
    );
    
    // Remove if already exists
    recentlyPlaylist.songIds.remove(song.id);
    
    // Add to the beginning
    recentlyPlaylist.songIds.insert(0, song.id);
    
    // Keep only last 50 songs
    if (recentlyPlaylist.songIds.length > 50) {
      recentlyPlaylist.songIds = recentlyPlaylist.songIds.take(50).toList();
    }
    
    await _savePlaylists();
  }
  
  // Search
  List<Song> searchSongs(String query) {
    if (query.isEmpty) return _allSongs;
    
    final lowerQuery = query.toLowerCase();
    return _allSongs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.artist.toLowerCase().contains(lowerQuery) ||
          song.album.toLowerCase().contains(lowerQuery);
    }).toList();
  }
  
  // Get songs by album
  List<Song> getSongsByAlbum(String album) {
    return _allSongs.where((song) => song.album == album).toList();
  }
  
  // Get unique albums
  List<String> getAlbums() {
    final albums = <String>{};
    for (var song in _allSongs) {
      albums.add(song.album);
    }
    return albums.toList()..sort();
  }
  
  // Get songs by artist
  List<Song> getSongsByArtist(String artist) {
    return _allSongs.where((song) => song.artist == artist).toList();
  }
  
  // Get unique artists
  List<String> getArtists() {
    final artists = <String>{};
    for (var song in _allSongs) {
      artists.add(song.artist);
    }
    return artists.toList()..sort();
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}