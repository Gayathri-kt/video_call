import 'dart:developer';
import 'dart:io';

import 'package:agora_flutter_quickstart/src/pages/call.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:connectycube_sdk/connectycube_calls.dart';
import 'package:connectycube_sdk/connectycube_pushnotifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import 'index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  var textEvents = "";
  ClientRole? _role = ClientRole.Broadcaster;

  @override
  void initState() {
    super.initState();
    textEvents = "";

    firebaseSetup(_firebaseMessaging);
    listenerEvent(onEvent);

  }
  onEvent(event) {
    if (!mounted) return;
    setState(() {
      textEvents += "${event.toString()}\n";
    });
  }
  void firebaseSetup(FirebaseMessaging firebaseMessaging) async {
    String? deviceToken = await firebaseMessaging.getToken();
    debugPrint("Mainoken:$deviceToken");

    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Message clicked!');
      showCallkitIncoming(Uuid().v4());
    });
    // await _firebaseMessaging.subscribeToTopic("Employee");
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

 
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {

      // RemoteMessage initialMessage =
      //     await FirebaseMessaging.instance.getInitialMessage();

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("Message__:${message.notification?.title}");

        showCallkitIncoming(Uuid().v4());

        // If `onMessage` is triggered with a notification, construct our own
        // local notification to show to users using the created channel.
      });
      // debugPrint("Notification: ${initialMessage?.data.toString()}");
      // if (initialMessage?.data['type'] == 'task') {
      /* Navigator.pushNamed(context, '/chat',
            arguments: ChatArguments(initialMessage));*/
      // }
    }
    /* else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    snackBarAlert("Notification Permission is denied");
  }*/
  }
  Future<void> onBackgroundMessage(RemoteMessage message) {
    log('[onBackgroundMessage] message__: ${message.notification?.title}');
    showCallkitIncoming(Uuid().v4());
    // showNotification(message);
    return Future.value();
  }

  Future<void> showCallkitIncoming(String uuid) async {
    var params = <String, dynamic>{
      'id': uuid,
      'nameCaller': 'Hien Nguyen',
      'appName': 'Callkit',
      'avatar': 'https://i.pravatar.cc/100',
      'handle': '0123456789',
      'type': 0,
      'duration': 30000,
      'textAccept': 'Accept',
      'textDecline': 'Decline',
      'textMissedCall': 'Missed call',
      'textCallback': 'Call back',
      'extra': <String, dynamic>{'userId': '1a2b3c4d'},
      'headers': <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      'android': <String, dynamic>{
        'isCustomNotification': true,
        'isShowLogo': true,
        'isShowCallback': true,
        'ringtonePath': 'system_ringtone_default',
        'backgroundColor': '#0955fa',
        'isShowMissedCallNotification': true,
        // 'backgroundUrl': 'https://i.pravatar.cc/500',
        'actionColor': '#4CAF50'
      },
      'ios': <String, dynamic>{
        'iconName': 'CallKitLogo',
        'handleType': '',
        'supportsVideo': true,
        'maximumCallGroups': 2,
        'maximumCallsPerCallGroup': 1,
        'audioSessionMode': 'default',
        'audioSessionActive': true,
        'audioSessionPreferredSampleRate': 44100.0,
        'audioSessionPreferredIOBufferDuration': 0.005,
        'supportsDTMF': true,
        'supportsHolding': true,
        'supportsGrouping': false,
        'supportsUngrouping': false,
        'ringtonePath': 'system_ringtone_default'
      }
    };
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
                  height:45 ,
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ElevatedButton(
              onPressed: () {
                showCallkitIncoming(Uuid().v4());

              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                shadowColor: Colors.green,
              ),
              child:Text("Video Screen",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.white)),
            ),
          ),
        ),
      ),
    );;
  }

  void showNotification(RemoteMessage message) async{
    var initializationSettingsAndroid = const AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    ); // <- default icon name is @mipmap/ic_launcher
    var initializationSettingsIOS = const IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (payload) {
        // Get.toNamed('/notify');
        debugPrint("payload${payload}");
        showCallkitIncoming(Uuid().v4());


      },
    );
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'Employee_channel', // id
        'New Announcement Notifications', // title
        description: 'New Announcement is arrived.', // description
        importance: Importance.max,
        enableLights: true,
        enableVibration: true,
        playSound: true,
        ledColor: Colors.green,
        showBadge: true);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id, channel.name, channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
            largeIcon:
            const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            ledColor: Colors.white,
            ledOnMs: 1000,
            ledOffMs: 500,
            playSound: true,
            enableVibration: true,
            enableLights: true,
            autoCancel: true,
            color: Colors.white,
            styleInformation: const DefaultStyleInformation(true, true),
            // sound: const RawResourceAndroidNotificationSound('slow_spring'),
            // category: "New Announcement",
            channelShowBadge: true,
            // visibility: NotificationVisibility.public,
            // ticker: "New Announcement",
            importance: Importance.max,
            showWhen: false,
            priority: Priority.high,

            // other properties...
          ),
          iOS: const IOSNotificationDetails(presentSound: true),
        ),
      );

/*            setState(() {
              _totalNotifications++;
            });*/

    }
  }
/*  Future<void> _onCallMuted(bool mute, String uuid) async {
    // Called when the system or user mutes a call
    currentCall?.setMicrophoneMute(mute);
  }*/

/*  Future<void> _onCallAccepted(CallEvent callEvent) async {
    // Called when the user answers an incoming call via Call Kit
    ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: true); // useful on Android when accept the call from the Lockscreen
    currentCall?.acceptCall();
  }

  Future<void> _onCallRejected(CallEvent callEvent) async {
    // Called when the user ends an incoming call via Call Kit
    if (!CubeChatConnection.instance.isAuthenticated()) {
      // reject the call via HTTP request
      rejectCall(
          callEvent.sessionId, {...callEvent.opponentsIds, callEvent.callerId});
    } else {
      currentCall?.reject();
    }
  }

  /// This provided handler must be a top-level function and cannot be
  /// anonymous otherwise an [ArgumentError] will be thrown.
  Future<void> onCallRejectedWhenTerminated(CallEvent callEvent) async {
    var currentUser = await SharedPrefs.getUser();
    initConnectycubeContextLess();

    return rejectCall(
        callEvent.sessionId, {...callEvent.opponentsIds.where((userId) => currentUser!.id != userId), callEvent.callerId});
  }

  initConnectycubeContextLess() {
    CubeSettings.instance.applicationId = config.APP_ID;
    CubeSettings.instance.authorizationKey = config.AUTH_KEY;
    CubeSettings.instance.authorizationSecret = config.AUTH_SECRET;
    CubeSettings.instance.onSessionRestore = () {
      return SharedPrefs.getUser().then((savedUser) {
        return createSession(savedUser);
      });
    };
  }*/

  Future<void> listenerEvent(Function? callback) async {
    try {
      FlutterCallkitIncoming.onEvent.listen((event) async {
        print('HOME: $event');
        switch (event!.name) {
          case CallEvent.ACTION_CALL_INCOMING:
          // TODO: received an incoming call
            break;
          case CallEvent.ACTION_CALL_START:
          // TODO: started an outgoing call
          // TODO: show screen calling in Flutter
            break;
          case CallEvent.ACTION_CALL_ACCEPT:
          // TODO: accepted an incoming call
          // TODO: show screen calling in Flutter
            await _handleCameraAndMic(Permission.camera);
            await _handleCameraAndMic(Permission.microphone);

          Get.to(CallPage(channelName: "gayathri",role: _role,));
            break;
          case CallEvent.ACTION_CALL_DECLINE:
          // TODO: declined an incoming call
          //   await requestHttp("ACTION_CALL_DECLINE_FROM_DART");
            break;
          case CallEvent.ACTION_CALL_ENDED:
          // TODO: ended an incoming/outgoing call
            break;
          case CallEvent.ACTION_CALL_TIMEOUT:
          // TODO: missed an incoming call
            break;
          case CallEvent.ACTION_CALL_CALLBACK:
          // TODO: only Android - click action `Call back` from missed call notification
            break;
          case CallEvent.ACTION_CALL_TOGGLE_HOLD:
          // TODO: only iOS
            break;
          case CallEvent.ACTION_CALL_TOGGLE_MUTE:
          // TODO: only iOS
            break;
          case CallEvent.ACTION_CALL_TOGGLE_DMTF:
          // TODO: only iOS
            break;
          case CallEvent.ACTION_CALL_TOGGLE_GROUP:
          // TODO: only iOS
            break;
          case CallEvent.ACTION_CALL_TOGGLE_AUDIO_SESSION:
          // TODO: only iOS
            break;
          case CallEvent.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
          // TODO: only iOS
            break;
        }
        if (callback != null) {
          callback(event.toString());
        }
      });
    } on Exception {}
  }
  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}
