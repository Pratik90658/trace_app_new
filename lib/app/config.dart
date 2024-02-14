import 'dart:ui';

class Config {
  static const String packageNameAndroid = "com.nemochatapp.tech";
  static const String packageNameiOS = "com.nemochatapp.tech";
  static const String iosAppStoreId = "";
  static final String appName = "Nemo Chat";
  static final String appVersion = "1.0.2";
  static final String companyName = "Nemo Tech";
  static final String appOrCompanyUrl = "https://nemo.live";
  static final String initialCountry = 'US'; // United States

  static final String serverUrl = "https://parseapi.back4app.com";
  static final String liveQueryUrl = "wss://nemochatapp.b4a.io";
  static final String appId = "qKJZnTU1BfNVq9FvkmQVYWG46365gDdmhDV47s4w";
  static final String clientKey = "MoShiIpZqIo4umKKcpBi4qCS9uoPR7EHmFLHmVAp";

  // Firebase Cloud Messaging
  static final String pushGcm = "22993218649";
  static final String webPushCertificate =
      "BD7GuLewTK3GZ6CVieGaH9FiaWCCfUA2vjaZJeaQpFacyMSKsM5vfV887AZFmqPX-lZmOz_lB5Vi-CRtl6Kbubg";

  // User support objectId
  static final String supportId = "";

  // Play Store and App Store public keys
  static final String publicGoogleSdkKey = "";
  static final String publicIosSdkKey = "";

  // Languages
  static String defaultLanguage = "en"; // English is default language.
  static List<Locale> languages = [
    Locale(defaultLanguage),
    //Locale('pt'),
    //Locale('fr')
  ];

  // Dynamic link
  static const String inviteSuffix = "";
  static const String uriPrefix = "https..link";
  static const String link = "https://..link";

  // Android Admob ad
  static const String admobAndroidOpenAppAd =
      "ca-app-pub-9318890613494690/4325316561";
  static const String admobAndroidHomeBannerAd =
      "ca-app-pub-9318890613494690/8240828077";
  static const String admobAndroidFeedNativeAd =
      "ca-app-pub-9318890613494690/9362338057";
  static const String admobAndroidChatListBannerAd =
      "ca-app-pub-9318890613494690/6736174716";
  static const String admobAndroidLiveBannerAd =
      "ca-app-pub-9318890613494690/7959371442";
  static const String admobAndroidFeedBannerAd =
      "ca-app-pub-9318890613494690/9362338057";

  // iOS Admob ad
  static const String admobIOSOpenAppAd =
      "ca-app-pub-1084112649181796/6328973508";
  static const String admobIOSHomeBannerAd =
      "ca-app-pub-1084112649181796/1185447057";
  static const String admobIOSFeedNativeAd =
      "ca-app-pub-1084112649181796/7224203806";
  static const String admobIOSChatListBannerAd =
      "ca-app-pub-1084112649181796/5811376758";
  static const String admobIOSLiveBannerAd =
      "ca-app-pub-1084112649181796/8093979063";
  static const String admobIOSFeedBannerAd =
      "ca-app-pub-1084112649181796/6907075815";

  // Web links for help, privacy policy and terms of use.
  static final String helpCenterUrl = "https://nemotech.in/tnc.php";
  static final String privacyPolicyUrl = "https://nemotech.in/privacy.php";
  static final String termsOfUseUrl = "https://nemotech.in/tnc.php";
  static final String termsOfUseInAppUrl = "https://nemotech.in/tnc.php";
  static final String dataSafetyUrl = "https://nemotech.in/tnc.php";
  static final String openSourceUrl = "https://nemotech.in/tnc.php";
  static final String instructionsUrl = "https://nemotech.in/tnc.php";
  static final String cashOutUrl = "https://nemotech.in/tnc.php";
  static final String supportUrl = "https://nemotech.in/tnc.php";
  static final String liveAgreementUrl = "https://nemotech.in/live.html";
  static final String userAgreementUrl = "https://nemotech.in/user.html";

  // Google Play and Apple Pay In-app Purchases IDs
  static final String credit100 = "nemo.100.credits";
  static final String credit200 = "nemo.200.credits";
  static final String credit500 = "nemo.500.credits";
  static final String credit1000 = "nemo.1000.credits";
  static final String credit2100 = "nemo.2100.credits";
  static final String credit5250 = "nemo.5250.credits";
  static final String credit10500 = "nemo.10500.credits";
}
