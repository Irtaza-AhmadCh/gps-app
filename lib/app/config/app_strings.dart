/// App strings with GetX localization support
class AppStrings {
  AppStrings._();

  // App
  static String get appName => 'Hiking Tracker';

  // Splash
  static String get splashTitle => 'Explore with Trust';

  // Onboarding
  static String get onboarding1Title => 'Track your journeys';
  static String get onboarding1Desc =>
      'Track your journeys and hikes effortlessly';
  static String get onboarding2Title => 'Safety First';
  static String get onboarding2Desc => 'Your location stays private and secure';
  static String get onboarding3Title => 'Community';
  static String get onboarding3Desc =>
      'Explore destinations and connect with others';
  static String get onboarding4Title => 'Permission';
  static String get onboarding4Desc =>
      'We only access location during activities';
  static String get getStarted => 'Get Started';
  static String get skip => 'Skip';
  static String get continueText => 'Continue';

  // Auth - Shared
  static String get email => 'Email';
  static String get password => 'Password';
  static String get confirmPassword => 'Confirm Password';
  static String get forgotPassword => 'Forgot password?';
  static String get login => 'Login';
  static String get signup => 'Sign Up';
  static String get alreadyHaveAccount => 'Already have an account? Login';
  static String get dontHaveAccount => 'Don\'t have an account? Sign Up';

  // Auth - Signup
  static String get fullName => 'Full Name';
  static String get passwordStrength => 'Password strength';
  static String get termsAndPrivacy => 'I agree to Terms & Privacy';
  static String get createAccount => 'Create Account';
  static String get profilePicture => 'Profile Picture';
  static String get gender => 'Gender';
  static String get phoneNumber => 'Phone Number';
  static String get optional => 'Optional';
  static String get step1 => 'Step 1 of 2';
  static String get step2 => 'Step 2 of 2';

  // Permission
  static String get enableLocation => 'Enable Location';
  static String get permissionExplanation =>
      'We need your location to track your hikes and ensure your safety. We only access it when you are recording an activity.';

  // Dashboard
  static String get dashboard => 'Dashboard';
  static String get startHike => 'Start Hike';
  static String get gpsStatus => 'GPS Status';
  static String get recentActivity => 'Recent Activity';

  // Profile
  static String get profile => 'Profile';
  static String get editProfile => 'Edit Profile';
  static String get privacy => 'Privacy';
  static String get about => 'About';
  static String get terms => 'Terms';
  static String get logout => 'Logout';

  // Existing Strings (Kept for compatibility)
  static String get homeTitle => 'My Hikes';
  static String get noHikesYet => 'No hikes yet. Start your first adventure!';
  static String get gpsPermissionRequired =>
      'GPS permission required to track hikes';
  static String get enableGps => 'Enable GPS';
  static String get deleteHike => 'Delete Hike';
  static String get confirmDelete =>
      'Are you sure you want to delete this hike?';
  static String get cancel => 'Cancel';
  static String get delete => 'Delete';
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
  static String get hikeSummary => 'Hike Summary';
  static String get replay => 'Replay';
  static String get elevationProfile => 'Elevation Profile';
  static String get stats => 'Stats';
  static String get totalDistance => 'Total Distance';
  static String get totalDuration => 'Total Duration';
  static String get avgSpeed => 'Avg Speed';
  static String get maxElevation => 'Max Elevation';
  static String get minElevation => 'Min Elevation';
  static String get mapNotAvailableOffline =>
      'Map not available offline.\\nPre-cache area before hiking.';
  static String get loadingMap => 'Loading map...';
  static String get locationPermissionDenied => 'Location permission denied';
  static String get locationPermissionDeniedForever =>
      'Location permission denied permanently. Please enable in settings.';
  static String get openSettings => 'Open Settings';
  static String get errorSavingHike => 'Error saving hike';
  static String get errorLoadingHikes => 'Error loading hikes';
  static String get errorStartingTracking => 'Error starting GPS tracking';
  static String get errorGpsUnavailable => 'GPS unavailable';
  static String get meters => 'm';
  static String get kilometers => 'km';
  static String get metersPerSecond => 'm/s';
  static String get kilometersPerHour => 'km/h';

  // New Strings for Redesigned UI
  // Tracking States
  static String get readyToStart => 'Ready to start tracking';
  static String get tracking => 'Tracking';
  static String get paused => 'Paused';
  static String get tapToStart => 'Tap to start your hike';
  static String get gpsReady => 'GPS Ready';
  static String get gpsSearching => 'Searching for GPS...';
  static String get gpsWeak => 'Weak GPS Signal';

  // Hike Completion
  static String get hikeCompleted => 'Hike Completed!';
  static String get congratulations => 'Congratulations!';
  static String get completionMessage => 'You\'ve completed an amazing hike';
  static String get addDetails => 'Add Details';
  static String get skipForNow => 'Skip for now';
  static String get viewHike => 'View Hike';

  // Add Hike Details
  static String get hikeTitle => 'Hike Title';
  static String get enterTitle => 'Enter hike title';
  static String get addImages => 'Add Images';
  static String get addPlace => 'Add Place';
  static String get placeName => 'Place Name';
  static String get placeDescription => 'Description';
  static String get enterPlaceName => 'Enter place name';
  static String get enterPlaceDescription => 'Enter description';
  static String get placesVisited => 'Places Visited';
  static String get noPlacesAdded => 'No places added yet';
  static String get saveAndView => 'Save & View Hike';

  // Hikes List
  static String get myHikes => 'My Hikes';
  static String get hikeHistory => 'Hike History';
  static String get noHikesMessage => 'No hikes yet — start your first one';

  // Hike Details
  static String get routePreview => 'Route Preview';
  static String get hikeStats => 'Hike Stats';
  static String get places => 'Places';
}
