// ignore_for_file: deprecated_member_use
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace/app/constants.dart';
import 'package:trace/home/profile/tab_profile_screen.dart';
import 'package:trace/home/feed/feed_home_screen.dart';
import 'package:trace/home/profile/profile_edit.dart';
import 'package:trace/models/MessageModel.dart';
import 'package:trace/models/OfficialAnnouncementModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/providers/calls_providers.dart';
import 'package:trace/ui/button_widget.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/utils/shared_manager.dart';
import 'package:trace/widgets/component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vibration/vibration.dart';

import '../app/setup.dart';
import '../auth/welcome_screen.dart';
import '../models/NotificationsModel.dart';
import '../services/dynamic_link_service.dart';
import 'admob/AppLifecycleReactor.dart';
import 'admob/AppOpenAdManager.dart';
import 'live/live_preview.dart';
import 'live/live_screen.dart';
import 'message/message_list_screen.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  static const String route = '/home';

  UserModel? currentUser;
  SharedPreferences? preferences;
  int? initialTabIndex;

  HomeScreen(
      {this.initialTabIndex, this.currentUser, required this.preferences});

  /* static of(BuildContext context, {bool root = false}) => root
      ? context.findRootAncestorStateOfType<_HomeScreenState>()
      : context.findAncestorStateOfType<_HomeScreenState>();*/

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppLifecycleReactor _appLifecycleReactor;

  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  bool? hasVibrator;
  bool? hasAmplitude;
  bool? hasCustomDuration;
  int unreadMessageMount = 0;

  LiveQuery liveQuery = LiveQuery();
  Subscription? subscription;

  late QueryBuilder<NotificationsModel> notificationQueryBuilder;
  late QueryBuilder<MessageModel> messageQueryBuilder;
  late QueryBuilder<OfficialAnnouncementModel> officialAssistantQueryBuilder;
  var officialAnnouncements = [];
  bool messageCounted = false;
  bool announceCounted = false;

  getUnreadNotification() async {
    notificationQueryBuilder =
        QueryBuilder<NotificationsModel>(NotificationsModel());
    notificationQueryBuilder.whereEqualTo(
        NotificationsModel.keyReceiver, widget.currentUser!);
    notificationQueryBuilder.whereEqualTo(NotificationsModel.keyRead, false);

    notificationQueryBuilder.whereNotEqualTo(
        NotificationsModel.keyAuthor, widget.currentUser!);

    setupNotificationLiveQuery();

    ParseResponse parseResponse = await notificationQueryBuilder.query();

    if (parseResponse.success || parseResponse.count > 0) {
      unreadMessageMount += parseResponse.count;
    }
  }

  getUnreadMessage() async {
    messageQueryBuilder = QueryBuilder<MessageModel>(MessageModel());
    messageQueryBuilder.whereEqualTo(
        MessageModel.keyReceiver, widget.currentUser!);
    messageQueryBuilder.whereEqualTo(MessageModel.keyRead, false);

    messageQueryBuilder.whereNotEqualTo(
        NotificationsModel.keyAuthor, widget.currentUser!);

    setupMessageLiveQuery();

    ParseResponse parseResponse = await messageQueryBuilder.query();

    if (parseResponse.success || parseResponse.count > 0) {
      unreadMessageMount += parseResponse.count;
    }
  }

  getUnreadOfficial() async {
    officialAssistantQueryBuilder =
        QueryBuilder<OfficialAnnouncementModel>(OfficialAnnouncementModel());
    officialAssistantQueryBuilder.whereNotEqualTo(
        NotificationsModel.keyAuthor, widget.currentUser!);

    setupOfficialLiveQuery();

    ParseResponse parseResponse = await officialAssistantQueryBuilder.query();

    if (parseResponse.success) {
      if (parseResponse.results != null) {
        for (OfficialAnnouncementModel announcement in parseResponse.results!) {
          if (!announcement.getViewedBy!
              .contains(widget.currentUser!.objectId!)) {
            officialAnnouncements.add(announcement.objectId);
          }
        }
        unreadMessageMount += officialAnnouncements.length;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _loadAd();
  }

  @override
  void dispose() {
    super.dispose();
    if (subscription != null) {
      liveQuery.client.unSubscribe(subscription!);
    }
    //_anchoredAdaptiveAd?.dispose();
  }

  initializeVibrator() async {
    hasVibrator = await Vibration.hasVibrator();
    hasAmplitude = await Vibration.hasAmplitudeControl();
    hasAmplitude = await Vibration.hasCustomVibrationsSupport();
  }

  vibrate() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    bool? hasAmplitude = await Vibration.hasAmplitudeControl();

    if (hasVibrator!) {
      Vibration.vibrate(
        amplitude: hasAmplitude != null ? 128 : -1,
        duration: hasAmplitude != null ? 80 : 500,
      );
    }
  }

  Future<void> _loadAd() async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final AnchoredAdaptiveBannerAdSize? size =
    await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    } else {
      print('Got to get height of anchored banner.');
    }

    _anchoredAdaptiveAd = BannerAd(
      // TODO: replace these test ad units with your own ad unit.
      adUnitId: Constants.getAdmobHomeBannerUnit(),
      size: size,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$ad loaded: ${ad.responseInfo}');
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd!.load();
  }

  TextEditingController inviteTextController = TextEditingController();
  bool hasNotification = false;

  int _selectedIndex = 1;
  double iconSize = 30;

  static bool appTrackingDialogShowing = false;

  double _getElevation() {
    if (_selectedIndex == 0) {
      return 0;
    } else {
      return 8;
    }
  }

  /*

  cleanStories() async {
    var idList = [];
    QueryBuilder<StoriesModel> queryStory =
    QueryBuilder<StoriesModel>(StoriesModel());
    queryStory.whereLessThan(StoriesModel.keyExpiration, DateTime.now());

    ParseResponse response = await queryStory.query();

    if (response.success) {
      if (response.result != null) {
        for (StoriesModel stories in response.results!) {
          if (!idList.contains(stories.objectId)) {
            idList.add(stories.objectId);
          }
        }
        if (idList.isNotEmpty) {
          cleanAuthors(idList);
        }
      }
    }
  }

  cleanAuthors(List idList) async {
    QueryBuilder<StoriesAuthorsModel> queryStoryAuthor =
    QueryBuilder<StoriesAuthorsModel>(StoriesAuthorsModel());

    ParseResponse result = await queryStoryAuthor.query();

    if (result.success) {
      if (result.result != null) {
        for (StoriesAuthorsModel storyAuthor in result.results!) {
          for (var i = 0; i < idList.length; i++) {
            storyAuthor.setRemoveStory = idList[i];
            storyAuthor.save();
          }
        }
      }
    }
  }

  */

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    vibrate();
    //getUser(updateLocation: false);
  }

  List<Widget> _widgetOptions() {
    //_checkNotifications();

    List<Widget> widgets = [

      FeedHomeScreen(
        currentUser: widget.currentUser,
        preferences: widget.preferences,
      ),
      LiveScreen(
        currentUser: widget.currentUser != null
            ? widget.currentUser
            : widget.currentUser,
        preferences: widget.preferences,
      ),
      LivePreviewScreen(
        currentUser: widget.currentUser!,
        liveTypeIndex: 1,
      ),
      MessagesListScreen(
        currentUser: widget.currentUser != null
            ? widget.currentUser
            : widget.currentUser,
        preferences: widget.preferences,
      ),
      TabProfileScreen(
        currentUser: widget.currentUser != null
            ? widget.currentUser
            : widget.currentUser,
        preferences: widget.preferences,
      ),
    ];

    return widgets;
  }

  BottomNavigationBar bottomNavBar() {
    bool isDark = QuickHelp.isDarkMode(context);
    Color bgColor = _selectedIndex == 2
        ? kTransparentColor
        : QuickHelp.isDarkMode(context)
        ? kContentColorLightTheme
        : kContentColorDarkTheme;
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            backgroundColor: bgColor,
            icon: Component.buildNavIcon(
                Image.asset(
                    _selectedIndex == 1
                        ? "assets/svg/category.png"
                        : "assets/svg/menu.png",
                    height: 30,
                    width: 30,
                    color: Colors.amber
                ),
                0,
                false,
                context),
            label: "Feed"),
        BottomNavigationBarItem(
            backgroundColor: bgColor,
            icon: Component.buildNavIcon(
                Image.asset(
                    _selectedIndex == 1
                        ? "assets/svg/balls.png"
                        : "assets/svg/ballp.png",
                    height: 30,
                    width: 30,
                    color:  Colors.amber
                ),
                1,
                false,
                context, badge: 12),
            label: "Live"),
        BottomNavigationBarItem(
            backgroundColor: bgColor,
            icon: Component.buildNavIcon(
                Image.asset(
                  _selectedIndex == 2
                      ? "assets/svg/live.png"
                      : "assets/svg/live.png",
                  height: 30,
                  width: 30,

                ),
                2,
                false,
                context,
                color: 0xFF27E150,
                badge: 15),
            label: "Streaming"),
        BottomNavigationBarItem(
          backgroundColor: bgColor,
          icon: Component.buildNavIcon(
              Image.asset(
                  _selectedIndex == 3
                      ? "assets/svg/chat.png"
                      : "assets/svg/chat.png",
                  height: 30,
                  width: 30,
                  color: Colors.amber
              ),
              3,
              unreadMessageMount > 0,
              badge: unreadMessageMount,
              context),
          label:'Message',
        ),
        BottomNavigationBarItem(
          backgroundColor: kTransparentColor,
          label: "Profile",
          icon:  Image.asset(
            _selectedIndex == 4
                ? "assets/svg/user-avatar.png"
                : "assets/svg/user-avatar.png",
            height: 30,
            width: 30,
            color: Colors.amber,
          ),
        ),
      ],
      type: BottomNavigationBarType.fixed,
      elevation: _getElevation(),
      currentIndex: _selectedIndex,
      selectedItemColor: kPrimaryColor,
      backgroundColor: bgColor,
      unselectedItemColor:
      Colors.green,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      selectedLabelStyle: TextStyle(
          color: kPrimaryColor, fontSize: 12, fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(
          color:  Colors.amber ,
          fontSize: 12,
          fontWeight: FontWeight.bold),
      onTap: (index) => onItemTapped(index),
    );
  }

  checkUser() async {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();

    if (widget.currentUser!.getFullName!.isNotEmpty) {
      Purchases.setDisplayName(widget.currentUser!.getFullName!);
    }

    if (widget.currentUser!.getEmail != null) {
      Purchases.setEmail(widget.currentUser!.getEmail!);
    }

    if (widget.currentUser!.getGender != null) {
      Map<String, String> params = <String, String>{
        "Gender": widget.currentUser!.getGender!,
      };
      Purchases.setAttributes(params);
    }

    if (widget.currentUser!.getAge != null) {
      Map<String, String> params = <String, String>{
        "Age": widget.currentUser!.getAge.toString(),
      };
      Purchases.setAttributes(params);
    }

    if (widget.currentUser!.getBirthday != null) {
      Map<String, String> params = <String, String>{
        "Birthday":
        QuickHelp.getBirthdayFromDate(widget.currentUser!.getBirthday!),
      };
      Purchases.setAttributes(params);
    }

    print("USER PURCHASES: $customerInfo");
  }

  Future<void> checkPermissionAudio() async {
    if (QuickHelp.isAndroidPlatform()) {
      PermissionStatus status = await Permission.storage.status;
      PermissionStatus status2 = await Permission.camera.status;
      PermissionStatus status3 = await Permission.microphone.status;
      PermissionStatus status4 = await Permission.audio.status;

      print('Permission android');

      // Check if any permission is not granted
      if (status != PermissionStatus.granted ||
          status2 != PermissionStatus.granted ||
          status3 != PermissionStatus.granted ||
          status4 != PermissionStatus.granted) {
        // If any permission is not granted, request them
        checkStatusAudio(status, status2, status3, status4);
      } else {
        // All permissions are already granted, you can handle it accordingly
        print('All audio permissions are already granted');
      }
    } else if (QuickHelp.isIOSPlatform()) {
      PermissionStatus status = await Permission.photos.status;
      PermissionStatus status2 = await Permission.camera.status;
      PermissionStatus status3 = await Permission.microphone.status;
      PermissionStatus status4 = await Permission.audio.status;

      print('Permission ios');

      // Check if any permission is not granted
      if (status != PermissionStatus.granted ||
          status2 != PermissionStatus.granted ||
          status3 != PermissionStatus.granted ||
          status4 != PermissionStatus.granted) {
        // If any permission is not granted, request them
        checkStatusAudio(status, status2, status3, status4);
      } else {
        // All permissions are already granted, you can handle it accordingly
        print('All audio permissions are already granted');
      }
    } else {
      print('Permission other device');
    }
  }


  void checkStatusAudio(PermissionStatus status, PermissionStatus status2,
      PermissionStatus status3,PermissionStatus status4) {
    if (status.isDenied || status2.isDenied || status3.isDenied) {
      QuickHelp.showDialogPermission(
          context: context,
          title: "permissions.photo_access".tr(),
          confirmButtonText: "permissions.okay_".tr().toUpperCase(),
          message: "permissions.photo_access_explain"
              .tr(namedArgs: {"app_name": Setup.appName}),
          onPressed: () async {
            QuickHelp.hideLoadingDialog(context);
            Map<Permission, PermissionStatus> statuses = await [
              Permission.camera,
              Permission.photos,
              Permission.storage,
              Permission.audio,
              Permission.microphone,
            ].request();

            if (statuses[Permission.camera]!.isGranted &&
                statuses[Permission.photos]!.isGranted ||
                statuses[Permission.storage]!.isGranted ||statuses[Permission.audio]!.isGranted||
                statuses[Permission.microphone]!.isGranted) {
              print("all permissions granted");
            }
          });
    } else if (status.isPermanentlyDenied ||
        status2.isPermanentlyDenied ||
        status3.isPermanentlyDenied) {
      QuickHelp.showDialogPermission(
          context: context,
          title: "permissions.photo_access_denied".tr(),
          confirmButtonText: "permissions.okay_settings".tr().toUpperCase(),
          message: "permissions.photo_access_denied_explain"
              .tr(namedArgs: {"app_name": Setup.appName}),
          onPressed: () {
            QuickHelp.hideLoadingDialog(context);

            openAppSettings();
          });
    } else if (status.isGranted && status2.isGranted && status3.isGranted) {
      print("all permissions granted");
    }

    print('Permission $status');
    print('Permission $status2');
    print('Permission $status3');
  }

  @override
  void initState() {
    super.initState();


    getUnreadNotification();
    getUnreadMessage();
    getUnreadOfficial();

    Future.delayed(Duration(seconds: 2), () {
      DynamicLinkService().openSharedContents(
        currentUser: widget.currentUser!,
        preferences: widget.preferences!,
        context: context,
      );
    });

    initializeVibrator();
    QuickHelp.saveCurrentRoute(route: HomeScreen.route);
    initSharedPref();
    checkUser();

    _selectedIndex = widget.initialTabIndex ?? _selectedIndex;

    Future.delayed(Duration(seconds: 2), () {
      if (QuickHelp.isIOSPlatform()) {
        if (!mounted) return; // Try
        showAppTrackingPermission(context);
      }
    });

    if (Setup.isOpenAppAdsEnabled) {
      AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd();
      _appLifecycleReactor =
          AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
      _appLifecycleReactor.listenToAppStateChanges();
    }
  }

  bool checkHomeBannerAdReels() {
    if (SharedManager().isBannerAdsOnHomeReelsEnabled(widget.preferences)) {
      return true;
    } else {
      if (_selectedIndex == 4) {
        return false;
      } else {
        return true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentUser != null) {
      widget.currentUser = widget.currentUser;

      context.read<CallsProvider>().isAgoraUserLogged(widget.currentUser);
    } else if (ModalRoute.of(context)!.settings.arguments != null) {
      widget.currentUser =
      ModalRoute.of(context)!.settings.arguments as UserModel;

      context.read<CallsProvider>().isAgoraUserLogged(widget.currentUser);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: _selectedIndex == 2,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _widgetOptions().elementAt(_selectedIndex),
          ),
          // if (_anchoredAdaptiveAd != null &&
          //     _isLoaded &&
          //     checkHomeBannerAdReels())
          //   Container(
          //     //color: Colors.green,
          //     width: _anchoredAdaptiveAd!.size.width.toDouble(),
          //     height: _anchoredAdaptiveAd!.size.height.toDouble(),
          //     child: AdWidget(ad: _anchoredAdaptiveAd!),
          //   )
          //Container(height: 50, color: Colors.purpleAccent,)
        ],
      ),
      //_widgetOptions().elementAt(_selectedIndex),
      bottomNavigationBar: bottomNavBar(),
    );
  }

  Widget getCoinsWidget(
      {double? coinIconSize, Color? coinsColor, String? coinsIcon}) {
    QueryBuilder<UserModel> queryBuilder =
    QueryBuilder<UserModel>(UserModel.forQuery());
    queryBuilder.whereEqualTo(keyVarObjectId, widget.currentUser!.objectId!);

    return ParseLiveListWidget<UserModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      duration: Duration(seconds: 0),
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<ParseObject> snapshot) {
        if (snapshot.hasData) {
          UserModel updatedUser = snapshot.loadedData! as UserModel;
          widget.currentUser = updatedUser;

          if (QuickHelp.isAccountDisabled(updatedUser)) {
            print("User updated accountDisabled true");

            widget.currentUser!.logout(deleteLocalUserData: true).then((value) {
              QuickHelp.goToPageWithClear(
                context,
                WelcomeScreen(),
              );
            }).onError(
                  (error, stackTrace) {},
            );
          } else {
            print("User updated accountDisabled false");
          }

          //print("User updated, old value: ${widget.currentUser!.getCredits.toString()}");
          //print("User updated, new value: ${updatedUser.getCredits.toString()}");

          return coinsWidget(
            coinIconSize: coinIconSize,
            coinsColor: coinsColor,
            coinsIcon: coinsIcon,
            coins: updatedUser.getCredits.toString(),
          );
        } else {
          return coinsWidget(
            coinIconSize: coinIconSize,
            coinsColor: coinsColor,
            coinsIcon: coinsIcon,
            coins: "...",
          );
        }
      },
      queryEmptyElement: coinsWidget(
        coinIconSize: coinIconSize,
        coinsColor: coinsColor,
        coinsIcon: coinsIcon,
        coins: "",
      ),
      listLoadingElement: coinsWidget(
        coinIconSize: coinIconSize,
        coinsColor: coinsColor,
        coinsIcon: coinsIcon,
        coins: "...",
      ),
    );
  }

  Widget coinsWidget(
      {double? coinIconSize,
        Color? coinsColor,
        String? coinsIcon,
        String? coins}) {
    return Row(
      children: [
        SvgPicture.asset(coinsIcon!, width: coinIconSize, height: coinIconSize),
        TextWithTap(
          coins!,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          marginLeft: 6,
          color: coinsColor,
        ),
      ],
    );
  }

  void showNameModal() {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        isDismissible: false,
        builder: (context) {
          return _showBottomSheetUpdateName();
        });
  }

  Widget _showBottomSheetUpdateName() {
    return Container(
      color: Color.fromRGBO(0, 0, 0, 0.001),
      child: GestureDetector(
        onTap: () {},
        child: DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.1,
          maxChildSize: 1.0,
          builder: (_, controller) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(
                    //color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(25.0),
                      topRight: const Radius.circular(25.0),
                    ),
                  ),
                  child: ContainerCorner(
                    radiusTopRight: 25.0,
                    radiusTopLeft: 25.0,
                    color: QuickHelp.isDarkMode(context)
                        ? kContentColorLightTheme
                        : Colors.white,
                    child: SafeArea(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                TextWithTap(
                                  "profile_screen.change_name_title".tr(),
                                  marginTop: 10,
                                  marginBottom: 20,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                TextWithTap(
                                  "profile_screen.change_name_explain".tr(),
                                  fontSize: 16,
                                  textAlign: TextAlign.center,
                                  marginLeft: 20,
                                  marginRight: 20,
                                ),
                              ],
                            ),
                            ButtonWidget(
                              width: 100,
                              height: 30,
                              padding: EdgeInsets.only(left: 10, right: 10),
                              marginBottom: 20,
                              borderRadiusAll: 30,
                              color: kPrimaryColor,
                              child: TextWithTap(
                                "profile_screen.change_btn".tr(),
                                color: Colors.white,
                              ),
                              onTap: () async {
                                QuickHelp.hideLoadingDialog(context);

                                UserModel? user = await QuickHelp
                                    .goToNavigatorScreenForResult(
                                    context,
                                    ProfileEdit(
                                      currentUser: widget.currentUser,
                                    ));

                                if (user != null) {
                                  widget.currentUser = user;
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  showAppTrackingPermission(BuildContext context) async {
    // Show tracking authorization dialog and ask for permission
    try {
      // If the system can show an authorization request dialog
      TrackingStatus status =
      await AppTrackingTransparency.trackingAuthorizationStatus;

      if (status == TrackingStatus.notSupported) {
        print("TrackingPermission notSupported");
      } else if (status == TrackingStatus.notDetermined) {
        // Show a custom explainer dialog before the system dialog

        if (!appTrackingDialogShowing) {
          appTrackingDialogShowing = true;

          QuickHelp.showDialogPermission(
              context: context,
              dismissible: false,
              confirmButtonText:
              "permissions.allow_tracking".tr().toUpperCase(),
              title: "permissions.allow_app_tracking".tr(),
              message: "permissions.app_tracking_explain".tr(),
              onPressed: () async {
                QuickHelp.goBackToPreviousPage(context);
                appTrackingDialogShowing = false;
                await AppTrackingTransparency.requestTrackingAuthorization()
                    .then((value) async {
                  if (status == TrackingStatus.authorized) {
                    await FacebookAuth.i.autoLogAppEventsEnabled(true);
                  }
                });
              });
        }
      }
    } on PlatformException {
      // Unexpected exception was thrown
    }
  }

  showError(int code) {
    QuickHelp.hideLoadingDialog(context);
    QuickHelp.showErrorResult(context, code);
  }

  initSharedPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Constants.queryParseConfig(preferences);
  }

  setupNotificationLiveQuery() async {
    subscription = await liveQuery.client.subscribe(notificationQueryBuilder);

    print('*** INITIALIZE_Live_query ***');

    subscription!.on(LiveQueryEvent.create,
            (NotificationsModel notification) async {
          print('*** CREATED_Live_query ***');

          if (notification.isRead!) {
            unreadMessageMount--;
          } else {
            unreadMessageMount++;
          }
        });

    subscription!.on(LiveQueryEvent.update,
            (NotificationsModel notification) async {
          print('*** UPDATE_Live_query ***');
          if (notification.isRead!) {
            unreadMessageMount--;
          } else {
            unreadMessageMount++;
          }
        });

    subscription!.on(LiveQueryEvent.enter,
            (NotificationsModel notification) async {
          print('*** ENTER_Live_query ***');
          if (notification.isRead!) {
            unreadMessageMount--;
          } else {
            unreadMessageMount++;
          }
        });

    subscription!.on(LiveQueryEvent.leave,
            (NotificationsModel notification) async {
          print('*** Leave_Live_query ***');
          if (notification.isRead!) {
            unreadMessageMount--;
          } else {
            unreadMessageMount++;
          }
        });
  }

  setupMessageLiveQuery() async {
    subscription = await liveQuery.client.subscribe(messageQueryBuilder);

    print('*** INITIALIZE_Live_query ***');

    subscription!.on(LiveQueryEvent.create, (MessageModel message) async {
      print('*** CREATED_Live_query ***');

      if (message.isRead!) {
        unreadMessageMount--;
      } else {
        unreadMessageMount++;
        messageCounted = true;
      }
    });

    subscription!.on(LiveQueryEvent.update, (MessageModel message) async {
      print('*** UPDATE_Live_query ***');
      if (message.isRead!) {
        unreadMessageMount--;
      } else {
        if (!messageCounted) {
          unreadMessageMount++;
        }
        messageCounted = false;
      }
    });

    subscription!.on(LiveQueryEvent.enter, (MessageModel message) async {
      print('*** ENTER_Live_query ***');
      if (message.isRead!) {
        unreadMessageMount--;
      } else {
        unreadMessageMount++;
      }
    });

    subscription!.on(LiveQueryEvent.leave, (MessageModel message) async {
      print('*** Leave_Live_query ***');
      if (message.isRead!) {
        unreadMessageMount--;
      } else {
        unreadMessageMount++;
      }
    });
  }

  setupOfficialLiveQuery() async {
    subscription =
    await liveQuery.client.subscribe(officialAssistantQueryBuilder);

    print('*** INITIALIZE_Live_query ***');

    subscription!.on(LiveQueryEvent.create,
            (OfficialAnnouncementModel official) async {
          print('*** CREATED_Live_query ***');

          if (!official.getViewedBy!.contains(widget.currentUser!.objectId!)) {
            officialAnnouncements.add(official.objectId);
            unreadMessageMount++;
            announceCounted = true;
          }
        });

    subscription!.on(LiveQueryEvent.update,
            (OfficialAnnouncementModel official) async {
          print('*** UPDATE_Live_query ***');
          if (!official.getViewedBy!.contains(widget.currentUser!.objectId!)) {
            officialAnnouncements.add(official.objectId);
            unreadMessageMount++;
          } else {
            if (!announceCounted) {
              unreadMessageMount++;
            }
            announceCounted = false;
          }
        });

    subscription!.on(LiveQueryEvent.enter,
            (OfficialAnnouncementModel official) async {
          print('*** ENTER_Live_query ***');
          if (!official.getViewedBy!.contains(widget.currentUser!.objectId!)) {
            officialAnnouncements.add(official.objectId);
            unreadMessageMount++;
            announceCounted = true;
          }
        });

    subscription!.on(LiveQueryEvent.leave,
            (OfficialAnnouncementModel official) async {
          print('*** Leave_Live_query ***');
          if (official.getViewedBy!.contains(widget.currentUser!.objectId!)) {
            officialAnnouncements.add(official.objectId);
            unreadMessageMount--;
          }
        });
  }
}
