import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Videorecordings extends StatefulWidget {
  const Videorecordings({super.key});

  @override
  State<Videorecordings> createState() => _VideorecordingsState();
}

class _VideorecordingsState extends State<Videorecordings> {
  late YoutubePlayerController _controller;
  List<String> _playlistVideoIds = [];
  List<Map<String, String>> _playlistVideos = [];
  int _currentVideoIndex = 0;
  bool _isPlayerReady = false;
  bool _isLoading = true;
  String? _error;

  // Playlist ID extracted from the URL
  final String playlistId = 'PLVR4vfgvLpdWg1wtc3rI2tElDxUwu5i4O';
  
  // Replace 'YOUR_ACTUAL_API_KEY_HERE' with the API key you got from Google Cloud Console
  // Example: 'AIzaSyBvOkBownzG4IKHQ3s2bePn7KjnwMxOyXg'
  final String youtubeApiKey = 'AIzaSyCcf1LUgIJ7lzduDJJlcLDOX81E_wWabmY';
  
  // Fallback video IDs in case API fails
  final List<String> fallbackVideoIds = [
    'mrrC2hNd0DU?si',
    'ScMzIvxBSi4', 
    'kJQP7kiw5Fk',
    'fJ9rUzIMcZQ',
  ];

  @override
  void initState() {
    super.initState();
    _fetchPlaylistVideos();
  }

  Future<void> _fetchPlaylistVideos() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Try to fetch from YouTube API first
      if (youtubeApiKey != 'YOUR_YOUTUBE_API_KEY_HERE') {
        await _fetchFromYouTubeAPI();
      } else {
        // Use fallback videos if no API key is provided
        _useFallbackVideos();
      }
      
      if (_playlistVideoIds.isNotEmpty) {
        _initializePlayer();
      }
    } catch (e) {
      print('Error fetching playlist: $e');
      setState(() {
        _error = 'Failed to load playlist. Using fallback videos.';
      });
      _useFallbackVideos();
      _initializePlayer();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFromYouTubeAPI() async {
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/playlistItems'
      '?part=snippet'
      '&playlistId=$playlistId'
      '&maxResults=50'
      '&key=$youtubeApiKey'
    );

    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List;
      
      _playlistVideoIds = items.map<String>((item) {
        return item['snippet']['resourceId']['videoId'] as String;
      }).toList();
      
      _playlistVideos = items.map<Map<String, String>>((item) {
        return {
          'id': item['snippet']['resourceId']['videoId'] as String,
          'title': item['snippet']['title'] as String,
          'description': item['snippet']['description'] as String? ?? '',
        };
      }).toList();
    } else {
      throw Exception('Failed to load playlist from YouTube API');
    }
  }

  void _useFallbackVideos() {
    _playlistVideoIds = fallbackVideoIds;
    _playlistVideos = fallbackVideoIds.asMap().entries.map((entry) {
      return {
        'id': entry.value,
        'title': 'Sample Video ${entry.key + 1}',
        'description': 'This is a sample video. Configure YouTube API key to load actual playlist.',
      };
    }).toList();
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: _playlistVideoIds[_currentVideoIndex],
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        captionLanguage: 'en',
      ),
    );
    _controller.addListener(_listener);
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }

  void _playNext() {
    if (_currentVideoIndex < _playlistVideoIds.length - 1) {
      setState(() {
        _currentVideoIndex++;
      });
      _controller.load(_playlistVideoIds[_currentVideoIndex]);
    }
  }

  void _playPrevious() {
    if (_currentVideoIndex > 0) {
      setState(() {
        _currentVideoIndex--;
      });
      _controller.load(_playlistVideoIds[_currentVideoIndex]);
    }
  }

  void _playVideoAtIndex(int index) {
    setState(() {
      _currentVideoIndex = index;
    });
    _controller.load(_playlistVideoIds[index]);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(150),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 50),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.asset(
                        'assets/image1.jpeg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Gate Sentinel",
                      style: GoogleFonts.acme(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'Loading playlist...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {
          _playNext();
        },
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(150),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 50),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.asset(
                        'assets/image1.jpeg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Gate Sentinel",
                      style: GoogleFonts.acme(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            // YouTube Player
            player,
            
            // Error message if any
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.orange[100],
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.orange),
                  textAlign: TextAlign.center,
                ),
              ),
            
            // Playlist Controls
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: _currentVideoIndex > 0 ? _playPrevious : null,
                    icon: Icon(
                      Icons.skip_previous,
                      color: _currentVideoIndex > 0 ? Colors.blue : Colors.grey,
                      size: 30,
                    ),
                  ),
                  Text(
                    'Video ${_currentVideoIndex + 1} of ${_playlistVideoIds.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    onPressed: _currentVideoIndex < _playlistVideoIds.length - 1 ? _playNext : null,
                    icon: Icon(
                      Icons.skip_next,
                      color: _currentVideoIndex < _playlistVideoIds.length - 1 ? Colors.blue : Colors.grey,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            
            // Playlist Container
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF333333).withAlpha(235),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security Video Playlist',
                      style: GoogleFonts.acme(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _playlistVideoIds.length,
                        itemBuilder: (context, index) {
                          final isCurrentVideo = index == _currentVideoIndex;
                          final video = _playlistVideos.isNotEmpty ? _playlistVideos[index] : null;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isCurrentVideo 
                                  ? Colors.blue.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: isCurrentVideo 
                                  ? Border.all(color: Colors.blue, width: 2)
                                  : null,
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 60,
                                height: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[800],
                                ),
                                child: Icon(
                                  isCurrentVideo ? Icons.play_circle_filled : Icons.play_circle_outline,
                                  color: isCurrentVideo ? Colors.blue : Colors.white70,
                                  size: 30,
                                ),
                              ),
                              title: Text(
                                video?['title'] ?? 'Video ${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isCurrentVideo ? FontWeight.bold : FontWeight.normal,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                'Video ID: ${_playlistVideoIds[index]}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              onTap: () => _playVideoAtIndex(index),
                              trailing: isCurrentVideo
                                  ? const Icon(
                                      Icons.volume_up,
                                      color: Colors.blue,
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// // Custom AppBar Shape
// class CustomAppBarClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.lineTo(0, size.height);
//     path.lineTo(size.width / 2, size.height - 80);
//     path.lineTo(size.width, size.height);
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
