import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banksample/models/achievement.dart';
import 'dart:async'; // For Stream.periodic to update achievements in real-time

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  DateTime? _quitTime;
  double _pricePerSession = 0.0;
  int _timesPerDay = 0;
  final Map<String, bool> _achievedStatus =
      {}; // Map to store achievement completion status

  @override
  void initState() {
    super.initState();
    _loadQuitData();
  }

  Future<void> _loadQuitData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _quitTime = DateTime.fromMillisecondsSinceEpoch(
        prefs.getInt('quit_timestamp') ?? DateTime.now().millisecondsSinceEpoch,
      );
      _pricePerSession =
          double.tryParse(prefs.getString('price_per_session') ?? '0.0') ?? 0.0;
      _timesPerDay = int.tryParse(prefs.getString('times_per_day') ?? '0') ?? 0;
      _loadAchievedStatus(prefs);
    });
  }

  void _loadAchievedStatus(SharedPreferences prefs) {
    for (var achievement in _allAchievements) {
      _achievedStatus[achievement.id] =
          prefs.getBool('achieved_${achievement.id}') ?? false;
    }
  }

  // Calculate money saved (duplicate from HomeScreen for self-containment, or pass from parent)
  double _calculateMoneySaved(Duration duration) {
    if (_pricePerSession == 0.0 || _timesPerDay == 0) return 0.0;
    double sessionsPerDayCost = _pricePerSession * _timesPerDay;
    double hoursSaved = duration.inHours.toDouble();
    double daysSaved = hoursSaved / 24.0;
    return daysSaved * sessionsPerDayCost;
  }

  // List of all achievements
  final List<Achievement> _allAchievements = [
    Achievement(
      id: 'money_10',
      title: 'First Savings!',
      description: 'Saved \$10!',
      icon: Icons.attach_money,
      isAchieved: (duration, moneySaved) => moneySaved >= 10,
    ),
    Achievement(
      id: 'money_50',
      title: 'Significant Savings!',
      description: 'Saved \$50!',
      icon: Icons.monetization_on,
      isAchieved: (duration, moneySaved) => moneySaved >= 50,
    ),
    Achievement(
      id: 'money_100',
      title: 'Triple Digit Club!',
      description: 'Saved \$100!',
      icon: Icons.account_balance_wallet,
      isAchieved: (duration, moneySaved) => moneySaved >= 100,
    ),
    Achievement(
      id: 'money_250',
      title: 'Serious Saver!',
      description: 'Saved \$250!',
      icon: Icons.savings,
      isAchieved: (duration, moneySaved) => moneySaved >= 250,
    ),
    Achievement(
      id: 'money_500',
      title: 'Half a Grand!',
      description: 'Saved \$500!',
      icon: Icons.currency_exchange,
      isAchieved: (duration, moneySaved) => moneySaved >= 500,
    ),
    Achievement(
      id: 'day_1',
      title: 'First Day Done!',
      description: 'Abstained for 1 day!',
      icon: Icons.check_circle,
      isAchieved: (duration, moneySaved) => duration.inDays >= 1,
    ),
    Achievement(
      id: 'day_3',
      title: 'Three Days Strong!',
      description: 'Abstained for 3 days!',
      icon: Icons.calendar_today,
      isAchieved: (duration, moneySaved) => duration.inDays >= 3,
    ),
    Achievement(
      id: 'day_7',
      title: 'One Week Warrior!',
      description: 'Abstained for 7 days!',
      icon: Icons.calendar_view_week,
      isAchieved: (duration, moneySaved) => duration.inDays >= 7,
    ),
    Achievement(
      id: 'day_14',
      title: 'Two Weeks of Freedom!',
      description: 'Abstained for 14 days!',
      icon: Icons.calendar_month,
      isAchieved: (duration, moneySaved) => duration.inDays >= 14,
    ),
    Achievement(
      id: 'day_30',
      title: 'One Month Milestone!',
      description: 'Abstained for 30 days!',
      icon: Icons.event,
      isAchieved: (duration, moneySaved) => duration.inDays >= 30,
    ),
    Achievement(
      id: 'day_60',
      title: 'Two Months Momentum!',
      description: 'Abstained for 60 days!',
      icon: Icons.date_range,
      isAchieved: (duration, moneySaved) => duration.inDays >= 60,
    ),
    Achievement(
      id: 'day_90',
      title: 'Three Months Triumph!',
      description: 'Abstained for 90 days!',
      icon: Icons.event_note,
      isAchieved: (duration, moneySaved) => duration.inDays >= 90,
    ),
    Achievement(
      id: 'hour_24',
      title: '24 Hour Power!',
      description: 'Abstained for 24 hours!',
      icon: Icons.access_time,
      isAchieved: (duration, moneySaved) => duration.inHours >= 24,
    ),
    Achievement(
      id: 'hour_72',
      title: '72 Hours Clean!',
      description: 'Abstained for 72 hours!',
      icon: Icons.timer,
      isAchieved: (duration, moneySaved) => duration.inHours >= 72,
    ),
    Achievement(
      id: 'hour_168',
      title: 'A Week of Hours!',
      description: 'Abstained for 168 hours!',
      icon: Icons.watch_later,
      isAchieved: (duration, moneySaved) => duration.inHours >= 168,
    ),
    Achievement(
      id: 'money_1000',
      title: 'Grand Master Saver!',
      description: 'Saved \$1000!',
      icon: Icons.attach_money_outlined,
      isAchieved: (duration, moneySaved) => moneySaved >= 1000,
    ),
    Achievement(
      id: 'day_180',
      title: 'Half a Year Hero!',
      description: 'Abstained for 180 days!',
      icon: Icons.calendar_month_outlined,
      isAchieved: (duration, moneySaved) => duration.inDays >= 180,
    ),
    Achievement(
      id: 'day_365',
      title: 'One Year Victory!',
      description: 'Abstained for 365 days!',
      icon: Icons.celebration,
      isAchieved: (duration, moneySaved) => duration.inDays >= 365,
    ),
    Achievement(
      id: 'consistent_quit',
      title: 'Consistent Effort!',
      description: 'Maintain your streak for a few weeks without resetting.',
      icon: Icons.trending_up,
      isAchieved:
          (duration, moneySaved) => duration.inDays >= 21, // Example condition
    ),
    Achievement(
      id: 'healthy_mind',
      title: 'Clear Mind!',
      description: 'Experience clearer thinking and focus.',
      icon: Icons.lightbulb_outline,
      isAchieved:
          (duration, moneySaved) => duration.inDays >= 10, // Example condition
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _quitTime == null
        ? Center(child: CircularProgressIndicator())
        : StreamBuilder<int>(
          stream: Stream.periodic(
            Duration(seconds: 1),
            (i) => i,
          ), // Update every second
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            Duration abstainedDuration = DateTime.now().difference(_quitTime!);
            double moneySaved = _calculateMoneySaved(abstainedDuration);

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _allAchievements.length,
              itemBuilder: (context, index) {
                final achievement = _allAchievements[index];
                bool isAchievedNow = achievement.isAchieved(
                  abstainedDuration,
                  moneySaved,
                );

                // Update status in shared preferences if it just got achieved
                if (isAchievedNow &&
                    !(_achievedStatus[achievement.id] ?? false)) {
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setBool('achieved_${achievement.id}', true);
                    setState(() {
                      _achievedStatus[achievement.id] = true;
                    });
                  });
                }

                final bool achieved = _achievedStatus[achievement.id] ?? false;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: achieved ? Colors.blue.shade50 : Colors.grey.shade50,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(15),
                    leading: Icon(
                      achievement.icon,
                      size: 40,
                      color: achieved ? Colors.blue : Colors.grey.shade500,
                    ),
                    title: Text(
                      achievement.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: achieved ? Colors.blue : Colors.grey.shade700,
                      ),
                    ),
                    subtitle: Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: achieved ? Colors.blue : Colors.grey.shade600,
                      ),
                    ),
                    trailing:
                        achieved
                            ? Icon(
                              Icons.check_circle_outline,
                              color: Colors.blue,
                              size: 30,
                            )
                            : Icon(
                              Icons.lock,
                              color: Colors.grey.shade500,
                              size: 30,
                            ),
                  ),
                );
              },
            );
          },
        );
  }
}
