import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/connectivity_service.dart';
import '../theme/app_colors.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final isOnline = await ConnectivityService().isOnline;
    if (!mounted) return;
    setState(() {
      _isOnline = isOnline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('عن الكنيسة'), elevation: 2),
        body: RefreshIndicator(
          onRefresh: _checkConnectivity,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'كنيسة تجلي الرب للروم الأرثوذكس',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          SizedBox(height: 16),
                          Text(
                            'شارع دير الروم، رام الله التحتا، رام الله , فلسطين',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'الهاتف: 6618 295 02',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'البريد الإلكتروني: info@orthodox-ramallah.ps',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _isOnline
                          ? _buildOnlineMap(context)
                          : _buildOfflineMap(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isOnline ? _openMap : null,
                    icon: const Icon(Icons.map),
                    label: const Text('فتح الخريطة'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'تابعنا عبر الوسائط الاجتماعية',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildSocialLinkButton(
                    context,
                    icon: Icons.video_library,
                    label: 'يوتيوب',
                    url: 'https://youtube.com/@tajalli1850?si=SVpU5m7k4_Z62h5-',
                  ),
                  const SizedBox(height: 10),
                  _buildSocialLinkButton(
                    context,
                    icon: Icons.facebook,
                    label: 'فيسبوك',
                    url: 'https://www.facebook.com/110892873896014/',
                  ),
                  const SizedBox(height: 10),
                  _buildSocialLinkButton(
                    context,
                    icon: Icons.camera_alt,
                    label: 'انستجرام',
                    url:
                        'https://www.instagram.com/orthodox_ramallah?igsh=OHJ4ZmU2ZGsyNDY=',
                  ),
                  const SizedBox(height: 10),
                  _buildSocialLinkButton(
                    context,
                    icon: Icons.music_video,
                    label: 'تيك توك',
                    url: 'https://tiktok.com/@tajalli.ps?_t=8sOzPlQQeyf&_r=1',
                  ),
                  if (!_isOnline) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'الخدمة عبر الإنترنت غير متاحة حالياً. اسحب لتحديث الصفحة.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kDarkBlue),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineMap(BuildContext context) {
    return Container(
      height: 260,
      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.location_on, size: 48, color: kDarkBlue),
            SizedBox(height: 10),
            Text(
              'الموقع متاح',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              '31.9039157, 35.1967993',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineMap(BuildContext context) {
    return Container(
      height: 260,
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'لا يوجد اتصال بالإنترنت',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              'اسحب لتحديث أو تحقق من اتصالك.',
              style: TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinkButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String url,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        alignment: Alignment.centerRight,
        backgroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: () => _openUrl(url),
      icon: Icon(icon, size: 22),
      label: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }

  Future<void> _openUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر فتح الرابط.')));
      }
    }
  }

  Future<void> _openMap() async {
    const lat = 31.9039157;
    const lng = 35.1967993;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر فتح الخريطة.')));
      }
    }
  }
}
