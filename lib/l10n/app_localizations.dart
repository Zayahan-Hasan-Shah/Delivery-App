import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'ShefsCloud Delivery'**
  String get appName;

  /// No description provided for @brandShort.
  ///
  /// In en, this message translates to:
  /// **'ShefsCloud'**
  String get brandShort;

  /// No description provided for @englishLabel.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get englishLabel;

  /// No description provided for @urduLabel.
  ///
  /// In en, this message translates to:
  /// **'اردو'**
  String get urduLabel;

  /// No description provided for @roleSender.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get roleSender;

  /// No description provided for @roleRider.
  ///
  /// In en, this message translates to:
  /// **'Rider'**
  String get roleRider;

  /// No description provided for @locationGateTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get locationGateTitle;

  /// No description provided for @locationGateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'ShefsCloud Delivery requires continuous access to your device location to pin pickup & drop-off points, assign nearby riders, and run live delivery tracking.'**
  String get locationGateSubtitle;

  /// No description provided for @locationGateMandatoryNote.
  ///
  /// In en, this message translates to:
  /// **'You cannot proceed until location access is allowed.'**
  String get locationGateMandatoryNote;

  /// No description provided for @locationGpsDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'GPS / Location Services Disabled'**
  String get locationGpsDisabledTitle;

  /// No description provided for @locationGpsDisabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please turn on device Location Services (GPS) to continue using ShefsCloud Delivery.'**
  String get locationGpsDisabledSubtitle;

  /// No description provided for @locationDeniedForeverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Location permission was permanently denied. Please open App Settings and allow location access (Always or While Using) to continue.'**
  String get locationDeniedForeverSubtitle;

  /// No description provided for @allowLocationPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow Location Permission'**
  String get allowLocationPermission;

  /// No description provided for @openAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Open App Settings'**
  String get openAppSettings;

  /// No description provided for @openLocationSettings.
  ///
  /// In en, this message translates to:
  /// **'Enable GPS Settings'**
  String get openLocationSettings;

  /// No description provided for @checkingLocationPermission.
  ///
  /// In en, this message translates to:
  /// **'Checking location permissions...'**
  String get checkingLocationPermission;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage or deliver orders in real time.'**
  String get loginSubtitle;

  /// No description provided for @phoneOrEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number or Email'**
  String get phoneOrEmailLabel;

  /// No description provided for @phoneOrEmailHint.
  ///
  /// In en, this message translates to:
  /// **'03XX XXXXXXX or email'**
  String get phoneOrEmailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get signIn;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountPrompt;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get createAccount;

  /// No description provided for @quickDemoAccounts.
  ///
  /// In en, this message translates to:
  /// **'Quick Demo Accounts (MVP)'**
  String get quickDemoAccounts;

  /// No description provided for @demoSender.
  ///
  /// In en, this message translates to:
  /// **'Sender Demo'**
  String get demoSender;

  /// No description provided for @demoRider.
  ///
  /// In en, this message translates to:
  /// **'Rider Demo'**
  String get demoRider;

  /// No description provided for @registerTitleSender.
  ///
  /// In en, this message translates to:
  /// **'Create sender account'**
  String get registerTitleSender;

  /// No description provided for @registerSubtitleSender.
  ///
  /// In en, this message translates to:
  /// **'Send parcels & restaurant orders and track them live.'**
  String get registerSubtitleSender;

  /// No description provided for @registerTitleRider.
  ///
  /// In en, this message translates to:
  /// **'Join as a rider'**
  String get registerTitleRider;

  /// No description provided for @registerSubtitleRider.
  ///
  /// In en, this message translates to:
  /// **'Our team checks your documents before you can take jobs.'**
  String get registerSubtitleRider;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHintSender.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get fullNameHintSender;

  /// No description provided for @fullNameHintRider.
  ///
  /// In en, this message translates to:
  /// **'As on your CNIC'**
  String get fullNameHintRider;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumberLabel;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'03XX XXXXXXX'**
  String get phoneNumberHint;

  /// No description provided for @restaurantNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Restaurant / Business name'**
  String get restaurantNameLabel;

  /// No description provided for @restaurantNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Spice Kitchen'**
  String get restaurantNameHint;

  /// No description provided for @restaurantAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Restaurant / Pickup address'**
  String get restaurantAddressLabel;

  /// No description provided for @restaurantAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Street, sector, landmark'**
  String get restaurantAddressHint;

  /// No description provided for @cnicNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'CNIC number (Optional)'**
  String get cnicNumberLabel;

  /// No description provided for @cnicNumberHint.
  ///
  /// In en, this message translates to:
  /// **'XXXXX-XXXXXXX-X'**
  String get cnicNumberHint;

  /// No description provided for @drivingLicenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Driving license'**
  String get drivingLicenseLabel;

  /// No description provided for @bikePapersLabel.
  ///
  /// In en, this message translates to:
  /// **'Bike papers'**
  String get bikePapersLabel;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @photoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added'**
  String get photoAdded;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changePhoto;

  /// No description provided for @choosePhotoSource.
  ///
  /// In en, this message translates to:
  /// **'Select Document Photo'**
  String get choosePhotoSource;

  /// No description provided for @takePhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Take photo with Camera'**
  String get takePhotoCamera;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @useSampleDocument.
  ///
  /// In en, this message translates to:
  /// **'Attach Sample Document (Demo)'**
  String get useSampleDocument;

  /// No description provided for @bothDocumentsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please upload both Driving License and Bike Papers photos.'**
  String get bothDocumentsRequired;

  /// No description provided for @otpNotice.
  ///
  /// In en, this message translates to:
  /// **'We will verify your phone number and activate your account.'**
  String get otpNotice;

  /// No description provided for @registerSubmitSender.
  ///
  /// In en, this message translates to:
  /// **'Create Sender Account'**
  String get registerSubmitSender;

  /// No description provided for @registerSubmitRider.
  ///
  /// In en, this message translates to:
  /// **'Submit Rider Registration'**
  String get registerSubmitRider;

  /// No description provided for @alreadyRegisteredPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already registered?'**
  String get alreadyRegisteredPrompt;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered phone number or email to receive a one-time reset code.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send OTP Code'**
  String get sendResetCode;

  /// No description provided for @otpCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification Code (OTP)'**
  String get otpCodeLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get confirmNewPassword;

  /// No description provided for @senderDashboard.
  ///
  /// In en, this message translates to:
  /// **'Sender Dashboard'**
  String get senderDashboard;

  /// No description provided for @riderDashboard.
  ///
  /// In en, this message translates to:
  /// **'Rider Dashboard'**
  String get riderDashboard;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloUser(String name);

  /// No description provided for @createDelivery.
  ///
  /// In en, this message translates to:
  /// **'Create Delivery'**
  String get createDelivery;

  /// No description provided for @newDelivery.
  ///
  /// In en, this message translates to:
  /// **'New Delivery'**
  String get newDelivery;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Live Track'**
  String get trackOrder;

  /// No description provided for @activeOrders.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get activeOrders;

  /// No description provided for @completedOrders.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedOrders;

  /// No description provided for @recentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent Orders'**
  String get recentOrders;

  /// No description provided for @noActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'No active orders yet'**
  String get noActiveOrders;

  /// No description provided for @noActiveOrdersSenderHint.
  ///
  /// In en, this message translates to:
  /// **'Tap Create Delivery to dispatch a rider immediately.'**
  String get noActiveOrdersSenderHint;

  /// No description provided for @noActiveOrdersRiderHint.
  ///
  /// In en, this message translates to:
  /// **'Stay online to receive nearby multi-order deliveries.'**
  String get noActiveOrdersRiderHint;

  /// No description provided for @riderOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get riderOnline;

  /// No description provided for @riderOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get riderOffline;

  /// No description provided for @backgroundTrackingActive.
  ///
  /// In en, this message translates to:
  /// **'Background GPS tracking active'**
  String get backgroundTrackingActive;

  /// No description provided for @backgroundTrackingPaused.
  ///
  /// In en, this message translates to:
  /// **'Go Online to start live & background GPS tracking'**
  String get backgroundTrackingPaused;

  /// No description provided for @multiOrderLiveMap.
  ///
  /// In en, this message translates to:
  /// **'Live Multi-Order Map'**
  String get multiOrderLiveMap;

  /// No description provided for @ordersOnMapCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Active Orders on Map'**
  String ordersOnMapCount(int count);

  /// No description provided for @tapOrderForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap any order below or on map to view details'**
  String get tapOrderForDetails;

  /// No description provided for @cashInHand.
  ///
  /// In en, this message translates to:
  /// **'Cash in hand'**
  String get cashInHand;

  /// No description provided for @payableEarnings.
  ///
  /// In en, this message translates to:
  /// **'Payable earnings'**
  String get payableEarnings;

  /// No description provided for @deliveriesToday.
  ///
  /// In en, this message translates to:
  /// **'Deliveries today'**
  String get deliveriesToday;

  /// No description provided for @tabMapOrders.
  ///
  /// In en, this message translates to:
  /// **'Active Map'**
  String get tabMapOrders;

  /// No description provided for @tabDeliveryLog.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get tabDeliveryLog;

  /// No description provided for @tabEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get tabEarnings;

  /// No description provided for @pickupPinTab.
  ///
  /// In en, this message translates to:
  /// **'1. Pickup Pin'**
  String get pickupPinTab;

  /// No description provided for @dropoffPinTab.
  ///
  /// In en, this message translates to:
  /// **'2. Drop-off Pin'**
  String get dropoffPinTab;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use My Location'**
  String get useMyLocation;

  /// No description provided for @locatingGps.
  ///
  /// In en, this message translates to:
  /// **'Locating GPS...'**
  String get locatingGps;

  /// No description provided for @tapMapToSetPin.
  ///
  /// In en, this message translates to:
  /// **'Tap map to set pin'**
  String get tapMapToSetPin;

  /// No description provided for @youAreHere.
  ///
  /// In en, this message translates to:
  /// **'You Are Here'**
  String get youAreHere;

  /// No description provided for @pickupInfo.
  ///
  /// In en, this message translates to:
  /// **'Pickup Information'**
  String get pickupInfo;

  /// No description provided for @dropoffInfo.
  ///
  /// In en, this message translates to:
  /// **'Drop-off Information'**
  String get dropoffInfo;

  /// No description provided for @senderNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Sender / Restaurant Name'**
  String get senderNameLabel;

  /// No description provided for @senderPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Sender Phone'**
  String get senderPhoneLabel;

  /// No description provided for @pickupAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup Address'**
  String get pickupAddressLabel;

  /// No description provided for @receiverNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Receiver Name'**
  String get receiverNameLabel;

  /// No description provided for @receiverPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Receiver Phone'**
  String get receiverPhoneLabel;

  /// No description provided for @dropoffAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Drop-off Address'**
  String get dropoffAddressLabel;

  /// No description provided for @codAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount to collect (COD - PKR)'**
  String get codAmountLabel;

  /// No description provided for @deliveryFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated Delivery Fee'**
  String get deliveryFeeLabel;

  /// No description provided for @packageItems.
  ///
  /// In en, this message translates to:
  /// **'Package Items'**
  String get packageItems;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @riderNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes for Rider (Optional)'**
  String get riderNotesLabel;

  /// No description provided for @riderNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Gate code, fragile items, ring bell...'**
  String get riderNotesHint;

  /// No description provided for @confirmDeliveryRequest.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delivery Request'**
  String get confirmDeliveryRequest;

  /// No description provided for @itemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemNameLabel;

  /// No description provided for @itemQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get itemQuantityLabel;

  /// No description provided for @itemNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Item Notes'**
  String get itemNotesLabel;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @pickupLabel.
  ///
  /// In en, this message translates to:
  /// **'PICKUP'**
  String get pickupLabel;

  /// No description provided for @dropoffLabel.
  ///
  /// In en, this message translates to:
  /// **'DROP-OFF'**
  String get dropoffLabel;

  /// No description provided for @collectCashCod.
  ///
  /// In en, this message translates to:
  /// **'Collect Cash (COD)'**
  String get collectCashCod;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFee;

  /// No description provided for @riderShare.
  ///
  /// In en, this message translates to:
  /// **'Your Earning'**
  String get riderShare;

  /// No description provided for @recipientOtp.
  ///
  /// In en, this message translates to:
  /// **'Recipient OTP'**
  String get recipientOtp;

  /// No description provided for @yourDeliveryCode.
  ///
  /// In en, this message translates to:
  /// **'Your Delivery Code'**
  String get yourDeliveryCode;

  /// No description provided for @tellOtpToRider.
  ///
  /// In en, this message translates to:
  /// **'Share this code with the rider on handover'**
  String get tellOtpToRider;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @addProofPhoto.
  ///
  /// In en, this message translates to:
  /// **'Proof Photo'**
  String get addProofPhoto;

  /// No description provided for @markPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Mark as Picked Up'**
  String get markPickedUp;

  /// No description provided for @startDelivery.
  ///
  /// In en, this message translates to:
  /// **'Start Delivery (On The Way)'**
  String get startDelivery;

  /// No description provided for @confirmDelivery.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delivery'**
  String get confirmDelivery;

  /// No description provided for @deliveryCompleted.
  ///
  /// In en, this message translates to:
  /// **'Delivery Completed'**
  String get deliveryCompleted;

  /// No description provided for @orderOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Your order is on the way'**
  String get orderOnTheWay;

  /// No description provided for @liveTracking.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get liveTracking;

  /// No description provided for @assignedRider.
  ///
  /// In en, this message translates to:
  /// **'Assigned Rider'**
  String get assignedRider;

  /// No description provided for @findingNearestRider.
  ///
  /// In en, this message translates to:
  /// **'Assigning nearest rider...'**
  String get findingNearestRider;

  /// No description provided for @statusPlaced.
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get statusPlaced;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get statusAssigned;

  /// No description provided for @statusPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Picked Up'**
  String get statusPickedUp;

  /// No description provided for @statusOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On The Way'**
  String get statusOnTheWay;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get filterActive;

  /// No description provided for @filterDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get filterDelivered;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get logoutConfirmMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;
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
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
