// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get helloWorld => 'ሰላም ዓለም!';

  @override
  String failedToGetInitialLocation(Object error) {
    return 'መጀመሪያ አካባቢን ማግኘት አልተቻለም፡ $error';
  }

  @override
  String get failedToEndRide => 'ጉዞን ማቋረጥ አልተቻለም።';

  @override
  String get rideInProgress => 'ጉዞ በመካከል ነው';

  @override
  String get duration => 'ቆይታ';

  @override
  String get km => 'ኪ.ሜ';

  @override
  String get kcal => 'ካሎሪ';

  @override
  String get currentlyRiding => 'አሁን በመንካት ላይ ነህ';

  @override
  String bike(Object bikeId) {
    return 'ብስክሌት #$bikeId';
  }

  @override
  String get closestParkingZone => 'በአቅራቢያው ያለ የመቆሚያ ቦታ';

  @override
  String get searching => 'በመፈለግ ላይ...';

  @override
  String get endRide => 'ጉዞን አቁም';

  @override
  String get logIn => 'ግባ';

  @override
  String get welcomeBack => 'እንኳን ደህና መጣህ!';

  @override
  String get logInToContinueYourJourney => 'ጉዞህን ለመቀጠል እባክህ ግባ።';

  @override
  String get emailAddress => 'ኢሜይል አድራሻ';

  @override
  String get pleaseEnterAValidEmail => 'እባክህ ትክክለኛ ኢሜይል አስገባ';

  @override
  String get password => 'የይለፍ ቃል';

  @override
  String get passwordCannotBeEmpty => 'የይለፍ ቃል መባዶ መሆን አይችልም';

  @override
  String get loginFailedPleaseTryAgain => 'መግባት አልተሳካም። እባክህ እንደገና ሞክር።';

  @override
  String get accountVerifiedPleaseLogInToContinue =>
      'መለያው ተረጋግጧል! ለመቀጠል እባክህ ግባ።';

  @override
  String get verificationFailed => 'ማረጋገጥ አልተሳካም።';

  @override
  String get verification => 'ማረጋገጫ';

  @override
  String get enterYourCode => 'ኮድህን አስገባ';

  @override
  String get a4DigitCodeHasBeenSentToYourPhone => '4 አሃዝ ያለው ኮድ ወደ ስልክህ ተልኳል።';

  @override
  String get pleaseEnterThe4DigitCode => 'እባክህ 4 አሃዝ ያለው ኮድ አስገባ';

  @override
  String get verificationCode => 'የማረጋገጫ ኮድ';

  @override
  String get verify => 'አረጋግጥ';

  @override
  String get didntReceiveSms => 'ኤስኤምኤስ አልደረሰህም?';

  @override
  String get registrationFailedPleaseTryAgain =>
      'መመዝገብ አልተሳካም። እባክህ እንደገና ሞክር።';

  @override
  String get signUp => 'ተመዝገብ';

  @override
  String get createYourAccount => 'መለያህን ፍጠር';

  @override
  String get joinGaraBikeToStartYourJourney =>
      'ጉዞህን ለመጀመር ከGara Bike ጋር ተቀላቀል።';

  @override
  String get username => 'የተጠቃሚ ስም';

  @override
  String get phoneNumber => 'የስልክ ቁጥር (ለምሳሌ፡ +251...)';

  @override
  String get nidFanNumber => 'የNID FAN ቁጥር';

  @override
  String get nidFanNumberCannotBeEmpty => 'የNID FAN ቁጥር መባዶ መሆን አይችልም';

  @override
  String get pleaseEnterOnlyDigits => 'እባክህ ቁጥሮችን ብቻ አስገባ';

  @override
  String get nidFanMustBeExactly16Digits =>
      'የNID FAN ቁጥር በትክክል 16 አሃዝ መሆን አለበት';

  @override
  String get createAccount => 'መለያ ፍጠር';

  @override
  String get welcomeToGaraBike => 'እንኳን ወደ Gara Bike በደህና መጣህ';

  @override
  String get theFutureOfUrbanMobility =>
      'የአዲስ አበባ ከተማዊ መንቀሳቀስ የወደፊት መንገድ። ለመጀመር እንኩዋን ጠቅ አድርግ።';

  @override
  String get getStarted => 'ጀምር';

  @override
  String get alreadyHaveAnAccount => 'አስቀድሞ መለያ አለህ?';

  @override
  String get profileUpdatedSuccessfully => 'መገለጫ በተሳካ ሁኔታ ተዘምኗል!';

  @override
  String get failedToUpdateProfile => 'መገለጫ ማዘመን አልተሳካም።';

  @override
  String get editProfile => 'መገለጫን አርትዕ';

  @override
  String get nidFan => 'NID / FAN';

  @override
  String get saveChanges => 'ለውጦችን አስቀምጥ';

  @override
  String get favoriteLocations => 'ተወዳጅ አካባቢዎች';

  @override
  String get home => 'ቤት';

  @override
  String get work => 'ሥራ';

  @override
  String get notSet => 'አልተዘጋጀም';

  @override
  String get edit => 'አርትዕ';

  @override
  String get clear => 'አጽዳ';

  @override
  String get locationPermissionsAreDenied => 'የአካባቢ ፍቃድ ተከልክሏል';

  @override
  String get locationPermissionsArePermanentlyDenied =>
      'የአካባቢ ፍቃዶች በቋሚነት ተከልкለዋል።';

  @override
  String couldNotGetLocation(Object error) {
    return 'አካባቢን ማግኘት አልተቻለም፡ $error';
  }

  @override
  String hello(Object username) {
    return 'ሰላም $username';
  }

  @override
  String get wannaTakeARideToday => 'ዛሬ ጉዞ መውሰድ ትፈልጋለህ?';

  @override
  String get nearbyBikes => 'በአቅራቢያ ያሉ ብስክሌቶች';

  @override
  String get browseMap => 'ካርታን ተመልከት >';

  @override
  String error(Object errorMessage) {
    return 'ስህተት፡ $errorMessage';
  }

  @override
  String get noBikesFoundNearby => 'በአቅራቢያ ብስክሌት አልተገኘም።';

  @override
  String bikeIsReserved(Object bikeId) {
    return 'ብስክሌት #$bikeId ተያይዟል!';
  }

  @override
  String get view => 'ተመልከት';

  @override
  String joinMeOnGaraBike(Object code) {
    return 'ከGara Bike ጋር ተቀላቀል! በከተማ ውስጥ መንቀሳቀስ ለመቀላቀል ተስማሚ መንገድ ነው። የግብዣ ኮድ ተጠቀም፡ $code';
  }

  @override
  String get garaBikeInvitation => 'የGara Bike ግብዣ';

  @override
  String get inviteFriends => 'ጓደኞችን ጋብዝ';

  @override
  String get yourInvitationCode => 'የእርስዎ የግብዣ ኮድ';

  @override
  String get codeCopiedToClipboard => 'ኮድ ወደ ቅጂ ተገልብጧል!';

  @override
  String get shareCode => 'ኮድ አጋራ';

  @override
  String get myStatistics => 'የእኔ ስታቲስቲክስ';

  @override
  String get noStatisticsFound => 'ምንም ስታቲስቲክስ አልተገኘም።';

  @override
  String get totalDuration => 'ጠቅላላ ጊዜ';

  @override
  String get totalDistance => 'ጠቅላላ ርቀት';

  @override
  String get caloriesBurned => 'የተቃጠሉ ካሎሪዎች';

  @override
  String get carbonSaved => 'የተቆጠረ ካርቦን';

  @override
  String get locate => 'አግኝ';

  @override
  String get findBikesNearYouInstantly =>
      'በአቅራቢያው ያሉ ብስክሌቶችን በፍጥነት ፈልግ። ትክክለኛ የአካባቢ እርምጃን በየጊዜው ተጠቀም።';

  @override
  String get unlock => 'ክፈት';

  @override
  String get seamlesslyUnlockBikesWithATap =>
      'ብስክሌቶችን በአንድ ንክኪ በቀላሉ ክፈት። ፈጣን፣ ደህና፣ በቀና የተዘጋጀ።';

  @override
  String get ride => 'ተጓዝ';

  @override
  String get enjoyASmoothAndEcoFriendlyRide => 'ቀላልና የአካባቢ መጠበቂያ ጉዞ ይደሰቱ።';

  @override
  String get skip => 'ዝለል';

  @override
  String get next => 'ቀጣይ';

  @override
  String bikesAvailable(Object count) {
    return '$count ብስክሌቶች ይገኛሉ';
  }

  @override
  String battery(Object level) {
    return 'ባትሪ $level%';
  }

  @override
  String get passPurchasedSuccessfully => 'ፓስ በተሳካ ሁኔታ ተገዝቷል!';

  @override
  String get purchaseFailed => 'ግዢ አልተሳካም።';

  @override
  String get buyAPass => 'ፓስ ግዛ';

  @override
  String get noPassesAvailableAtThisTime => 'በዚህ ጊዜ ፓስ አይገኝም።';

  @override
  String daysOfUnlimitedRides(Object days) {
    return 'የማይቋረጡ ጉዞዎች ለ $days ቀን(ናት)';
  }

  @override
  String get purchase => 'ግዛ';

  @override
  String get failedToStartRide => 'ጉዞን ጀመር አልተቻለም።';

  @override
  String get tryAgain => 'እንደገና ሞክር';

  @override
  String get scanQrCode => 'QR ኮድ ተመልከት';

  @override
  String get positionTheQrCodeWithinTheFrame => 'QR ኮድን በቅጥያው ውስጥ አቀንብር';

  @override
  String get reservationFailed => 'ቦታ ማስያዝ አልተሳካም።';

  @override
  String reservationCancelledFeeCharged(Object fee) {
    return 'መያዣ ተሰርዟል። ክፍያ ተተግቧል፡ $fee ብር';
  }

  @override
  String get cancellationFailed => 'መሰረዝ አልተሳካም።';

  @override
  String get reservationExpired => 'መያዣ ጊዜዋ አልፏል!';

  @override
  String reserveBike(Object bikeId) {
    return 'ብስክሌት #$bikeId አስይዝ';
  }

  @override
  String get reserveThisBike => 'ይህን ብስክሌት አስይዝ';

  @override
  String minutes(Object minutes) {
    return '$minutes ደቂቃ(ዎች)';
  }

  @override
  String get confirmAndReserve => 'አረጋግጥ እና አስይዝ';

  @override
  String get bikeIsReservedTimeRemaining => 'ብስክሌት ተያይዟል! የቀረው ጊዜ፡';

  @override
  String get iveArrivedScanQr => 'ደርሻለሁ፣ QR ኮድ ተመልከት';

  @override
  String get cancelReservation => 'መያዣ ሰርዝ';

  @override
  String get tripCompleted => 'ጉዞ ተጠናቋል!';

  @override
  String get fare => 'ክፍያ';

  @override
  String get distance => 'ርቀት';

  @override
  String get calories => 'ካሎሪ';

  @override
  String get done => 'ተከናውኗል';

  @override
  String get searchForAParkingZone => 'የመቆሚያ ቦታ ፈልግ...';

  @override
  String get nameThisLocation => 'ይህን ቦታ ስም ስጥ';

  @override
  String get egHomeOfficeGym => 'ለምሳሌ፡ ቤት፣ ቢሮ፣ ጂም';

  @override
  String get cancel => 'ሰርዝ';

  @override
  String get save => 'አስቀምጥ';

  @override
  String get setLocation => 'አካባቢ አዘጋጅ';

  @override
  String get confirmLocation => 'አካባቢን አረጋግጥ';

  @override
  String get settings => 'ቅንብሮች';

  @override
  String get general => 'አጠቃላይ';

  @override
  String get darkMode => 'ጨለማ ሁነታ';

  @override
  String get notifications => 'ማሳወቂያዎች';

  @override
  String get language => 'ቋንቋ';

  @override
  String get english => 'እንግሊዝኛ';

  @override
  String get amharic => 'አማርኛ';

  @override
  String get account => 'መለያ';

  @override
  String get about => 'ስለ መተግበሪያው';

  @override
  String get privacyPolicy => 'የግላዊነት ፖሊሲ';

  @override
  String get termsOfService => 'የአገልግሎት ውሎች';

  @override
  String get appVersion => 'የመተግበሪያ ስሪት';

  @override
  String get garaBike => 'ጋራ ባይክ';

  @override
  String get support => 'ድጋፍ';

  @override
  String get newTicket => 'አዲስ መስመር ክለብ';

  @override
  String get ticketHistory => 'የመስመር ታሪክ';

  @override
  String get supportTicketCreatedSuccessfully => 'የድጋፍ ጥያቄ በተሳካ ሁኔታ ተፈጥሯል!';

  @override
  String get failedToCreateTicket => 'የድጋፍ ጥያቄ መፍጠር አልተሳካም።';

  @override
  String get contactUs => 'አግኙን';

  @override
  String get yourNameAndEmailAreAutomaticallyIncluded =>
      'ስምዎና ኢሜይልዎ በራስ-ሰር ይጨመራሉ። እባኮትን ችግኝዎን ከታች ይግለጹ።';

  @override
  String get subject => 'ርዕስ';

  @override
  String get yourMessage => 'መልእክትዎ';

  @override
  String get messageCannotBeEmpty => 'መልእክት ባዶ መሆን አይችልም።';

  @override
  String get pleaseProvideMoreDetails => 'እባኮትን በዝርዝር ያብራሩ (ቢያንስ 10 ቁምፊ)';

  @override
  String get submitTicket => 'ጥያቄ ያስገቡ';

  @override
  String get youHaveNoSupportTickets => 'የድጋፍ ጥያቄ የለዎትም።';

  @override
  String submitted(Object date) {
    return 'ተላክ፡ $date';
  }

  @override
  String get pleaseEnterAValidAmount => 'እባኮትን ትክክለኛ መጠን ያስገቡ።';

  @override
  String get topUpSuccessful => 'ተጨማሪ ገንዘብ ተሳክቷል!';

  @override
  String get topUpFailed => 'ተጨማሪ ገንዘብ አልተሳካም።';

  @override
  String topUpEtb(Object amount) {
    return 'ተጨማሪ ገንዘብ $amount ብር';
  }

  @override
  String get topUp => 'ተጨማሪ ገንዘብ';

  @override
  String get topUpWallet => 'በቦርሳ ተጨማሪ ገንዘብ ያክሉ';

  @override
  String get selectAmount => 'መጠን ይምረጡ';

  @override
  String get or => 'ወይም';

  @override
  String get enterCustomAmount => 'በተገኘ መጠን ያስገቡ';

  @override
  String get selectPaymentMethod => 'የክፍያ ዘዴ ይምረጡ';

  @override
  String get garaRider => 'ጋራ ጋላቢ';

  @override
  String get myWallet => 'የእኔ ቦርሳ';

  @override
  String get etb => 'ብር';

  @override
  String get logOut => 'ውጣ';

  @override
  String get wannaTakeARide => 'ዛሬ ጉዞ መውሰድ ይፈልጋሉ?';

  @override
  String get noBikesFound => 'በአቅራቢያ ምንም ብስክሌቶች አልተገኙም።';

  @override
  String bikeReserved(Object bikeId) {
    return 'ብስክሌት #$bikeId ተይዟል!';
  }

  @override
  String get zeroMins => '0 ደቂቃ';

  @override
  String get zeroMeters => '0 ሜትር';

  @override
  String get zeroCalories => '0 ካሎሪ';

  @override
  String get zero => '0';

  @override
  String get zeroMinsZeroSecs => '0ደ 0ሰ';

  @override
  String get zeroPointZeroZero => '0.00';

  @override
  String searchFailed(Object error) {
    return 'ፍለጋ አልተሳካም፡ $error';
  }

  @override
  String get noWalletDetailsFound => 'ምንም የኪስ ቦርሳ ዝርዝሮች አልተገኙም።';

  @override
  String get currentBalance => 'የአሁኑ ቀሪ ሂሳብ';

  @override
  String get buyPass => 'ፓስ ይግዙ';

  @override
  String metersAway(Object distance) {
    return '$distance ሜትር ርቀት';
  }

  @override
  String kmAway(Object distance) {
    return '$distance ኪሜ ርቀት';
  }

  @override
  String get distanceUnknown => 'ርቀት ያልታወቀ';

  @override
  String fieldCannotBeEmpty(Object fieldName) {
    return '$fieldName ባዶ መሆን አይችልም';
  }

  @override
  String get parkingZone => 'የመኪና ማቆሚያ ዞን';

  @override
  String get couldNotLoadWeather => 'የአየር ሁኔታን መጫን አልተቻለም።';

  @override
  String get jan => 'ጃን';

  @override
  String get feb => 'ፌብ';

  @override
  String get mar => 'ማር';

  @override
  String get apr => 'ኤፕ';

  @override
  String get may => 'ሜይ';

  @override
  String get jun => 'ጁን';

  @override
  String get jul => 'ጁላይ';

  @override
  String get aug => 'ኦገ';

  @override
  String get sep => 'ሴፕ';

  @override
  String get oct => 'ኦክ';

  @override
  String get nov => 'ኖቬ';

  @override
  String get dec => 'ዲሴ';

  @override
  String get monday => 'ሰኞ';

  @override
  String get tuesday => 'ማክሰኞ';

  @override
  String get wednesday => 'ረቡዕ';

  @override
  String get thursday => 'ሐሙስ';

  @override
  String get friday => 'አርብ';

  @override
  String get saturday => 'ቅዳሜ';

  @override
  String get sunday => 'እሁድ';
}
