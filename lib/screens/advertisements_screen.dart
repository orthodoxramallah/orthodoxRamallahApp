import 'package:flutter/material.dart';
import '../services/schedule_services.dart';

class AdvertisementsScreen extends StatelessWidget {
  const AdvertisementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الإعلانات'), elevation: 2),
        body: FutureBuilder<List<String>>(
          future: ScheduleService.getAdvertisements(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'حدث خطأ أثناء تحميل الإعلانات. حاول مرة أخرى لاحقاً.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final ads = snapshot.data ?? [];
            if (ads.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد إعلانات متاحة حالياً.',
                  style: theme.textTheme.bodyLarge,
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ads.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      ads[index],
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
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
}
