// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String failedToGetInitialLocation(Object error) {
    return 'Failed to get initial location: $error';
  }

  @override
  String get failedToEndRide => 'Failed to end ride.';

  @override
  String get rideInProgress => 'Ride in Progress';

  @override
  String get duration => 'DURATION';

  @override
  String get km => 'KM';

  @override
  String get kcal => 'KCAL';

  @override
  String get currentlyRiding => 'Currently Riding';

  @override
  String bike(Object bikeId) {
    return 'Bike #$bikeId';
  }

  @override
  String get closestParkingZone => 'Closest Parking Zone';

  @override
  String get searching => 'Searching...';

  @override
  String get endRide => 'End Ride';

  @override
  String get logIn => 'Log In';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get logInToContinueYourJourney => 'Log in to continue your journey.';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get pleaseEnterAValidEmail => 'Please enter a valid email';

  @override
  String get password => 'Password';

  @override
  String get passwordCannotBeEmpty => 'Password cannot be empty';

  @override
  String get loginFailedPleaseTryAgain => 'Login failed. Please try again.';

  @override
  String get accountVerifiedPleaseLogInToContinue =>
      'Account verified! Please log in to continue.';

  @override
  String get verificationFailed => 'Verification failed.';

  @override
  String get verification => 'Verification';

  @override
  String get enterYourCode => 'Enter Your Code';

  @override
  String get a4DigitCodeHasBeenSentToYourPhone =>
      'A 4-digit code has been sent to your phone.';

  @override
  String get pleaseEnterThe4DigitCode => 'Please enter the 4-digit code';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get verify => 'Verify';

  @override
  String get didntReceiveSms => 'Didn\'t receive SMS?';

  @override
  String get registrationFailedPleaseTryAgain =>
      'Registration failed. Please try again.';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createYourAccount => 'Create Your Account';

  @override
  String get joinGaraBikeToStartYourJourney =>
      'Join Gara Bike to start your journey.';

  @override
  String get username => 'Username';

  @override
  String get phoneNumber => 'Phone Number (e.g., +251...)';

  @override
  String get nidFanNumber => 'NID FAN number';

  @override
  String get nidFanNumberCannotBeEmpty => 'NID FAN number cannot be empty';

  @override
  String get pleaseEnterOnlyDigits => 'Please enter only digits';

  @override
  String get nidFanMustBeExactly16Digits => 'NID FAN must be exactly 16 digits';

  @override
  String get createAccount => 'Create Account';

  @override
  String get welcomeToGaraBike => 'Welcome to Gara Bike';

  @override
  String get theFutureOfUrbanMobility =>
      'The future of urban mobility in Addis Ababa. Tap to get started.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get alreadyHaveAnAccount => 'Already have an account?';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully!';

  @override
  String get failedToUpdateProfile => 'Failed to update profile.';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get nidFan => 'NID / FAN';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get favoriteLocations => 'Favorite Locations';

  @override
  String get home => 'Home';

  @override
  String get work => 'Work';

  @override
  String get notSet => 'Not set';

  @override
  String get edit => 'Edit';

  @override
  String get clear => 'Clear';

  @override
  String get locationPermissionsAreDenied => 'Location permissions are denied';

  @override
  String get locationPermissionsArePermanentlyDenied =>
      'Location permissions are permanently denied.';

  @override
  String couldNotGetLocation(Object error) {
    return 'Could not get location: $error';
  }

  @override
  String hello(Object username) {
    return 'Hello $username';
  }

  @override
  String get wannaTakeARideToday => 'Wanna take a ride today?';

  @override
  String get nearbyBikes => 'Nearby Bikes';

  @override
  String get browseMap => 'Browse Map >';

  @override
  String error(Object errorMessage) {
    return 'Error: $errorMessage';
  }

  @override
  String get noBikesFoundNearby => 'No bikes found nearby.';

  @override
  String bikeIsReserved(Object bikeId) {
    return 'Bike #$bikeId is reserved!';
  }

  @override
  String get view => 'View';

  @override
  String joinMeOnGaraBike(Object code) {
    return 'Join me on Gara Bike! It\'s a great way to get around the city. Use my invitation code to get started: $code';
  }

  @override
  String get garaBikeInvitation => 'Gara Bike Invitation';

  @override
  String get inviteFriends => 'Invite Friends';

  @override
  String get yourInvitationCode => 'Your Invitation Code';

  @override
  String get codeCopiedToClipboard => 'Code copied to clipboard!';

  @override
  String get shareCode => 'Share Code';

  @override
  String get myStatistics => 'My Statistics';

  @override
  String get noStatisticsFound => 'No statistics found.';

  @override
  String get totalDuration => 'Total Duration';

  @override
  String get totalDistance => 'Total Distance';

  @override
  String get caloriesBurned => 'Calories Burned';

  @override
  String get carbonSaved => 'Carbon Saved';

  @override
  String get locate => 'Locate';

  @override
  String get findBikesNearYouInstantly =>
      'Find bikes near you instantly. Use precise location tracking anytime, anywhere.';

  @override
  String get unlock => 'Unlock';

  @override
  String get seamlesslyUnlockBikesWithATap =>
      'Seamlessly unlock bikes with a tap. Fast, secure, and ready to ride when you are.';

  @override
  String get ride => 'Ride';

  @override
  String get enjoyASmoothAndEcoFriendlyRide =>
      'Enjoy a smooth and eco-friendly ride to your destination.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String bikesAvailable(Object count) {
    return '$count Bikes Available';
  }

  @override
  String battery(Object level) {
    return '$level% Battery';
  }

  @override
  String get passPurchasedSuccessfully => 'Pass purchased successfully!';

  @override
  String get purchaseFailed => 'Purchase failed.';

  @override
  String get buyAPass => 'Buy a Pass';

  @override
  String get noPassesAvailableAtThisTime => 'No passes available at this time.';

  @override
  String daysOfUnlimitedRides(Object days) {
    return '$days day(s) of unlimited rides';
  }

  @override
  String get purchase => 'Purchase';

  @override
  String get failedToStartRide => 'Failed to start ride.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get positionTheQrCodeWithinTheFrame =>
      'Position the QR Code within the frame';

  @override
  String get reservationFailed => 'Reservation failed.';

  @override
  String reservationCancelledFeeCharged(Object fee) {
    return 'Reservation cancelled. Fee charged: $fee ETB';
  }

  @override
  String get cancellationFailed => 'Cancellation failed.';

  @override
  String get reservationExpired => 'Reservation expired!';

  @override
  String reserveBike(Object bikeId) {
    return 'Reserve Bike #$bikeId';
  }

  @override
  String get reserveThisBike => 'Reserve This Bike';

  @override
  String minutes(Object minutes) {
    return '$minutes minutes';
  }

  @override
  String get confirmAndReserve => 'Confirm & Reserve';

  @override
  String get bikeIsReservedTimeRemaining => 'Bike is reserved! Time remaining:';

  @override
  String get iveArrivedScanQr => 'I\'ve Arrived, Scan QR';

  @override
  String get cancelReservation => 'Cancel Reservation';

  @override
  String get tripCompleted => 'Trip Completed!';

  @override
  String get fare => 'Fare';

  @override
  String get distance => 'Distance';

  @override
  String get calories => 'Calories';

  @override
  String get done => 'Done';

  @override
  String get searchForAParkingZone => 'Search for a parking zone...';

  @override
  String get nameThisLocation => 'Name this Location';

  @override
  String get egHomeOfficeGym => 'e.g., Home, Office, Gym';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get setLocation => 'Set Location';

  @override
  String get confirmLocation => 'Confirm Location';

  @override
  String get settings => 'Settings';

  @override
  String get general => 'General';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get amharic => 'Amharic';

  @override
  String get account => 'Account';

  @override
  String get about => 'About';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get appVersion => 'App Version';

  @override
  String get garaBike => 'Gara Bike';

  @override
  String get support => 'Support';

  @override
  String get newTicket => 'New Ticket';

  @override
  String get ticketHistory => 'Ticket History';

  @override
  String get supportTicketCreatedSuccessfully =>
      'Support ticket created successfully!';

  @override
  String get failedToCreateTicket => 'Failed to create ticket.';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get yourNameAndEmailAreAutomaticallyIncluded =>
      'Your name and email are automatically included. Please describe your issue below.';

  @override
  String get subject => 'Subject';

  @override
  String get yourMessage => 'Your Message';

  @override
  String get messageCannotBeEmpty => 'Message cannot be empty';

  @override
  String get pleaseProvideMoreDetails =>
      'Please provide more details (at least 10 characters)';

  @override
  String get submitTicket => 'Submit Ticket';

  @override
  String get youHaveNoSupportTickets => 'You have no support tickets.';

  @override
  String submitted(Object date) {
    return 'Submitted: $date';
  }

  @override
  String get pleaseEnterAValidAmount => 'Please enter a valid amount.';

  @override
  String get topUpSuccessful => 'Top-up successful!';

  @override
  String get topUpFailed => 'Top-up failed.';

  @override
  String topUpEtb(Object amount) {
    return 'Top Up ETB $amount';
  }

  @override
  String get topUp => 'Top Up';

  @override
  String get topUpWallet => 'Top Up Wallet';

  @override
  String get selectAmount => 'Select Amount';

  @override
  String get or => 'OR';

  @override
  String get enterCustomAmount => 'Enter Custom Amount';

  @override
  String get selectPaymentMethod => 'Select Payment Method';

  @override
  String get garaRider => 'Gara Rider';

  @override
  String get myWallet => 'My Wallet';

  @override
  String get etb => 'ETB';

  @override
  String get logOut => 'Log Out';

  @override
  String get wannaTakeARide => 'Wanna take a ride today?';

  @override
  String get noBikesFound => 'No bikes found nearby.';

  @override
  String bikeReserved(Object bikeId) {
    return 'Bike #$bikeId is reserved!';
  }

  @override
  String get zeroMins => '0 mins';

  @override
  String get zeroMeters => '0 m';

  @override
  String get zeroCalories => '0 cal';

  @override
  String get zero => '0';

  @override
  String get zeroMinsZeroSecs => '0m 0s';

  @override
  String get zeroPointZeroZero => '0.00';

  @override
  String searchFailed(Object error) {
    return 'Search failed: $error';
  }

  @override
  String get noWalletDetailsFound => 'No wallet details found.';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get buyPass => 'Buy Pass';

  @override
  String metersAway(Object distance) {
    return '$distance m away';
  }

  @override
  String kmAway(Object distance) {
    return '$distance km away';
  }

  @override
  String get distanceUnknown => 'Distance unknown';

  @override
  String fieldCannotBeEmpty(Object fieldName) {
    return '$fieldName cannot be empty';
  }

  @override
  String get parkingZone => 'Parking Zone';

  @override
  String get couldNotLoadWeather => 'Could not load weather.';

  @override
  String get jan => 'Jan';

  @override
  String get feb => 'Feb';

  @override
  String get mar => 'Mar';

  @override
  String get apr => 'Apr';

  @override
  String get may => 'May';

  @override
  String get jun => 'Jun';

  @override
  String get jul => 'Jul';

  @override
  String get aug => 'Aug';

  @override
  String get sep => 'Sep';

  @override
  String get oct => 'Oct';

  @override
  String get nov => 'Nov';

  @override
  String get dec => 'Dec';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';
}
