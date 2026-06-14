class SaintDayInfo {
  final String title;
  final String description;
  final String note;
  final List<String> imagepath;
  final bool isFeast;
  final bool isFast;
  final String? prayer;

  const SaintDayInfo({
    required this.title,
    this.description = '',
    this.note = '',
    this.imagepath = const [],
    this.isFeast = false,
    this.isFast = false,
    this.prayer,
  });

  SaintDayInfo copyWith({
    String? title,
    String? description,
    String? note,
    List<String>? imagepath,
    bool? isFeast,
    bool? isFast,
    String? prayer,
  }) {
    return SaintDayInfo(
      title: title ?? this.title,
      description: description ?? this.description,
      note: note ?? this.note,
      imagepath: imagepath ?? this.imagepath,
      isFeast: isFeast ?? this.isFeast,
      isFast: isFast ?? this.isFast,
      prayer: prayer ?? this.prayer,
    );
  }
}