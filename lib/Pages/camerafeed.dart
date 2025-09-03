import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Camerafeed extends StatefulWidget {
  const Camerafeed({super.key});

  @override
  State<Camerafeed> createState() => _CamerafeedState();
}

class _CamerafeedState extends State<Camerafeed> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    const String videoId = 'SneMtI6e3a'; // 24/7 LoFi music stream (reliable)
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false, // Changed to false for better control
        mute: false,
        enableCaption: false,
        isLive: true,
        forceHD: false,
        loop: false,
        useHybridComposition: false, // Try false if having issues
        controlsVisibleAtStart: true, // Show controls initially
        hideControls: false,
      ),
    );

    _controller.addListener(() {
      if (mounted) {
        if (_controller.value.isReady && !_isPlayerReady) {
          setState(() {
            _isPlayerReady = true;
            _hasError = false;
          });
          print('YouTube Player is ready');
          
          // Try to play after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _controller.play();
            }
          });
        }

        if (_controller.value.hasError) {
          setState(() {
            _hasError = true;
            _errorMessage = _controller.value.errorCode.toString();
          });
          print('YouTube Player Error: ${_controller.value.errorCode}');
        }

        if (_controller.value.playerState == PlayerState.buffering) {
          print('Player is buffering...');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _retryPlayer() {
    setState(() {
      _hasError = false;
      _isPlayerReady = false;
    });
    _controller.reload();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(175),
        child: Container(
          color: Colors.white,
          child: SafeArea(
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
      ),
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF333333).withAlpha(235),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // YouTube Player with Error Handling
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 220, // Fixed height for consistency
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _hasError
                      ? _buildErrorWidget()
                      : _buildPlayerWidget(),
                ),
              ),
            ),
            
            // Status and Controls
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Status Row
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatusButton(
                              'Retry',
                              Icons.refresh,
                              _retryPlayer,
                            ),
                            
                            _buildStatusButton(
                              'Play',
                              Icons.play_arrow,
                              () => _controller.play(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    // Status Information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _isPlayerReady 
                                ? Icons.videocam 
                                : _hasError 
                                    ? Icons.error 
                                    : Icons.hourglass_empty,
                            size: 48,
                            color: _isPlayerReady 
                                ? Colors.green 
                                : _hasError 
                                    ? Colors.red 
                                    : Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _hasError 
                                ? 'Connection Error'
                                : _isPlayerReady 
                                    ? 'Live Camera Feed Active'
                                    : 'Loading Camera Feed...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _hasError 
                                ? 'Error: $_errorMessage\nTry using a real device or check internet connection'
                                : _isPlayerReady 
                                    ? 'Security monitoring is active'
                                    : 'Connecting to video stream...',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
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

  Widget _buildPlayerWidget() {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // Handle exit from fullscreen
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        onReady: () {
          print('Player is ready in widget');
        },
        onEnded: (metaData) {
          print('Video ended');
        },
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          const Expanded(
            child: Text(
              'Live Camera Feed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _retryPlayer,
          ),
        ],
      ),
      builder: (context, player) {
        return player;
      },
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to Load Video',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Error: $_errorMessage',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _retryPlayer,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String label, IconData icon, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}