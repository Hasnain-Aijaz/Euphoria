import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:euphoria/models/models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080'; 

  static Future<List<Artist>> fetchArtists() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/artists'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Artist.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Album>> fetchAlbums() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/albums'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Album.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Song>> fetchSongs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/songs'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Song.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Song>> fetchSongsByAlbum(int albumId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/songs/album/$albumId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Song.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Song>> fetchSongsByArtist(int artistId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/songs/artist/$artistId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Song.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Album>> fetchAlbumsByArtist(int artistId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/albums/artist/$artistId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Album.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Playlist>> fetchMyPlaylists() async {
    try {
      final token = await getToken();
      if (token == null) return [];
      final response = await http.get(
        Uri.parse('$baseUrl/playlists/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Playlist.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Song>> fetchLikedSongs() async {
    try {
      final token = await getToken();
      if (token == null) return [];
      final response = await http.get(
        Uri.parse('$baseUrl/liked-songs/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Song.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> createArtist({
    required String name,
    required String bio,
    required PlatformFile image,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/artists'));
      request.headers['Authorization'] = 'Bearer $token';

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          image.bytes!,
          filename: image.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath('image', image.path!));
      }
      
      request.fields['name'] = name;
      request.fields['bio'] = bio;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> createAlbum({
    required String title,
    required int artistId,
    required PlatformFile coverImage,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/albums'));
      request.headers['Authorization'] = 'Bearer $token';

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'cover',
          coverImage.bytes!,
          filename: coverImage.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath('cover', coverImage.path!));
      }

      request.fields['title'] = title;
      request.fields['artistId'] = artistId.toString();

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> uploadSong({
    required String title,
    required int artistId,
    required String genre,
    required int durationSeconds,
    required PlatformFile audioFile,
    PlatformFile? thumbnailFile,
    int? albumId,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/songs'));
      
      // Add Headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add JSON Metadata Part
      final songData = jsonEncode({
        'title': title,
        'artistId': artistId,
        'genre': genre,
        'durationSeconds': durationSeconds,
        'albumId': albumId,
      });

      request.files.add(http.MultipartFile.fromString(
        'song',
        songData,
        contentType: MediaType('application', 'json'),
      ));

      // Add Audio File
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'audio',
          audioFile.bytes!,
          filename: audioFile.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'audio',
          audioFile.path!,
        ));
      }

      // Add Thumbnail File
      if (thumbnailFile != null) {
        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes(
            'thumbnail',
            thumbnailFile.bytes!,
            filename: thumbnailFile.name,
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(
            'thumbnail',
            thumbnailFile.path!,
          ));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200 && response.statusCode != 201) {
        if (kDebugMode) {
          print('Upload Failed: ${response.statusCode}');
          print('Response Body: ${response.body}');
        }
      }

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        print('Upload Error: $e');
      }
      return false;
    }
  }

  static Future<List<Song>> fetchSongsByGenre(String genre) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/songs/genre/$genre'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Song.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Song>> searchSongs(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/songs/search?title=$query'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Song.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Artist>> searchArtists(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/artists/search?name=$query'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Artist.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Album>> searchAlbums(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/albums/search?title=$query'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Album.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final token = response.body;
        await _saveToken(token);
        return null; // No error
      } else {
        return _handleError(response);
      }
    } catch (e) {
      return 'Connection error. Is the backend running?';
    }
  }

  static Future<String?> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return null; // Success
      } else {
        return _handleError(response);
      }
    } catch (e) {
      return 'Connection error. Is the backend running?';
    }
  }

  static Future<User?> getMe() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<bool> createPlaylist({
    required String name,
    String description = '',
  }) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/playlists'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'playlistName': name,
          'description': description,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> addSongToPlaylist(int playlistId, int songId) async {
    try {
      final token = await getToken();
      if (token == null) return false;
      final response = await http.post(
        Uri.parse('$baseUrl/playlists/$playlistId/songs/$songId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> removeSongFromPlaylist(int playlistId, int songId) async {
    try {
      final token = await getToken();
      if (token == null) return false;
      final response = await http.delete(
        Uri.parse('$baseUrl/playlists/$playlistId/songs/$songId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deletePlaylist(int playlistId) async {
    try {
      final token = await getToken();
      if (token == null) return false;
      final response = await http.delete(
        Uri.parse('$baseUrl/playlists/$playlistId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> likeSong(int songId) async {
    try {
      final token = await getToken();
      if (token == null) return false;
      final response = await http.post(
        Uri.parse('$baseUrl/likes/songs/$songId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> unlikeSong(int songId) async {
    try {
      final token = await getToken();
      if (token == null) return false;
      final response = await http.delete(
        Uri.parse('$baseUrl/likes/songs/$songId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  static Future<List<int>> fetchLikedSongIds() async {
    try {
      final token = await getToken();
      if (token == null) return [];
      final response = await http.get(
        Uri.parse('$baseUrl/likes/songs'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => json['id'] as int).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  static String _handleError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data['message'] ?? 'An unexpected error occurred';
    } catch (_) {
      return 'Error: ${response.statusCode}';
    }
  }
}
