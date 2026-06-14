import 'package:flutter/material.dart';
import 'package:orthodox_church_ramallah/screens/advertisements_screen.dart';
import 'package:orthodox_church_ramallah/screens/calendar_screen.dart';
import 'package:orthodox_church_ramallah/screens/sundays_paper_screen.dart';
import '../services/notification_service.dart';
import 'location_screen.dart';
import 'schedule_screen.dart';
import 'bible_screen.dart';
import 'chants_screen.dart';
import 'live_screen.dart';
import 'prayers_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final Map<int, Widget> _screenCache = {};

  Widget _getScreen(int index) {
    if (!_screenCache.containsKey(index)) {
      switch (index) {
        case 0:
          _screenCache[0] = MainDashboardScreen();
          break;
        case 1:
          _screenCache[1] = const LivePlayerPage();
          break;
        case 2:
          _screenCache[2] = const BibleScreen();
          break;
        case 3:
          _screenCache[3] = const CalendarScreen();
          break;
        case 4:
          _screenCache[4] = const LocationScreen();
          break;
        default:
          _screenCache[0] = MainDashboardScreen();
      }
    }
    return _screenCache[index]!;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: _getScreen(_currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(
              icon: Icon(Icons.videocam),
              label: 'البث المباشر',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'الكتاب المقدس',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'التقويم',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'عن الكنيسة',
            ),
          ],
        ),
      ),
    );
  }
}

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verse = NotificationService.getTodayVerse();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 10),
                    blurRadius: 25,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    height: 76,
                    width: 76,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'كنيسة تجلي الرب للروم الارثوذكس - رام الله',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 10),
                    blurRadius: 25,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.menu_book,
                          size: 26,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'آية اليوم',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    verse,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuTile(
              context,
              icon: Icons.schedule,
              label: 'مواعيد الصلوات',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScheduleScreen()),
              ),
            ),
            const SizedBox(height: 14),
            _buildMenuTile(
              context,
              icon: Icons.music_note,
              label: 'التراتيل , مقاطع فيديو و كتب روحية',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChantsScreen()),
              ),
            ),
            const SizedBox(height: 14),
            _buildMenuTile(
              context,
              icon: Icons.book,
              label: 'كتب الصلوات',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrayersScreen()),
              ),
            ),
            const SizedBox(height: 14),
            _buildMenuTile(
              context,
              icon: Icons.picture_as_pdf,
              label: 'نشرة يوم الأحد',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SundaysPaperScreen(),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _buildMenuTile(
              context,
              icon: Icons.ondemand_video,
              label: 'الاعلانات',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvertisementsScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(14),
                child: Icon(icon, size: 28, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
