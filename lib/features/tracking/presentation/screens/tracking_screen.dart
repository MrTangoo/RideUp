import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/tracking_provider.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final String horseId;

  const TrackingScreen({
    super.key,
    required this.horseId,
  });

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  GoogleMapController? _mapController;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTracking();
    });
  }

  Future<void> _startTracking() async {
    final error = await ref
        .read(trackingControllerProvider.notifier)
        .startTracking(widget.horseId);

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      context.pop();
    }
  }

  Future<void> _stopTracking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminer l\'activité'),
        content: const Text('Voulez-vous terminer cette activité ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuer'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Terminer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final error = await ref
          .read(trackingControllerProvider.notifier)
          .stopTracking();

      if (mounted) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else {
          context.pop();
        }
      }
    }
  }

  void _togglePause() {
    if (_isPaused) {
      ref.read(trackingControllerProvider.notifier).resumeTracking();
    } else {
      ref.read(trackingControllerProvider.notifier).pauseTracking();
    }
    setState(() => _isPaused = !_isPaused);
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingControllerProvider);
    final theme = Theme.of(context);
    final stats = trackingState.stats;

    // Create polyline from points
    final polyline = trackingState.points.isNotEmpty
        ? Polyline(
            polylineId: const PolylineId('route'),
            points: trackingState.points
                .map((p) => LatLng(p.lat, p.lng))
                .toList(),
            color: theme.colorScheme.primary,
            width: 5,
          )
        : null;

    // Get current position for camera
    final currentPosition = trackingState.points.isNotEmpty
        ? trackingState.points.last
        : null;

    return Scaffold(
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentPosition != null
                  ? LatLng(currentPosition.lat, currentPosition.lng)
                  : const LatLng(48.8566, 2.3522), // Paris default
              zoom: 17,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            polylines: polyline != null ? {polyline} : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Stats overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'Distance',
                          value: Formatters.formatDistance(
                            stats['distance'] ?? 0.0,
                          ),
                        ),
                        _StatItem(
                          label: 'Vitesse',
                          value: Formatters.formatSpeed(
                            stats['avgSpeed'] ?? 0.0,
                          ),
                        ),
                        _StatItem(
                          label: 'Durée',
                          value: Formatters.formatDuration(
                            Duration(seconds: stats['durationSeconds'] ?? 0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'Vitesse max',
                          value: Formatters.formatSpeed(
                            stats['maxSpeed'] ?? 0.0,
                          ),
                        ),
                        _StatItem(
                          label: 'Dénivelé',
                          value: '${(stats['elevationGain'] ?? 0.0).toStringAsFixed(0)} m',
                        ),
                        _StatItem(
                          label: 'Calories',
                          value: Formatters.formatCalories(
                            stats['calories'] ?? 0.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Controls
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Pause/Resume button
                FloatingActionButton(
                  onPressed: _togglePause,
                  heroTag: 'pause',
                  child: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                ),

                // Stop button
                FloatingActionButton.extended(
                  onPressed: _stopTracking,
                  heroTag: 'stop',
                  backgroundColor: theme.colorScheme.error,
                  icon: const Icon(Icons.stop),
                  label: const Text('Terminer'),
                ),

                // Center button
                FloatingActionButton(
                  onPressed: () {
                    if (currentPosition != null && _mapController != null) {
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLng(
                          LatLng(currentPosition.lat, currentPosition.lng),
                        ),
                      );
                    }
                  },
                  heroTag: 'center',
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
