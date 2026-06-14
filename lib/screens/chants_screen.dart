import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'chants_audio_screen.dart';
import 'chants_video_screen.dart';
import 'chants_books_screen.dart';


class ChantsScreen extends StatefulWidget {
  const ChantsScreen({super.key});

  @override
  State<ChantsScreen> createState() => _ChantsScreenState();
}

class ChantsData {
  final String title;
  final String description;
  final IconData icon;

  ChantsData({required this.title, required this.description, required this.icon});
}

class _ChantsScreenState extends State<ChantsScreen> {
  final List<ChantsData> chants = [
    ChantsData(title: 'التراتيل الصوتية', description: 'تسجيلات صوتية للتراتيل', icon: Icons.music_note),
    ChantsData(title: 'الفيديوهات', description: 'فيديوهات التراتيل والمحاضرات', icon: Icons.videocam),
    ChantsData(title: 'الكتب الإلكترونية', description: 'كتب روحية بصيغة PDF', icon: Icons.book),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تراتيل, محاضرات و كتب روحية'),
          elevation: 2,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: chants.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        switch (index) {
                          case 0:
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ChantsAudioScreen()),
                            );
                            break;
                          case 1:
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ChantsVideoScreen()),
                            );
                            break;
                          case 2:
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ChantsBooksScreen()),
                            );
                            break;
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: kDarkBlue, borderRadius: BorderRadius.circular(10)),
                              child: Icon(chants[index].icon, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(chants[index].title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.right),
                                  const SizedBox(height: 8),
                                  Text(
                                    chants[index].description,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.arrow_back_ios, size: 18, color: kDarkBlue),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
