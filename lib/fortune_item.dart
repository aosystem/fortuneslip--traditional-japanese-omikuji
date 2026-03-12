class FortuneItem {
  const FortuneItem({required this.rawName, required this.ratio});

  final String rawName;
  final int ratio;

  String get display {
    final index = rawName.indexOf(':');
    if (index == -1) {
      return rawName.trim();
    }
    return rawName.substring(0, index).trim();
  }

  String get reading {
    final index = rawName.indexOf(':');
    if (index == -1) {
      return rawName.trim();
    }
    return rawName.substring(index + 1).trim();
  }

  FortuneItem copyWith({String? rawName, int? ratio}) {
    return FortuneItem(
      rawName: rawName ?? this.rawName,
      ratio: ratio ?? this.ratio,
    );
  }
}
