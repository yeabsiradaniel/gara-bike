import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
  ];

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @failedToGetInitialLocation.
  ///
  /// In en, this message translates to:
  /// **'Failed to get initial location: {error}'**
  String failedToGetInitialLocation(Object error);

  /// No description provided for @failedToEndRide.
  ///
  /// In en, this message translates to:
  /// **'Failed to end ride.'**
  String get failedToEndRide;

  /// No description provided for @rideInProgress.
  ///
  /// In en, this message translates to:
  /// **'Ride in Progress'**
  String get rideInProgress;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get duration;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'KM'**
  String get km;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'KCAL'**
  String get kcal;

  /// No description provided for @currentlyRiding.
  ///
  /// In en, this message translates to:
  /// **'Currently Riding'**
  String get currentlyRiding;

  /// No description provided for @bike.
  ///
  /// In en, this message translates to:
  /// **'Bike #{bikeId}'**
  String bike(Object bikeId);

  /// No description provided for @closestParkingZone.
  ///
  /// In en, this message translates to:
  /// **'Closest Parking Zone'**
  String get closestParkingZone;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @endRide.
  ///
  /// In en, this message translates to:
  /// **'End Ride'**
  String get endRide;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @logInToContinueYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue your journey.'**
  String get logInToContinueYourJourney;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @pleaseEnterAValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterAValidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get passwordCannotBeEmpty;

  /// No description provided for @loginFailedPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginFailedPleaseTryAgain;

  /// No description provided for @accountVerifiedPleaseLogInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Account verified! Please log in to continue.'**
  String get accountVerifiedPleaseLogInToContinue;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed.'**
  String get verificationFailed;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @enterYourCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Code'**
  String get enterYourCode;

  /// No description provided for @a4DigitCodeHasBeenSentToYourPhone.
  ///
  /// In en, this message translates to:
  /// **'A 4-digit code has been sent to your phone.'**
  String get a4DigitCodeHasBeenSentToYourPhone;

  /// No description provided for @pleaseEnterThe4DigitCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 4-digit code'**
  String get pleaseEnterThe4DigitCode;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @didntReceiveSms.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive SMS?'**
  String get didntReceiveSms;

  /// No description provided for @registrationFailedPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registrationFailedPleaseTryAgain;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get createYourAccount;

  /// No description provided for @joinGaraBikeToStartYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Join Gara Bike to start your journey.'**
  String get joinGaraBikeToStartYourJourney;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number (e.g., +251...)'**
  String get phoneNumber;

  /// No description provided for @nidFanNumber.
  ///
  /// In en, this message translates to:
  /// **'NID FAN number'**
  String get nidFanNumber;

  /// No description provided for @nidFanNumberCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'NID FAN number cannot be empty'**
  String get nidFanNumberCannotBeEmpty;

  /// No description provided for @pleaseEnterOnlyDigits.
  ///
  /// In en, this message translates to:
  /// **'Please enter only digits'**
  String get pleaseEnterOnlyDigits;

  /// No description provided for @nidFanMustBeExactly16Digits.
  ///
  /// In en, this message translates to:
  /// **'NID FAN must be exactly 16 digits'**
  String get nidFanMustBeExactly16Digits;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @welcomeToGaraBike.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Gara Bike'**
  String get welcomeToGaraBike;

  /// No description provided for @theFutureOfUrbanMobility.
  ///
  /// In en, this message translates to:
  /// **'The future of urban mobility in Addis Ababa. Tap to get started.'**
  String get theFutureOfUrbanMobility;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile.'**
  String get failedToUpdateProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @nidFan.
  ///
  /// In en, this message translates to:
  /// **'NID / FAN'**
  String get nidFan;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @favoriteLocations.
  ///
  /// In en, this message translates to:
  /// **'Favorite Locations'**
  String get favoriteLocations;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @locationPermissionsAreDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are denied'**
  String get locationPermissionsAreDenied;

  /// No description provided for @locationPermissionsArePermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied.'**
  String get locationPermissionsArePermanentlyDenied;

  /// No description provided for @couldNotGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get location: {error}'**
  String couldNotGetLocation(Object error);

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello {username}'**
  String hello(Object username);

  /// No description provided for @wannaTakeARideToday.
  ///
  /// In en, this message translates to:
  /// **'Wanna take a ride today?'**
  String get wannaTakeARideToday;

  /// No description provided for @nearbyBikes.
  ///
  /// In en, this message translates to:
  /// **'Nearby Bikes'**
  String get nearbyBikes;

  /// No description provided for @browseMap.
  ///
  /// In en, this message translates to:
  /// **'Browse Map >'**
  String get browseMap;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {errorMessage}'**
  String error(Object errorMessage);

  /// No description provided for @noBikesFoundNearby.
  ///
  /// In en, this message translates to:
  /// **'No bikes found nearby.'**
  String get noBikesFoundNearby;

  /// No description provided for @bikeIsReserved.
  ///
  /// In en, this message translates to:
  /// **'Bike #{bikeId} is reserved!'**
  String bikeIsReserved(Object bikeId);

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @joinMeOnGaraBike.
  ///
  /// In en, this message translates to:
  /// **'Join me on Gara Bike! It\'s a great way to get around the city. Use my invitation code to get started: {code}'**
  String joinMeOnGaraBike(Object code);

  /// No description provided for @garaBikeInvitation.
  ///
  /// In en, this message translates to:
  /// **'Gara Bike Invitation'**
  String get garaBikeInvitation;

  /// No description provided for @inviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get inviteFriends;

  /// No description provided for @yourInvitationCode.
  ///
  /// In en, this message translates to:
  /// **'Your Invitation Code'**
  String get yourInvitationCode;

  /// No description provided for @codeCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard!'**
  String get codeCopiedToClipboard;

  /// No description provided for @shareCode.
  ///
  /// In en, this message translates to:
  /// **'Share Code'**
  String get shareCode;

  /// No description provided for @myStatistics.
  ///
  /// In en, this message translates to:
  /// **'My Statistics'**
  String get myStatistics;

  /// No description provided for @noStatisticsFound.
  ///
  /// In en, this message translates to:
  /// **'No statistics found.'**
  String get noStatisticsFound;

  /// No description provided for @totalDuration.
  ///
  /// In en, this message translates to:
  /// **'Total Duration'**
  String get totalDuration;

  /// No description provided for @totalDistance.
  ///
  /// In en, this message translates to:
  /// **'Total Distance'**
  String get totalDistance;

  /// No description provided for @caloriesBurned.
  ///
  /// In en, this message translates to:
  /// **'Calories Burned'**
  String get caloriesBurned;

  /// No description provided for @carbonSaved.
  ///
  /// In en, this message translates to:
  /// **'Carbon Saved'**
  String get carbonSaved;

  /// No description provided for @locate.
  ///
  /// In en, this message translates to:
  /// **'Locate'**
  String get locate;

  /// No description provided for @findBikesNearYouInstantly.
  ///
  /// In en, this message translates to:
  /// **'Find bikes near you instantly. Use precise location tracking anytime, anywhere.'**
  String get findBikesNearYouInstantly;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @seamlesslyUnlockBikesWithATap.
  ///
  /// In en, this message translates to:
  /// **'Seamlessly unlock bikes with a tap. Fast, secure, and ready to ride when you are.'**
  String get seamlesslyUnlockBikesWithATap;

  /// No description provided for @ride.
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get ride;

  /// No description provided for @enjoyASmoothAndEcoFriendlyRide.
  ///
  /// In en, this message translates to:
  /// **'Enjoy a smooth and eco-friendly ride to your destination.'**
  String get enjoyASmoothAndEcoFriendlyRide;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @bikesAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} Bikes Available'**
  String bikesAvailable(Object count);

  /// No description provided for @battery.
  ///
  /// In en, this message translates to:
  /// **'{level}% Battery'**
  String battery(Object level);

  /// No description provided for @passPurchasedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Pass purchased successfully!'**
  String get passPurchasedSuccessfully;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed.'**
  String get purchaseFailed;

  /// No description provided for @buyAPass.
  ///
  /// In en, this message translates to:
  /// **'Buy a Pass'**
  String get buyAPass;

  /// No description provided for @noPassesAvailableAtThisTime.
  ///
  /// In en, this message translates to:
  /// **'No passes available at this time.'**
  String get noPassesAvailableAtThisTime;

  /// No description provided for @daysOfUnlimitedRides.
  ///
  /// In en, this message translates to:
  /// **'{days} day(s) of unlimited rides'**
  String daysOfUnlimitedRides(Object days);

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @failedToStartRide.
  ///
  /// In en, this message translates to:
  /// **'Failed to start ride.'**
  String get failedToStartRide;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCode;

  /// No description provided for @positionTheQrCodeWithinTheFrame.
  ///
  /// In en, this message translates to:
  /// **'Position the QR Code within the frame'**
  String get positionTheQrCodeWithinTheFrame;

  /// No description provided for @reservationFailed.
  ///
  /// In en, this message translates to:
  /// **'Reservation failed.'**
  String get reservationFailed;

  /// No description provided for @reservationCancelledFeeCharged.
  ///
  /// In en, this message translates to:
  /// **'Reservation cancelled. Fee charged: {fee} ETB'**
  String reservationCancelledFeeCharged(Object fee);

  /// No description provided for @cancellationFailed.
  ///
  /// In en, this message translates to:
  /// **'Cancellation failed.'**
  String get cancellationFailed;

  /// No description provided for @reservationExpired.
  ///
  /// In en, this message translates to:
  /// **'Reservation expired!'**
  String get reservationExpired;

  /// No description provided for @reserveBike.
  ///
  /// In en, this message translates to:
  /// **'Reserve Bike #{bikeId}'**
  String reserveBike(Object bikeId);

  /// No description provided for @reserveThisBike.
  ///
  /// In en, this message translates to:
  /// **'Reserve This Bike'**
  String get reserveThisBike;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String minutes(Object minutes);

  /// No description provided for @confirmAndReserve.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Reserve'**
  String get confirmAndReserve;

  /// No description provided for @bikeIsReservedTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Bike is reserved! Time remaining:'**
  String get bikeIsReservedTimeRemaining;

  /// No description provided for @iveArrivedScanQr.
  ///
  /// In en, this message translates to:
  /// **'I\'ve Arrived, Scan QR'**
  String get iveArrivedScanQr;

  /// No description provided for @cancelReservation.
  ///
  /// In en, this message translates to:
  /// **'Cancel Reservation'**
  String get cancelReservation;

  /// No description provided for @tripCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trip Completed!'**
  String get tripCompleted;

  /// No description provided for @fare.
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get fare;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @searchForAParkingZone.
  ///
  /// In en, this message translates to:
  /// **'Search for a parking zone...'**
  String get searchForAParkingZone;

  /// No description provided for @nameThisLocation.
  ///
  /// In en, this message translates to:
  /// **'Name this Location'**
  String get nameThisLocation;

  /// No description provided for @egHomeOfficeGym.
  ///
  /// In en, this message translates to:
  /// **'e.g., Home, Office, Gym'**
  String get egHomeOfficeGym;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @setLocation.
  ///
  /// In en, this message translates to:
  /// **'Set Location'**
  String get setLocation;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get confirmLocation;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @amharic.
  ///
  /// In en, this message translates to:
  /// **'Amharic'**
  String get amharic;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @garaBike.
  ///
  /// In en, this message translates to:
  /// **'Gara Bike'**
  String get garaBike;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @newTicket.
  ///
  /// In en, this message translates to:
  /// **'New Ticket'**
  String get newTicket;

  /// No description provided for @ticketHistory.
  ///
  /// In en, this message translates to:
  /// **'Ticket History'**
  String get ticketHistory;

  /// No description provided for @supportTicketCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Support ticket created successfully!'**
  String get supportTicketCreatedSuccessfully;

  /// No description provided for @failedToCreateTicket.
  ///
  /// In en, this message translates to:
  /// **'Failed to create ticket.'**
  String get failedToCreateTicket;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @yourNameAndEmailAreAutomaticallyIncluded.
  ///
  /// In en, this message translates to:
  /// **'Your name and email are automatically included. Please describe your issue below.'**
  String get yourNameAndEmailAreAutomaticallyIncluded;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @yourMessage.
  ///
  /// In en, this message translates to:
  /// **'Your Message'**
  String get yourMessage;

  /// No description provided for @messageCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Message cannot be empty'**
  String get messageCannotBeEmpty;

  /// No description provided for @pleaseProvideMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'Please provide more details (at least 10 characters)'**
  String get pleaseProvideMoreDetails;

  /// No description provided for @submitTicket.
  ///
  /// In en, this message translates to:
  /// **'Submit Ticket'**
  String get submitTicket;

  /// No description provided for @youHaveNoSupportTickets.
  ///
  /// In en, this message translates to:
  /// **'You have no support tickets.'**
  String get youHaveNoSupportTickets;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted: {date}'**
  String submitted(Object date);

  /// No description provided for @pleaseEnterAValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount.'**
  String get pleaseEnterAValidAmount;

  /// No description provided for @topUpSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Top-up successful!'**
  String get topUpSuccessful;

  /// No description provided for @topUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Top-up failed.'**
  String get topUpFailed;

  /// No description provided for @topUpEtb.
  ///
  /// In en, this message translates to:
  /// **'Top Up ETB {amount}'**
  String topUpEtb(Object amount);

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get topUp;

  /// No description provided for @topUpWallet.
  ///
  /// In en, this message translates to:
  /// **'Top Up Wallet'**
  String get topUpWallet;

  /// No description provided for @selectAmount.
  ///
  /// In en, this message translates to:
  /// **'Select Amount'**
  String get selectAmount;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @enterCustomAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Custom Amount'**
  String get enterCustomAmount;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @garaRider.
  ///
  /// In en, this message translates to:
  /// **'Gara Rider'**
  String get garaRider;

  /// No description provided for @myWallet.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get myWallet;

  /// No description provided for @etb.
  ///
  /// In en, this message translates to:
  /// **'ETB'**
  String get etb;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @wannaTakeARide.
  ///
  /// In en, this message translates to:
  /// **'Wanna take a ride today?'**
  String get wannaTakeARide;

  /// No description provided for @noBikesFound.
  ///
  /// In en, this message translates to:
  /// **'No bikes found nearby.'**
  String get noBikesFound;

  /// No description provided for @bikeReserved.
  ///
  /// In en, this message translates to:
  /// **'Bike #{bikeId} is reserved!'**
  String bikeReserved(Object bikeId);

  /// No description provided for @zeroMins.
  ///
  /// In en, this message translates to:
  /// **'0 mins'**
  String get zeroMins;

  /// No description provided for @zeroMeters.
  ///
  /// In en, this message translates to:
  /// **'0 m'**
  String get zeroMeters;

  /// No description provided for @zeroCalories.
  ///
  /// In en, this message translates to:
  /// **'0 cal'**
  String get zeroCalories;

  /// No description provided for @zero.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get zero;

  /// No description provided for @zeroMinsZeroSecs.
  ///
  /// In en, this message translates to:
  /// **'0m 0s'**
  String get zeroMinsZeroSecs;

  /// No description provided for @zeroPointZeroZero.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get zeroPointZeroZero;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed: {error}'**
  String searchFailed(Object error);

  /// No description provided for @noWalletDetailsFound.
  ///
  /// In en, this message translates to:
  /// **'No wallet details found.'**
  String get noWalletDetailsFound;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @buyPass.
  ///
  /// In en, this message translates to:
  /// **'Buy Pass'**
  String get buyPass;

  /// No description provided for @metersAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} m away'**
  String metersAway(Object distance);

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String kmAway(Object distance);

  /// No description provided for @distanceUnknown.
  ///
  /// In en, this message translates to:
  /// **'Distance unknown'**
  String get distanceUnknown;

  /// No description provided for @fieldCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} cannot be empty'**
  String fieldCannotBeEmpty(Object fieldName);

  /// No description provided for @parkingZone.
  ///
  /// In en, this message translates to:
  /// **'Parking Zone'**
  String get parkingZone;

  /// No description provided for @couldNotLoadWeather.
  ///
  /// In en, this message translates to:
  /// **'Could not load weather.'**
  String get couldNotLoadWeather;

  /// No description provided for @jan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get apr;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @jun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get aug;

  /// No description provided for @sep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dec;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
