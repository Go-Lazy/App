/// Returns true if [candidate] (e.g. "1.2.0") is a newer version than
/// [current] (e.g. "1.1.4"), comparing dot-separated numeric parts.
/// Missing trailing parts are treated as zero, so "1.2" > "1.1.9" is false
/// and "1.2" > "1.1" is true.
bool isNewerVersion(String candidate, String current) {
  final candidateParts = _numericParts(candidate);
  final currentParts = _numericParts(current);
  final length = candidateParts.length > currentParts.length
      ? candidateParts.length
      : currentParts.length;

  for (var i = 0; i < length; i++) {
    final candidatePart = i < candidateParts.length ? candidateParts[i] : 0;
    final currentPart = i < currentParts.length ? currentParts[i] : 0;
    if (candidatePart != currentPart) return candidatePart > currentPart;
  }
  return false;
}

List<int> _numericParts(String version) {
  return version
      .trim()
      .split('.')
      .map((part) => int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
      .toList();
}
