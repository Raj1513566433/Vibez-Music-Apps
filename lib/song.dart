class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String imagePath;
  final String audioPath;
  final Duration duration;
  
  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.imagePath,
    required this.audioPath,
    required this.duration,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'imagePath': imagePath,
      'audioPath': audioPath,
      'duration': duration.inSeconds,
    };
  }
  
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      imagePath: json['imagePath'],
      audioPath: json['audioPath'],
      duration: Duration(seconds: json['duration']),
    );
  }
  
  String get durationString {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}