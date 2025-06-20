import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:banksample/screens/achievements_screen.dart';
import 'package:banksample/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DateTime? _quitTime;
  double _pricePerSession = 0.0;
  int _timesPerDay = 0;
  Duration _abstainedDuration = Duration.zero;
  final NotificationService _notificationService = NotificationService();
  Timer? _timer;
  bool _isLoading = true;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _loadQuitData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_quitTime != null) {
        setState(() {
          _abstainedDuration = DateTime.now().difference(_quitTime!);
        });
      }
    });
  }

  Future<void> _loadQuitData() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp =
        prefs.getInt('quit_timestamp') ?? DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _quitTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      _pricePerSession =
          double.tryParse(prefs.getString('price_per_session') ?? '0.0') ?? 0.0;
      _timesPerDay = int.tryParse(prefs.getString('times_per_day') ?? '0') ?? 0;
      _isLoading = false;
      _abstainedDuration = DateTime.now().difference(_quitTime!);
    });
  }

  String _formatDuration(Duration d) {
    return '${d.inDays}d ${d.inHours.remainder(24)}h '
        '${d.inMinutes.remainder(60)}m ${d.inSeconds.remainder(60)}s';
  }

  double _calculateMoneySaved() {
    if (_pricePerSession == 0 || _timesPerDay == 0) return 0;
    final costPerDay = _pricePerSession * _timesPerDay;
    final costPerSecond = costPerDay / 86400;
    return _abstainedDuration.inSeconds * costPerSecond;
  }

  Map<String, bool> _getHealthMilestones() {
    return {
      '20 minutes': _abstainedDuration.inMinutes >= 20,
      '8 hours': _abstainedDuration.inHours >= 8,
      '24 hours': _abstainedDuration.inHours >= 24,
      '48 hours': _abstainedDuration.inHours >= 48,
      '72 hours': _abstainedDuration.inHours >= 72,
      '2 weeks': _abstainedDuration.inDays >= 14,
      '1 month': _abstainedDuration.inDays >= 30,
      '3 months': _abstainedDuration.inDays >= 90,
      '1 year': _abstainedDuration.inDays >= 365,
    };
  }

  void _checkAchievements() {
    _notificationService.checkAndNotifyAchievements(
      _abstainedDuration,
      _calculateMoneySaved(),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty && !_isLoading) {
      _pages.addAll([
        _buildHomeContent(),
        _buildHealthContent(),
        AchievementsScreen(),
        _buildProfileContent(),
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quit Weed',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions:
            _selectedIndex == 0
                ? [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadQuitData,
                  ),
                ]
                : null,
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: Colors.blue.shade700),
              )
              : _selectedIndex == 0
              ? _buildHomeContent()
              : _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeContent() {
    _checkAchievements();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildStatsCard(
            title: 'TIME ABSTAINED',
            value: _formatDuration(_abstainedDuration),
            icon: Icons.access_time,
          ),
          const SizedBox(height: 20),
          _buildStatsCard(
            title: 'MONEY SAVED',
            value: '\$${_calculateMoneySaved().toStringAsFixed(2)}',
            icon: Icons.attach_money,
          ),
          const SizedBox(height: 32),
          _buildMotivationSection(),
          const SizedBox(height: 24),
          _buildHealthPreview(),
          const SizedBox(height: 24),
          _buildStartDateInfo(),
        ],
      ),
    );
  }

  Widget _buildHealthContent() {
    final milestones = _getHealthMilestones();
    final details = {
      '20 minutes': 'Blood pressure and pulse return to normal',
      '8 hours': 'Carbon monoxide level drops',
      '24 hours': 'Heart attack risk decreases',
      '48 hours': 'Nerve endings regrow',
      '72 hours': 'Breathing improves',
      '2 weeks': 'Circulation boosts',
      '1 month': 'Lung function increases',
      '3 months': 'Coughing reduces',
      '1 year': 'Heart disease risk halves',
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Milestones',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your body recovers as you stay committed',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children:
                  milestones.entries.map((e) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color:
                          e.value ? Colors.blue.shade50 : Colors.grey.shade50,
                      child: ListTile(
                        leading: Icon(
                          e.value ? Icons.check_circle : Icons.access_time,
                          color: e.value ? Colors.blue : Colors.grey.shade500,
                        ),
                        title: Text(
                          e.key,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                e.value ? Colors.blue.shade800 : Colors.black,
                          ),
                        ),
                        subtitle: Text(details[e.key]!),
                        trailing:
                            e.value
                                ? const Icon(Icons.verified, color: Colors.blue)
                                : Text(
                                  'Not yet',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _buildAppInfoHeader()),
          const SizedBox(height: 24),
          _buildInfoSection(
            title: 'About Quit Weed',
            content:
                'Quit Weed helps you track your progress toward a healthier lifestyle. Our app provides motivation, health insights, and achievement tracking to support your journey.',
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            title: 'Privacy Policy',
            content:
                'All data is stored locally and never shared without explicit consent.',
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            title: 'Terms of Use',
            content:
                'Use for personal purposes only. Information is not medical advice. Consult professionals.',
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            title: 'Contact Us',
            content: 'support@quitweed.app\n+1 (800) 123-4567',
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Overview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Every moment brings you closer to your goal',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Colors.blue.shade800,
                  ),
                ),
                Icon(icon, color: Colors.blue.shade700, size: 24),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events, size: 40, color: Colors.blue.shade700),
          const SizedBox(height: 16),
          Text(
            'You\'re making great progress!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your commitment today is building a healthier tomorrow. Keep up the amazing work!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.blue.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthPreview() {
    final milestones = _getHealthMilestones();
    final achieved = milestones.values.where((v) => v).length;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 1),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Health Benefits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                Icon(Icons.arrow_forward, color: Colors.blue.shade600),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: achieved / milestones.length,
              backgroundColor: Colors.blue.shade100,
            ),
            const SizedBox(height: 8),
            Text(
              '$achieved/${milestones.length} milestones achieved',
              style: TextStyle(color: Colors.blue.shade700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  milestones.entries.map((e) {
                    return Chip(
                      backgroundColor:
                          e.value ? Colors.blue.shade100 : Colors.grey.shade50,
                      label: Text(e.key),
                      avatar: Icon(
                        e.value ? Icons.check_circle : Icons.access_time,
                        color: e.value ? Colors.blue : Colors.grey,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartDateInfo() {
    return Text(
      'Journey started: ${DateFormat('MMM dd, yyyy – hh:mm a').format(_quitTime!)}',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
    );
  }

  Widget _buildAppInfoHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.self_improvement, size: 50, color: Colors.blue),
        ),
        const SizedBox(height: 16),
        Text(
          'Quit Weed',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your companion for a healthier lifestyle',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildInfoSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          activeIcon: Icon(Icons.favorite),
          label: 'Health',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star_outline),
          activeIcon: Icon(Icons.star),
          label: 'Achievements',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.blue.shade800,
      unselectedItemColor: Colors.grey.shade600,
      onTap: _onItemTapped,
      backgroundColor: Colors.white,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
    );
  }
}
