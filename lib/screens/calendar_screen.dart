import 'package:flutter/material.dart';
import 'package:orthodox_church_ramallah/services/saint_day_info.dart';
import 'package:orthodox_church_ramallah/services/saints_helper.dart';
import '../theme/app_colors.dart';

class _DayInfo {
  final int gregorianDay;
  final DateTime gregorianDate;
  final SaintDayInfo? info;

  const _DayInfo({
    required this.gregorianDay,
    required this.gregorianDate,
    required this.info,
  });
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late int _year;
  late int _selectedMonth;
  late PageController _pageController;
  final Map<String, List<_DayInfo>> _cachedMonthsData = {};
  final DateTime _today = DateTime.now();

  static const Color kFeastColor = kGoldPrimary;
  static const Color kFastColor = Color(0xFF1565C0);

  static const List<String> _monthNamesAr = [
    'كانون 2', 'شباط', 'آذار', 'نيسان', 'أيار', 'حزيران',
    'تموز', 'آب', 'أيلول', 'تشرين 1', 'تشرين 2', 'كانون 1',
  ];

  @override
  void initState() {
    super.initState();
    _year = _today.year;
    _selectedMonth = _today.month;
    _pageController = PageController(initialPage: _selectedMonth - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<_DayInfo> _generateMonthData(int year, int month) {
    final cacheKey = '$year-$month';
    if (_cachedMonthsData.containsKey(cacheKey)) {
      return _cachedMonthsData[cacheKey]!;
    }

    final gregorianFirst = DateTime(year, month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstWeekday = gregorianFirst.weekday % 7;

    final days = List<_DayInfo>.generate(firstWeekday + daysInMonth, (index) {
      if (index < firstWeekday) {
        return _DayInfo(
          gregorianDay: 0,
          gregorianDate: DateTime(year, month, 1),
          info: null,
        );
      }
      final day = index - firstWeekday + 1;
      final gregorianDate = DateTime(year, month, day);
      return _DayInfo(
        gregorianDay: day,
        gregorianDate: gregorianDate,
        info: SaintsHelper.infoForDate(gregorianDate),
      );
    });

    _cachedMonthsData[cacheKey] = days;
    return days;
  }

  void _goToToday() {
    setState(() {
      _year = _today.year;
      _selectedMonth = _today.month;
      _cachedMonthsData.clear();
    });
    _pageController.jumpToPage(_today.month - 1);
  }

  void _showYearPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _YearPickerSheet(
        selectedYear: _year,
        onYearSelected: (year) {
          Navigator.pop(context);
          setState(() {
            _year = year;
            _cachedMonthsData.clear();
          });
        },
      ),
    );
  }

  void _changeMonth(int delta) {
    final newMonth = _selectedMonth + delta;
    if (newMonth < 1 || newMonth > 12) return;
    setState(() => _selectedMonth = newMonth);
    _pageController.jumpToPage(newMonth - 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التقويم الكنسي'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.today),
              tooltip: 'اليوم',
              onPressed: _goToToday,
            ),
          ],
        ),
        body: Column(
          children: [
            // Year and Month selector
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Year button
                  Expanded(
                    child: InkWell(
                      onTap: _showYearPicker,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, size: 18, color: theme.colorScheme.onPrimaryContainer),
                            const SizedBox(width: 8),
                            Text('$_year', style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down, color: theme.colorScheme.onPrimaryContainer),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Month selector
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _selectedMonth > 1 ? () => _changeMonth(-1) : null,
                            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                            color: theme.colorScheme.primary,
                            disabledColor: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                            splashRadius: 22,
                          ),
                          Text(_monthNamesAr[_selectedMonth - 1],
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: _selectedMonth < 12 ? () => _changeMonth(1) : null,
                            icon: const Icon(Icons.arrow_forward_ios, size: 18),
                            color: theme.colorScheme.primary,
                            disabledColor: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                            splashRadius: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Legend
            const _CalendarLegend(feastColor: kFeastColor, fastColor: kFastColor),

            // Week header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _WeekHeaderRow(primaryColor: theme.primaryColor),
            ),
            const SizedBox(height: 8),

            // Calendar pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: 12,
                onPageChanged: (index) => setState(() => _selectedMonth = index + 1),
                itemBuilder: (context, monthIndex) {
                  final daysData = _generateMonthData(_year, monthIndex + 1);
                  return _MonthGrid(
                    daysData: daysData,
                    today: _today,
                    currentYear: _year,
                    currentMonth: monthIndex + 1,
                    feastColor: kFeastColor,
                    fastColor: kFastColor,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Year Picker ───

class _YearPickerSheet extends StatelessWidget {
  final int selectedYear;
  final ValueChanged<int> onYearSelected;

  const _YearPickerSheet({required this.selectedYear, required this.onYearSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentYear = DateTime.now().year;
    final years = List.generate(21, (i) => currentYear - 10 + i);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('اختر السنة', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          SizedBox(
            height: 280,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, childAspectRatio: 2.2, mainAxisSpacing: 10, crossAxisSpacing: 10),
              itemCount: years.length,
              itemBuilder: (context, index) {
                final year = years[index];
                final isSelected = year == selectedYear;
                final isCurrent = year == currentYear;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary
                        : isCurrent ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.08)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => onYearSelected(year),
                      child: Center(
                        child: Text('$year', style: theme.textTheme.bodyLarge?.copyWith(
                          color: isSelected ? theme.colorScheme.onPrimary
                              : isCurrent ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          fontWeight: isSelected || isCurrent ? FontWeight.bold : FontWeight.w500)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Legend ───

class _CalendarLegend extends StatelessWidget {
  final Color feastColor;
  final Color fastColor;

  const _CalendarLegend({required this.feastColor, required this.fastColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _legendItem(feastColor.withAlpha(153), 'عيد', Icons.star),
          _legendItem(fastColor.withAlpha(102), 'صوم', Icons.restaurant),
          _legendItem(Colors.deepPurple.withAlpha(102), 'عيد + صوم', Icons.auto_awesome),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.primary, width: 2),
                ),
              ),
              const SizedBox(width: 6),
              Text('اليوم', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, IconData icon) {
    return Builder(builder: (context) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      );
    });
  }
}

// ─── Week Header ───

class _WeekHeaderRow extends StatelessWidget {
  final Color primaryColor;
  const _WeekHeaderRow({required this.primaryColor});

  static const _weekDays = ['أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: primaryColor.withAlpha(26), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          for (final day in _weekDays)
            Expanded(child: Center(
              child: Text(day, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: primaryColor)))),
        ],
      ),
    );
  }
}

// ─── Month Grid ───

class _MonthGrid extends StatelessWidget {
  final List<_DayInfo> daysData;
  final DateTime today;
  final int currentYear;
  final int currentMonth;
  final Color feastColor;
  final Color fastColor;

  const _MonthGrid({
    required this.daysData, required this.today, required this.currentYear,
    required this.currentMonth, required this.feastColor, required this.fastColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 0.85),
        itemCount: daysData.length,
        itemBuilder: (context, index) {
          final dayInfo = daysData[index];
          if (dayInfo.gregorianDay == 0) return const SizedBox();

          final isToday = today.year == currentYear &&
              today.month == currentMonth &&
              today.day == dayInfo.gregorianDay;

          return _CalendarDayCell(
            dayInfo: dayInfo, isToday: isToday,
            feastColor: feastColor, fastColor: fastColor,
          );
        },
      ),
    );
  }
}

// ─── Day Cell ───

class _CalendarDayCell extends StatelessWidget {
  final _DayInfo dayInfo;
  final bool isToday;
  final Color feastColor;
  final Color fastColor;

  const _CalendarDayCell({
    required this.dayInfo, required this.feastColor,
    required this.fastColor, this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = dayInfo.info;
    final isFeast = info?.isFeast ?? false;
    final isFast = info?.isFast ?? false;

    Color? backgroundColor;
    Color? borderColor;
    Color textColor = theme.colorScheme.onSurface;

    if (isFeast && isFast) {
      backgroundColor = Colors.deepPurple.withValues(alpha: 0.15);
      textColor = Colors.deepPurple.shade900;
    } else if (isFeast) {
      backgroundColor = feastColor.withValues(alpha: 0.18);
      textColor = Colors.brown.shade900;
    } else if (isFast) {
      backgroundColor = fastColor.withValues(alpha: 0.16);
      textColor = Colors.blue.shade900;
    }

    if (isToday) {
      borderColor = theme.colorScheme.primary;
      backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.14);
      textColor = theme.colorScheme.primary;
    }

    return GestureDetector(
      onTap: () => _showDayDetails(context),
      child: RepaintBoundary(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: borderColor != null ? Border.all(color: borderColor, width: 2.5) : null,
            boxShadow: isToday
                ? [BoxShadow(color: theme.primaryColor.withAlpha(77), blurRadius: 6, offset: const Offset(0, 2))]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isFeast || isFast)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isFeast) Container(width: 5, height: 5, margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(color: feastColor, shape: BoxShape.circle)),
                    if (isFast) Container(width: 5, height: 5, margin: const EdgeInsets.only(left: 2),
                      decoration: BoxDecoration(color: fastColor, shape: BoxShape.circle)),
                  ],
                ),
              const SizedBox(height: 2),
              Text('${dayInfo.gregorianDay}',
                style: TextStyle(fontSize: 14, fontWeight: isToday ? FontWeight.bold : FontWeight.w600, color: textColor)),
            ],
          ),
        ),
      ),
    );
  }

  void _showDayDetails(BuildContext context) {
    final info = dayInfo.info ??
        const SaintDayInfo(title: 'لا توجد معلومات', description: 'لا توجد معلومات متاحة لهذا اليوم.');
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7, minChildSize: 0.3, maxChildSize: 0.95, expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),

                // Title
                Center(
                  child: Text(info.title,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                ),

                // Badges
                if (info.isFeast || info.isFast) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: Wrap(
                      spacing: 8, runSpacing: 6, alignment: WrapAlignment.center,
                      children: [
                        if (info.isFeast) _badge(Icons.star, 'عيد', feastColor),
                        if (info.isFast) _badge(Icons.restaurant, 'صوم', fastColor),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Date card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withAlpha(13),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.primaryColor.withAlpha(38)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month, size: 20, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        '${dayInfo.gregorianDate.day}/${dayInfo.gregorianDate.month}/${dayInfo.gregorianDate.year}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                // Note
                if (info.note.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('ملاحظات طقسية', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withAlpha(13),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.primaryColor.withAlpha(51)),
                    ),
                    child: Text(info.note, style: const TextStyle(fontSize: 14, height: 1.6)),
                  ),
                ],

                // Description
                if (info.description.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('التفاصيل', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(info.description, style: const TextStyle(fontSize: 15, height: 1.6)),
                  ),
                ],

                // Prayer
                if (info.prayer != null && info.prayer!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('طروبارية', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withAlpha(13),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.primaryColor.withAlpha(51)),
                    ),
                    child: Text(info.prayer!,
                      style: TextStyle(fontSize: 15, height: 1.6, color: theme.primaryColor.withAlpha(230))),
                  ),
                ],
                // Images
                if (info.imagepath.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 240,
                    child: PageView.builder(
                      itemCount: info.imagepath.length,
                      controller: PageController(viewportFraction: 0.85),
                      itemBuilder: (context, index) {
                        final path = info.imagepath[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              path,
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => Container(
                                height: 220,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withAlpha(26),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(Icons.person, size: 80, color: theme.primaryColor),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (info.imagepath.length > 1)
                    Center(
                      child: Text('اسحب لرؤية المزيد',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}