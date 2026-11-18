// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ShefsCloud Delivery';

  @override
  String get brandShort => 'ShefsCloud';

  @override
  String get englishLabel => 'EN';

  @override
  String get urduLabel => 'اردو';

  @override
  String get roleSender => 'Sender';

  @override
  String get roleRider => 'Rider';

  @override
  String get locationGateTitle => 'Location Permission Required';

  @override
  String get locationGateSubtitle =>
      'ShefsCloud Delivery requires continuous access to your device location to pin pickup & drop-off points, assign nearby riders, and run live delivery tracking.';

  @override
  String get locationGateMandatoryNote =>
      'You cannot proceed until location access is allowed.';

  @override
  String get locationGpsDisabledTitle => 'GPS / Location Services Disabled';

  @override
  String get locationGpsDisabledSubtitle =>
      'Please turn on device Location Services (GPS) to continue using ShefsCloud Delivery.';

  @override
  String get locationDeniedForeverSubtitle =>
      'Location permission was permanently denied. Please open App Settings and allow location access (Always or While Using) to continue.';

  @override
  String get allowLocationPermission => 'Allow Location Permission';

  @override
  String get openAppSettings => 'Open App Settings';

  @override
  String get openLocationSettings => 'Enable GPS Settings';

  @override
  String get checkingLocationPermission => 'Checking location permissions...';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginSubtitle =>
      'Sign in to manage or deliver orders in real time.';

  @override
  String get phoneOrEmailLabel => 'Phone number or Email';

  @override
  String get phoneOrEmailHint => '03XX XXXXXXX or email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Log in';

  @override
  String get noAccountPrompt => 'Don\'t have an account?';

  @override
  String get createAccount => 'Sign up';

  @override
  String get quickDemoAccounts => 'Quick Demo Accounts (MVP)';

  @override
  String get demoSender => 'Sender Demo';

  @override
  String get demoRider => 'Rider Demo';

  @override
  String get registerTitleSender => 'Create sender account';

  @override
  String get registerSubtitleSender =>
      'Send parcels & restaurant orders and track them live.';

  @override
  String get registerTitleRider => 'Join as a rider';

  @override
  String get registerSubtitleRider =>
      'Our team checks your documents before you can take jobs.';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameHintSender => 'Your full name';

  @override
  String get fullNameHintRider => 'As on your CNIC';

  @override
  String get phoneNumberLabel => 'Phone number';

  @override
  String get phoneNumberHint => '03XX XXXXXXX';

  @override
  String get restaurantNameLabel => 'Restaurant / Business name';

  @override
  String get restaurantNameHint => 'e.g. Spice Kitchen';

  @override
  String get restaurantAddressLabel => 'Restaurant / Pickup address';

  @override
  String get restaurantAddressHint => 'Street, sector, landmark';

  @override
  String get cnicNumberLabel => 'CNIC number (Optional)';

  @override
  String get cnicNumberHint => 'XXXXX-XXXXXXX-X';

  @override
  String get drivingLicenseLabel => 'Driving license';

  @override
  String get bikePapersLabel => 'Bike papers';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get photoAdded => 'Photo added';

  @override
  String get changePhoto => 'Change';

  @override
  String get choosePhotoSource => 'Select Document Photo';

  @override
  String get takePhotoCamera => 'Take photo with Camera';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get useSampleDocument => 'Attach Sample Document (Demo)';

  @override
  String get bothDocumentsRequired =>
      'Please upload both Driving License and Bike Papers photos.';

  @override
  String get otpNotice =>
      'We will verify your phone number and activate your account.';

  @override
  String get registerSubmitSender => 'Create Sender Account';

  @override
  String get registerSubmitRider => 'Submit Rider Registration';

  @override
  String get alreadyRegisteredPrompt => 'Already registered?';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your registered phone number or email to receive a one-time reset code.';

  @override
  String get sendResetCode => 'Send OTP Code';

  @override
  String get otpCodeLabel => 'Verification Code (OTP)';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get confirmNewPassword => 'Reset Password';

  @override
  String get senderDashboard => 'Sender Dashboard';

  @override
  String get riderDashboard => 'Rider Dashboard';

  @override
  String helloUser(String name) {
    return 'Hello, $name';
  }

  @override
  String get createDelivery => 'Create Delivery';

  @override
  String get newDelivery => 'New Delivery';

  @override
  String get trackOrder => 'Live Track';

  @override
  String get activeOrders => 'Active Orders';

  @override
  String get completedOrders => 'Completed';

  @override
  String get recentOrders => 'Recent Orders';

  @override
  String get noActiveOrders => 'No active orders yet';

  @override
  String get noActiveOrdersSenderHint =>
      'Tap Create Delivery to dispatch a rider immediately.';

  @override
  String get noActiveOrdersRiderHint =>
      'Stay online to receive nearby multi-order deliveries.';

  @override
  String get riderOnline => 'Online';

  @override
  String get riderOffline => 'Offline';

  @override
  String get backgroundTrackingActive => 'Background GPS tracking active';

  @override
  String get backgroundTrackingPaused =>
      'Go Online to start live & background GPS tracking';

  @override
  String get multiOrderLiveMap => 'Live Multi-Order Map';

  @override
  String ordersOnMapCount(int count) {
    return '$count Active Orders on Map';
  }

  @override
  String get tapOrderForDetails =>
      'Tap any order below or on map to view details';

  @override
  String get cashInHand => 'Cash in hand';

  @override
  String get payableEarnings => 'Payable earnings';

  @override
  String get deliveriesToday => 'Deliveries today';

  @override
  String get tabMapOrders => 'Active Map';

  @override
  String get tabDeliveryLog => 'Log';

  @override
  String get tabEarnings => 'Earnings';

  @override
  String get pickupPinTab => '1. Pickup Pin';

  @override
  String get dropoffPinTab => '2. Drop-off Pin';

  @override
  String get useMyLocation => 'Use My Location';

  @override
  String get locatingGps => 'Locating GPS...';

  @override
  String get tapMapToSetPin => 'Tap map to set pin';

  @override
  String get youAreHere => 'You Are Here';

  @override
  String get pickupInfo => 'Pickup Information';

  @override
  String get dropoffInfo => 'Drop-off Information';

  @override
  String get senderNameLabel => 'Sender / Restaurant Name';

  @override
  String get senderPhoneLabel => 'Sender Phone';

  @override
  String get pickupAddressLabel => 'Pickup Address';

  @override
  String get receiverNameLabel => 'Receiver Name';

  @override
  String get receiverPhoneLabel => 'Receiver Phone';

  @override
  String get dropoffAddressLabel => 'Drop-off Address';

  @override
  String get codAmountLabel => 'Amount to collect (COD - PKR)';

  @override
  String get deliveryFeeLabel => 'Estimated Delivery Fee';

  @override
  String get packageItems => 'Package Items';

  @override
  String get addItem => 'Add Item';

  @override
  String get riderNotesLabel => 'Notes for Rider (Optional)';

  @override
  String get riderNotesHint => 'Gate code, fragile items, ring bell...';

  @override
  String get confirmDeliveryRequest => 'Confirm Delivery Request';

  @override
  String get itemNameLabel => 'Item Name';

  @override
  String get itemQuantityLabel => 'Qty';

  @override
  String get itemNotesLabel => 'Item Notes';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get pickupLabel => 'PICKUP';

  @override
  String get dropoffLabel => 'DROP-OFF';

  @override
  String get collectCashCod => 'Collect Cash (COD)';

  @override
  String get deliveryFee => 'Delivery Fee';

  @override
  String get riderShare => 'Your Earning';

  @override
  String get recipientOtp => 'Recipient OTP';

  @override
  String get yourDeliveryCode => 'Your Delivery Code';

  @override
  String get tellOtpToRider => 'Share this code with the rider on handover';

  @override
  String get navigate => 'Navigate';

  @override
  String get call => 'Call';

  @override
  String get addProofPhoto => 'Proof Photo';

  @override
  String get markPickedUp => 'Mark as Picked Up';

  @override
  String get startDelivery => 'Start Delivery (On The Way)';

  @override
  String get confirmDelivery => 'Confirm Delivery';

  @override
  String get deliveryCompleted => 'Delivery Completed';

  @override
  String get orderOnTheWay => 'Your order is on the way';

  @override
  String get liveTracking => 'Live Tracking';

  @override
  String get assignedRider => 'Assigned Rider';

  @override
  String get findingNearestRider => 'Assigning nearest rider...';

  @override
  String get statusPlaced => 'Placed';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusAssigned => 'Assigned';

  @override
  String get statusPickedUp => 'Picked Up';

  @override
  String get statusOnTheWay => 'On The Way';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusFailed => 'Failed';

  @override
  String get filterAll => 'All';

  @override
  String get filterActive => 'Active';

  @override
  String get filterDelivered => 'Delivered';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirmTitle => 'Log out?';

  @override
  String get logoutConfirmMessage =>
      'Are you sure you want to log out of your account?';

  @override
  String get retry => 'Retry';
}
