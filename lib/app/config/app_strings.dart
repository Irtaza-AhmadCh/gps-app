/// App strings with GetX localization support
class AppStrings {
  AppStrings._();

  // App
  static String get appName => 'Hiking Tracker';

  // Home Screen
  static String get homeTitle => 'My Hikes';
  static String get startHike => 'Start Hike';
  static String get noHikesYet => 'No hikes yet. Start your first adventure!';
  static String get gpsPermissionRequired =>
      'GPS permission required to track hikes';
  static String get enableGps => 'Enable GPS';
  static String get deleteHike => 'Delete Hike';
  static String get confirmDelete =>
      'Are you sure you want to delete this hike?';
  static String get cancel => 'Cancel';
  static String get delete => 'Delete';

  // Live Tracking Screen
  static String get liveTracking => 'Live Tracking';
  static String get distance => 'Distance';
  static String get elevation => 'Elevation';
  static String get duration => 'Duration';
  static String get elevationGain => 'Gain';
  static String get elevationLoss => 'Loss';
  static String get pause => 'Pause';
  static String get resume => 'Resume';
  static String get stop => 'Stop';
  static String get saveHike => 'Save Hike';
  static String get enterHikeName => 'Enter hike name';
  static String get save => 'Save';
  static String get discardHike => 'Discard Hike';
  static String get confirmDiscard =>
      'Are you sure you want to discard this hike?';
  static String get discard => 'Discard';

  // Hike Summary Screen
  static String get hikeSummary => 'Hike Summary';
  static String get replay => 'Replay';
  static String get elevationProfile => 'Elevation Profile';
  static String get stats => 'Stats';
  static String get totalDistance => 'Total Distance';
  static String get totalDuration => 'Total Duration';
  static String get avgSpeed => 'Avg Speed';
  static String get maxElevation => 'Max Elevation';
  static String get minElevation => 'Min Elevation';

  // Map
  static String get mapNotAvailableOffline =>
      'Map not available offline.\nPre-cache area before hiking.';
  static String get loadingMap => 'Loading map...';

  // Permissions
  static String get locationPermissionDenied => 'Location permission denied';
  static String get locationPermissionDeniedForever =>
      'Location permission denied permanently. Please enable in settings.';
  static String get openSettings => 'Open Settings';

  // Errors
  static String get errorSavingHike => 'Error saving hike';
  static String get errorLoadingHikes => 'Error loading hikes';
  static String get errorStartingTracking => 'Error starting GPS tracking';
  static String get errorGpsUnavailable => 'GPS unavailable';

  // Units
  static String get meters => 'm';
  static String get kilometers => 'km';
  static String get metersPerSecond => 'm/s';
  static String get kilometersPerHour => 'km/h';
}
