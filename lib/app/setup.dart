import 'package:trace/app/config.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:easy_localization/easy_localization.dart';

import 'constants.dart';

class Setup {
  static final bool isDebug = kDebugMode;

  static String appName = Config.appName;
  static String appPackageName = Constants.appPackageName();
  static String appVersion = Config.appVersion;
  static String bio = "welcome_bio".tr(namedArgs: {"app_name": appName});
  static final List<String> allowedCountries =
      []; //['FR', 'CA', 'US', 'AO', 'BR'];
  static final int verificationCodeDigits = 6;

  // Social login= Config.appName
  static final bool isPhoneLoginEnabled = false;
  static final bool isFacebookLoginEnabled = true;
  static final bool isGoogleLoginEnabled = true;
  static final bool isAppleLoginEnabled = true;

  // App config
  static final bool isCallsEnabled = true;
  static final String streamingProviderType = 'agora'; // webrtc
  static final String streamingProviderKey = 'ef13c0fbfbbe47e48861f4327c92d6e8';

  //Tecent config
  static final int tecentSdkAppID = 0;
  static final String tecentSdkKEY = "";
  static final String tecentUserSIG = 'eJwtjM0KgkAURt-*u2*c***';
  static final String tecentUserID = 'chancilson';

  //Set Banuba license token for Video Editor SDK
  static const String licenseToken =
      "Qk5CIJdxzrHYdoUhvO5GonaXRBHkoSOM8ZmkNkIC7121pJliVrxLzFilI8fP4RkM4sV1+cPSTNCFF5x2jnNxxihBrGfF8Dv9ZFxEFrRzoCoXDSkuDILRGE5tqXjs1W5m8iez3e698KevjjN4Z9AXpj1ZDDNU0Wd2YMXD6eK/3SC9mAsZEps8y5yrxXW7auUNzrVLV+AQl/8f6PoOUNhFZk/DCgboNgCEghr/k6nf6k0a6az9C2L31eCfOC6hFbck2VAbSq+X5Ygu9eTty8IuQFdTGYgodm2lft0bm3aBWh9kpt6q8IfW1jYgD5dpU1bp3SZXPrpduey7zijZIQ5dOQH8T3oBpQCGht+LP6N38ux199BOVSUtGkwxipHr4RUlIHi1syPQKSbc+LDZm8bsuwxkZjeD8lam28o+G7TU8+cJBWh5/jrZrsqelAdalG24hM+ZZKpMnTccjU6FtuUuXrPURXJWkrVTn1iISqjK2v5BobDn97ne58pIWhOtFJKNedvghAXNje3wcUhyu2Vsokvv98I9qVjWey3HEgOR4Zew2HgHcpcT4eof48wSALEkQ6sh4cvqwToq+fH52KaX1CYeb87dP7+bSsXRijtxnRQHut3GTjyA+5EBoGSrnJ6HIkLAlDNJSqslASuZf1kgVg==";
  static const channelName = 'startActivity/VideoEditorChannel';
  static const methodInitVideoEditor = 'InitBanubaVideoEditor';
  static const methodStartVideoEditor = 'StartBanubaVideoEditor';
  static const methodStartVideoEditorPIP = 'StartBanubaVideoEditorPIP';
  static const methodStartVideoEditorTrimmer = 'StartBanubaVideoEditorTrimmer';
  static const methodDemoPlayExportedVideo = 'PlayExportedVideo';
  static const errEditorNotInitializedCode = 'ERR_VIDEO_EDITOR_NOT_INITIALIZED';
  static String errEditorNotInitializedMessage =
      "banuba_video_editor_sdk.sdk_not_initialized".tr();
  static const errEditorLicenseRevokedCode = 'ERR_VIDEO_EDITOR_LICENSE_REVOKED';
  static String errEditorLicenseRevokedMessage =
      "banuba_video_editor_sdk.license_revoked_or_expired".tr();

  static const argExportedVideoFile = 'exportedVideoFilePath';
  static const argExportedVideoCoverPreviewPath =
      'exportedVideoCoverPreviewPath';

  static final bool isWithdrawIbanEnabled = false;
  static final bool isWithdrawPayoneerEnabled = false;
  static final bool isWithdrawPaypalEnabled = true;
  static final bool isWithdrawUSDTlEnabled = true;

  // Additional Payments method, Google Play and Apple Pay are enabled by default
  static final bool isStripePaymentsEnabled = false;
  static final bool isPayPalPaymentsEnabled = true;

  // User fields
  static final int welcomeCredit = 0;
  static final int minimumAgeToRegister = 16;
  static final int maximumAgeToRegister = 16;
  static final int? maxDistanceBetweenUsers = 80;

  // Live Streaming and Calls
  static final int minimumDiamondsToPopular = 100;
  static final int callWaitingDuration = 30; // seconds

  //Withdraw calculations
  static final int diamondsEarnPercent = 60; //Percent to give the streamer.
  static final int withDrawPercent = 50; //Percent to give the streamer.
  static final int agencyPercent = 10; //Percent to give the agency.
  static final int diamondsNeededToRedeem =
      5000; // Minimum diamonds needed to redeem

  // Calls cost
  static final int coinsNeededForVideoCallPerMinute =
      120; //Coins per minute needed to make video call
  static final int coinsNeededForVoiceCallPerMinute =
      60; //Coins per minute needed to make Voice call

  //Leaders
  static final int diamondsNeededForLeaders = 10;

  //Lives
  static final double maxDistanceToNearBy = 500; //In Km
  static final int maxSecondsToShowBigGift = 5; //In seconds

  // Feed
  static final int coinsNeededToForExclusivePost = 50;

  // Ads Config
  static final bool isBannerAdsOnHomeReelsEnabled = true;
  static final bool isAdsOnMessageListEnabled = true;
  static final bool isAdsOnFeedEnabled = false;
  static final bool isOpenAppAdsEnabled = true;

  //Languages Setup
  static List<String> languages = ["en", "fr", "pt", "ar"];

  //Wealth level required for male before go live
  static int wealthRequiredLevel = 10;

  //Social media links
  static const String facebookPage = "https://www.facebook.com";
  static const String facebookProfile = "https://www.facebook.com";
  static const String youtube = "https://www.youtube.com";
  static const String instagram = "https://www.instagram.com";
  static const String gmail = "nemotechhelp@gmail.com";

  //Admob
  static const String admobAndroidWalletReward =
      "ca-app-pub-9318890613494690/8007216714";
  static const int earnCredit = 5;

  //Max video size allowed
  static const maxVideoSize = 10; //MegaBytes

  static const int level1MaxPoint = 117;
  static const int level2MaxPoint = 310;
  static const int level3MaxPoint = 608;
  static const int level4MaxPoint = 1234;
  static const int level5MaxPoint = 2003;
  static const int level7MaxPoint = 4001;
  static const int level8MaxPoint = 5001;
  static const int level9MaxPoint = 6102;
  static const int level10MaxPoint = 7021;
  static const int level11MaxPoint = 8329;
  static const int level12MaxPoint = 9012;
  static const int level13MaxPoint = 10123;
  static const int level14MaxPoint = 11203;
  static const int level15MaxPoint = 12304;
  static const int level16MaxPoint = 13402;
  static const int level17MaxPoint = 14009;
  static const int level18MaxPoint = 15888;
  static const int level19MaxPoint = 16333;
  static const int level20MaxPoint = 17123;
  static const int level21MaxPoint = 18000;
  static const int level22MaxPoint = 19223;
  static const int level23MaxPoint = 20345;
  static const int level24MaxPoint = 21300;
  static const int level25MaxPoint = 22893;
  static const int level26MaxPoint = 23930;
}
