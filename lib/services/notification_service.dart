import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banksample/models/achievement.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // List of all achievements (duplicate from AchievementsScreen, but needed here for notification logic)
  final List<Achievement> _allAchievements = [
    Achievement(
      id: 'money_10',
      title: 'First Savings!',
      description: 'You saved \$10! Keep up the great work!',
      icon: Icons.attach_money,
      isAchieved: (duration, moneySaved) => moneySaved >= 10,
    ),
    Achievement(
      id: 'money_50',
      title: 'Significant Savings!',
      description: 'You saved \$50! Your financial health is improving!',
      icon: Icons.monetization_on,
      isAchieved: (duration, moneySaved) => moneySaved >= 50,
    ),
    Achievement(
      id: 'money_100',
      title: 'Triple Digit Club!',
      description: 'You saved \$100! Imagine what you can do with that!',
      icon: Icons.account_balance_wallet,
      isAchieved: (duration, moneySaved) => moneySaved >= 100,
    ),
    Achievement(
      id: 'money_250',
      title: 'Serious Saver!',
      description: 'You saved \$250! Incredible discipline!',
      icon: Icons.savings,
      isAchieved: (duration, moneySaved) => moneySaved >= 250,
    ),
    Achievement(
      id: 'money_500',
      title: 'Half a Grand!',
      description: 'You saved \$500! A truly remarkable achievement!',
      icon: Icons.currency_exchange,
      isAchieved: (duration, moneySaved) => moneySaved >= 500,
    ),
    Achievement(
      id: 'day_1',
      title: 'First Day Done!',
      description: 'You abstained for 1 full day! Celebrate this victory!',
      icon: Icons.check_circle,
      isAchieved: (duration, moneySaved) => duration.inDays >= 1,
    ),
    Achievement(
      id: 'day_3',
      title: 'Three Days Strong!',
      description:
          'You\'ve made it 3 days! Your body and mind are thanking you.',
      icon: Icons.calendar_today,
      isAchieved: (duration, moneySaved) => duration.inDays >= 3,
    ),
    Achievement(
      id: 'day_7',
      title: 'One Week Warrior!',
      description: 'Congratulations! You completed one week of abstinence!',
      icon: Icons.calendar_view_week,
      isAchieved: (duration, moneySaved) => duration.inDays >= 7,
    ),
    Achievement(
      id: 'day_14',
      title: 'Two Weeks of Freedom!',
      description: 'Fantastic! Two weeks clean and counting!',
      icon: Icons.calendar_month,
      isAchieved: (duration, moneySaved) => duration.inDays >= 14,
    ),
    Achievement(
      id: 'day_30',
      title: 'One Month Milestone!',
      description: 'A whole month! You\'re building incredible momentum!',
      icon: Icons.event,
      isAchieved: (duration, moneySaved) => duration.inDays >= 30,
    ),
    Achievement(
      id: 'day_60',
      title: 'Two Months Momentum!',
      description: 'Sixty days strong! Your commitment is inspiring.',
      icon: Icons.date_range,
      isAchieved: (duration, moneySaved) => duration.inDays >= 60,
    ),
    Achievement(
      id: 'day_90',
      title: 'Three Months Triumph!',
      description: '90 days! You\'ve officially formed a new habit.',
      icon: Icons.event_note,
      isAchieved: (duration, moneySaved) => duration.inDays >= 90,
    ),
    Achievement(
      id: 'hour_24',
      title: '24 Hour Power!',
      description: 'You\'ve abstained for 24 hours! One day at a time!',
      icon: Icons.access_time,
      isAchieved: (duration, moneySaved) => duration.inHours >= 24,
    ),
    Achievement(
      id: 'hour_72',
      title: '72 Hours Clean!',
      description: 'Amazing! Three days without it!',
      icon: Icons.timer,
      isAchieved: (duration, moneySaved) => duration.inHours >= 72,
    ),
    Achievement(
      id: 'hour_168',
      title: 'A Week of Hours!',
      description: 'That\'s 168 hours of freedom! Way to go!',
      icon: Icons.watch_later,
      isAchieved: (duration, moneySaved) => duration.inHours >= 168,
    ),
    Achievement(
      id: 'money_1000',
      title: 'Grand Master Saver!',
      description: 'You\'ve saved a grand! What will you do with it?',
      icon: Icons.attach_money_outlined,
      isAchieved: (duration, moneySaved) => moneySaved >= 1000,
    ),
    Achievement(
      id: 'day_180',
      title: 'Half a Year Hero!',
      description: 'Six months clean! You are a true inspiration.',
      icon: Icons.calendar_month_outlined,
      isAchieved: (duration, moneySaved) => duration.inDays >= 180,
    ),
    Achievement(
      id: 'day_365',
      title: 'One Year Victory!',
      description: 'A full year! You have reclaimed your life!',
      icon: Icons.celebration,
      isAchieved: (duration, moneySaved) => duration.inDays >= 365,
    ),
    Achievement(
      id: 'consistent_quit',
      title: 'Consistent Effort!',
      description:
          'You\'ve maintained your streak for weeks. Consistency is key!',
      icon: Icons.trending_up,
      isAchieved: (duration, moneySaved) => duration.inDays >= 21,
    ),
    Achievement(
      id: 'healthy_mind',
      title: 'Clear Mind!',
      description:
          'You\'re likely experiencing clearer thinking and focus now. Well done!',
      icon: Icons.lightbulb_outline,
      isAchieved: (duration, moneySaved) => duration.inDays >= 10,
    ),
  ];

  Future<void> initNotifications() async {
    tz.initializeTimeZones(); // Initialize timezone data

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        ); // Use your app icon

    // final DarwinInitializationSettings initializationSettingsDarwin =
    //     DarwinInitializationSettings(
    //       onDidReceiveLocalNotification: (id, title, body, payload) async {
    //         // Handle notification tapped when app is in foreground (iOS only)
    //       },
    //     );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          // iOS: initializationSettingsDarwin,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (
        NotificationResponse notificationResponse,
      ) async {
        // Handle notification tapped when app is in background/terminated
        // You can navigate to a specific screen here if needed
      },
    );
  }

  Future<void> _showNotification(int id, String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'achievement_channel', // Channel ID
          'Achievement Notifications', // Channel Name
          channelDescription:
              'Notifications for achievements unlocked in the Quit Weed App',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails darwinPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: 'achievement_payload', // Optional payload
    );
  }

  Future<void> checkAndNotifyAchievements(
    Duration abstainedDuration,
    double moneySaved,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    for (var achievement in _allAchievements) {
      bool alreadyAchieved =
          prefs.getBool('achieved_${achievement.id}') ?? false;

      if (!alreadyAchieved &&
          achievement.isAchieved(abstainedDuration, moneySaved)) {
        // Achievement unlocked!
        await prefs.setBool('achieved_${achievement.id}', true);
        _showNotification(
          achievement.id.hashCode,
          achievement.title,
          achievement.description,
        );
        print('Achievement Unlocked: ${achievement.title}'); // For debugging
      }
    }
  }
}
