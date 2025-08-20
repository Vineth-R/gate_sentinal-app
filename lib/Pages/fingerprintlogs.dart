import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import '../Services/notification_service.dart';

// Alert model class
class Alert {
  final String id;
  final String description;
  final int timestamp;
  final String type;

  Alert({
    required this.id,
    required this.description,
    required this.timestamp,
    required this.type,
  });

  factory Alert.fromMap(String id, Map<dynamic, dynamic> data) {
    return Alert(
      id: id,
      description: data['description'] ?? '',
      timestamp: data['timestamp'] ?? 0,
      type: data['type'] ?? '',
    );
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);
}

class Fingerprintlogs extends StatefulWidget {
  const Fingerprintlogs({super.key});

  @override
  State<Fingerprintlogs> createState() => _FingerprintlogsState();
}

class _FingerprintlogsState extends State<Fingerprintlogs> {
  final DatabaseReference _alertsRef = FirebaseDatabase.instance
      .ref()
      .child('alerts')
      .child('7SmpYGZkm5VC5PGTVQlhVxA2ugy1');
  
  List<Alert> _alerts = [];
  StreamSubscription<DatabaseEvent>? _alertsSubscription;
  bool _isLoading = true;
  Alert? _latestAlert;
  final NotificationService _notificationService = NotificationService();
  Set<String> _processedAlertIds = {}; // Track processed alerts to avoid duplicate notifications

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _listenToAlerts();
  }

  @override
  void dispose() {
    _alertsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  void _listenToAlerts() {
    _alertsSubscription = _alertsRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final List<Alert> alerts = [];
        final List<Alert> newAlerts = [];
        
        data.forEach((key, value) {
          if (value is Map) {
            final alert = Alert.fromMap(key.toString(), value);
            alerts.add(alert);
            
            // Check if this is a new alert (not processed before)
            if (!_processedAlertIds.contains(alert.id)) {
              newAlerts.add(alert);
              _processedAlertIds.add(alert.id);
            }
          }
        });
        
        // Sort by timestamp (newest first)
        alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        newAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        setState(() {
          _alerts = alerts;
          _latestAlert = alerts.isNotEmpty ? alerts.first : null;
          _isLoading = false;
        });
        
        // Send push notifications for new alerts
        _handleNewAlerts(newAlerts);
        
        // Show in-app notification for the latest new alert
        if (newAlerts.isNotEmpty && mounted) {
          _showAlertNotification(newAlerts.first);
        }
      } else {
        setState(() {
          _alerts = [];
          _latestAlert = null;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _handleNewAlerts(List<Alert> newAlerts) async {
    if (newAlerts.isEmpty) return;

    if (newAlerts.length == 1) {
      // Single new alert
      final alert = newAlerts.first;
      await _notificationService.showMotionAlert(
        title: 'Motion Detected',
        description: alert.description,
        timestamp: alert.timestamp,
      );
    } else if (newAlerts.length > 1) {
      // Multiple new alerts
      await _notificationService.showMultipleAlertsNotification(newAlerts.length);
    }
  }

  void _showAlertNotification(Alert alert) {
    // Enhanced in-app notification
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'New Security Alert!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      alert.description,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'VIEW',
            textColor: Colors.white,
            onPressed: () {
              // Scroll to top to show the latest alert
              // You can add scroll controller if needed
            },
          ),
        ),
      );
    }
  }

  String _formatTimestamp(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hr ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(width: 8),
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
          // Latest Alert Banner (if any)
          if (_latestAlert != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border(
                  bottom: BorderSide(color: Colors.red[200]!),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[600], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latest Alert',
                          style: TextStyle(
                            color: Colors.red[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _latestAlert!.description,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _formatTimestamp(_latestAlert!.timestamp),
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Main Content Area
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 20.0),
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
                  Row(
                    children: [
                      Icon(Icons.notifications_active, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Security Alerts',
                        style: GoogleFonts.acme(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Real-time motion detection alerts',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Loading or Alerts List
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text(
                                  'Loading alerts...',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          )
                        : _alerts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.security,
                                      size: 64,
                                      color: Colors.white54,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No alerts yet',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Motion alerts will appear here',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _alerts.length,
                                itemBuilder: (context, index) {
                                  final alert = _alerts[index];
                                  final isLatest = index == 0;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: isLatest
                                          ? Colors.red.withOpacity(0.2)
                                          : Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: isLatest
                                          ? Border.all(color: Colors.red, width: 1)
                                          : null,
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: isLatest ? Colors.red : Colors.orange,
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        child: Icon(
                                          alert.type == 'motion_alert'
                                              ? Icons.directions_run
                                              : Icons.warning,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      title: Text(
                                        alert.description,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: isLatest
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatTimestamp(alert.timestamp),
                                            style: TextStyle(
                                              color: isLatest
                                                  ? Colors.red[300]
                                                  : Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            alert.type.replaceAll('_', ' ').toUpperCase(),
                                            style: TextStyle(
                                              color: isLatest
                                                  ? Colors.red[200]
                                                  : Colors.white60,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: isLatest
                                          ? Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Text(
                                                'NEW',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
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
    );
  }
}

// Custom AppBar Shape
class CustomAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width / 2, size.height - 80);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
