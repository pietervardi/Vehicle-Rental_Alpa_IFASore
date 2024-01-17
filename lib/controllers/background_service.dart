import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground
    ), 
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'foreground',
      initialNotificationTitle: 'Foreground Service',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888
    )
  );
  service.startService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'foreground',
    'Foreground Service',
    description: 'This channel is used for important notifications.',
    importance: Importance.low
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  DateTime now = DateTime.now();

  DateTime nextPromotionalTime = now.add(const Duration(minutes: 5));
  DateTime nextDiscountTime = now.add(const Duration(minutes: 10));

  Timer.periodic(Duration(
    seconds: nextPromotionalTime.isBefore(nextDiscountTime) 
      ? 30 
      : 60
  ), (timer) {
    if (nextPromotionalTime.isBefore(nextDiscountTime)) {
      showPromotionalNotification(flutterLocalNotificationsPlugin);
      nextPromotionalTime = nextPromotionalTime.add(const Duration(seconds: 30));
    } else {
      showDiscountNotification(flutterLocalNotificationsPlugin);
      nextDiscountTime = nextDiscountTime.add(const Duration(minutes: 1));
    }
  });
}

void showPromotionalNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
  flutterLocalNotificationsPlugin.show(
    888,
    'RentALPHA',
    "Planning your trip? Pick a vechicle from our app and we promise you'll look cool!",
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'foreground', 
        'Foreground Service',
        icon: 'ic_bg_service_small',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: false,
        autoCancel: true,
        tag: 'special_offer',
        groupKey: 'group_key',
      )
    )
  );
}

void showDiscountNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
  flutterLocalNotificationsPlugin.show(
    889,
    '15% discount just for you!',
    'Car you booked is now 15% off.',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'foreground', 
        'Foreground Service',
        icon: 'ic_bg_service_small',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: false,
        autoCancel: true,
        tag: 'special_offer',
        groupKey: 'group_key',
      )
    )
  );
}