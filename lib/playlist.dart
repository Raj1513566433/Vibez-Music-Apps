class Playlist {
  final String id;
  String name;
  List<String> songIds;
  final bool isSystemPlaylist;
  
  Playlist({
    required this.id,
    required this.name,
    required this.songIds,
    this.isSystemPlaylist = false,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songIds': songIds,
      'isSystemPlaylist': isSystemPlaylist,
    };
  }
  
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      songIds: List<String>.from(json['songIds']),
      isSystemPlaylist: json['isSystemPlaylist'] ?? false,
    );
  }
}