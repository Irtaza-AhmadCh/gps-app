import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/logger_service.dart';
import '../../repository/hike_repository.dart';
import '../../services/elevation_service.dart';
import '../model/hike.dart';
import '../model/track_point.dart';

/// Controller for Hike Summary/Replay View
/// Manages timeline playback and synchronization of map, chart, and stats
class HikeReplayController extends GetxController {
  final HikeRepository _repository = HikeRepository();
  final ElevationService _elevationService = ElevationService.instance;

  // Observable state
  final Rx<Hike?> hike = Rx<Hike?>(null);
  final RxInt currentIndex = 0.obs;
  final RxBool isPlaying = false.obs;
  final RxDouble playbackSpeed = 1.0.obs;

  Timer? _playbackTimer;

  // Computed values
  List<double> get smoothedElevations {
    if (hike.value == null) return [];
    return _elevationService.getSmoothedElevations(hike.value!.points);
  }

  TrackPoint? get currentPoint {
    if (hike.value == null || currentIndex.value >= hike.value!.points.length) {
      return null;
    }
    return hike.value!.points[currentIndex.value];
  }

  double get currentDistance {
    if (hike.value == null) return 0.0;
    return _repository.calculateDistanceUpToIndex(
      hike.value!.points,
      currentIndex.value,
    );
  }

  ({double gain, double loss}) get currentElevation {
    if (hike.value == null) {
      return (gain: 0.0, loss: 0.0);
    }
    return _elevationService.calculateElevationChangeUpToIndex(
      hike.value!.points,
      currentIndex.value,
    );
  }

  Duration get currentDuration {
    if (hike.value == null || currentIndex.value == 0) {
      return Duration.zero;
    }
    final startTime = hike.value!.points[0].timestamp;
    final currentTime = hike.value!.points[currentIndex.value].timestamp;
    return currentTime.difference(startTime);
  }

  @override
  void onInit() {
    super.onInit();
    LoggerService.i('HikeReplayController.onInit: initializing');
    _loadHike();
  }

  @override
  void onClose() {
    LoggerService.i('HikeReplayController.onClose: cancelling playback timer');
    _playbackTimer?.cancel();
    super.onClose();
  }

  /// Load hike from arguments
  void _loadHike() {
    LoggerService.i(
      'HikeReplayController._loadHike: loading hike from arguments',
    );
    final hikeArg = Get.arguments;
    if (hikeArg is Hike) {
      hike.value = hikeArg;
      currentIndex.value = 0;
      LoggerService.i(
        'HikeReplayController._loadHike: hike loaded - ${hike.value?.name}',
      );
    } else {
      LoggerService.e(
        'HikeReplayController._loadHike: No hike data provided in arguments',
      );
      Get.snackbar(
        'Error',
        'No hike data provided',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    }
  }

  /// Scrub to specific index
  void scrubToIndex(int index) {
    if (hike.value == null) return;

    final maxIndex = hike.value!.points.length - 1;
    currentIndex.value = index.clamp(0, maxIndex);
  }

  /// Scrub to specific progress (0.0 to 1.0)
  void scrubToProgress(double progress) {
    if (hike.value == null) return;

    final maxIndex = hike.value!.points.length - 1;
    final index = (progress * maxIndex).round();
    scrubToIndex(index);
  }

  /// Start replay playback
  void play() {
    if (hike.value == null || isPlaying.value) return;

    LoggerService.i('HikeReplayController.play: starting playback');
    isPlaying.value = true;

    // Calculate interval based on playback speed
    final intervalMs = (100 / playbackSpeed.value).round();

    _playbackTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (currentIndex.value < hike.value!.points.length - 1) {
        currentIndex.value++;
      } else {
        pause();
      }
    });
  }

  /// Pause replay playback
  void pause() {
    if (isPlaying.value) {
      LoggerService.i('HikeReplayController.pause: pausing playback');
    }
    isPlaying.value = false;
    _playbackTimer?.cancel();
  }

  /// Toggle play/pause
  void togglePlayPause() {
    LoggerService.i(
      'HikeReplayController.togglePlayPause: current status $isPlaying',
    );
    if (isPlaying.value) {
      pause();
    } else {
      play();
    }
  }

  /// Reset to beginning
  void reset() {
    pause();
    currentIndex.value = 0;
  }

  /// Skip to end
  void skipToEnd() {
    if (hike.value == null) return;
    pause();
    currentIndex.value = hike.value!.points.length - 1;
  }

  /// Set playback speed
  void setPlaybackSpeed(double speed) {
    LoggerService.i(
      'HikeReplayController.setPlaybackSpeed: setting speed to $speed',
    );
    playbackSpeed.value = speed.clamp(0.5, 5.0);

    // Restart timer if playing
    if (isPlaying.value) {
      pause();
      play();
    }
  }

  /// Delete current hike
  Future<void> deleteHike() async {
    if (hike.value == null) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Hike'),
        content: const Text('Are you sure you want to delete this hike?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        LoggerService.i(
          'HikeReplayController.deleteHike: deleting hike ${hike.value?.id}',
        );
        await _repository.deleteHike(hike.value!.id);
        LoggerService.i(
          'HikeReplayController.deleteHike: hike deleted successfully',
        );
        Get.snackbar(
          'Success',
          'Hike deleted',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back(); // Return to home
      } catch (e, stackTrace) {
        LoggerService.e(
          'HikeReplayController.deleteHike: failed to delete hike: $e',
          error: e,
          stackTrace: stackTrace,
        );
        Get.snackbar(
          'Error',
          'Failed to delete hike: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
