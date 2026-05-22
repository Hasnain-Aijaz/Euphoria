import 'package:flutter/foundation.dart';

class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final String? profileImgUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.profileImgUrl,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'] ?? 'USER',
      profileImgUrl: json['profileImgUrl'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'profileImgUrl': profileImgUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'ADMIN';
}

class Artist {
  final int id;
  final String name;
  final String bio;
  final String imgUrl;

  Artist({
    required this.id, 
    required this.name, 
    required this.bio, 
    required this.imgUrl
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      name: json['name'],
      bio: json['bio'] ?? '',
      imgUrl: json['imgUrl'] ?? '',
    );
  }
}

class Album {
  final int id;
  final String title;
  final String coverImgUrl;
  final Artist artist;
  final DateTime? releaseDate;

  Album({
    required this.id,
    required this.title,
    required this.coverImgUrl,
    required this.artist,
    this.releaseDate,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      title: json['title'],
      coverImgUrl: json['coverImgUrl'] ?? '',
      artist: Artist.fromJson(json['artist']),
      releaseDate: json['releaseDate'] != null ? DateTime.parse(json['releaseDate']) : null,
    );
  }
}

class Song {
  final int id;
  final String title;
  final String genre;
  final int durationSeconds;
  final String audioUrl;
  final String? thumbnailUrl;
  final int playCount;
  final Artist artist;
  final Album? album;

  Song({
    required this.id,
    required this.title,
    required this.genre,
    required this.durationSeconds,
    required this.audioUrl,
    this.thumbnailUrl,
    required this.playCount,
    required this.artist,
    this.album,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    // Handle both Song entity (with artist object) and SongSummaryResponse (with artistName string)
    Artist artist;
    if (json['artist'] != null) {
      artist = Artist.fromJson(json['artist']);
    } else {
      artist = Artist(
        id: 0,
        name: json['artistName'] ?? 'Unknown Artist',
        bio: '',
        imgUrl: '',
      );
    }

    return Song(
      id: json['id'],
      title: json['title'],
      genre: json['genre'] ?? '',
      durationSeconds: json['durationSeconds'] ?? 0,
      audioUrl: json['audioUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      playCount: json['playCount'] ?? 0,
      artist: artist,
      album: json['album'] != null ? Album.fromJson(json['album']) : null,
    );
  }

  String get durationFormatted {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get artistName => artist.name;
}

class Playlist {
  final int id;
  final String name;
  final String? description;
  final int? userId;
  final String? username;
  final List<Song> songs;
  final DateTime? createdAt;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    this.userId,
    this.username,
    required this.songs,
    this.createdAt,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'] ?? json['playlistName'] ?? '',
      description: json['description'],
      userId: json['userId'],
      username: json['username'],
      songs: (json['songs'] as List? ?? [])
          .map((s) => Song.fromJson(s))
          .toList(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
