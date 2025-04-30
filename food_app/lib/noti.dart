import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class Noti {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

 final bool _isInitialized = false; 

  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async{
    if (_isInitialized) return;

    // for android
    const initSettingsAndroid = 
    AndroidInitializationSettings('@mipmap/logo');

    //For iOS
    const initSettingIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true, 
      requestSoundPermission: true, 
    );

    //bruger metoderne der er lavet til at sætte det sammen
    const initSettings = InitializationSettings(
      android: initSettingsAndroid, 
      iOS: initSettingIOS, 
    );

    //sæt plugin i gang
    await notificationsPlugin.initialize(initSettings);
  }

// //Sæt notifikationerne   op

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        // //HER SKAL VI UDFYLDE DETALJERNE FRA NOTIFIKATIONEN. MITCH HAR SKREVET DETTE
        'daily_channel_id',
        'Daily Notifications',
        channelDescription: 'Daily notifications channel',
        importance: Importance.max, 
        priority: Priority.high
      ),
      iOS: DarwinNotificationDetails()
    );
  }

  //Vis notifikationen 
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload, 
  }) async {
    return notificationsPlugin.show(
      id, 
      title, 
      body, 
    const NotificationDetails()
    );
  }

}