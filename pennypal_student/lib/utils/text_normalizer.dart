class TextNormalizer {
  static const Map<String, String> _accentGroups = {
    'a': 'àáạảãâầấậẩẫăằắặẳẵ',
    'e': 'èéẹẻẽêềếệểễ',
    'i': 'ìíịỉĩ',
    'o': 'òóọỏõôồốộổỗơờớợởỡ',
    'u': 'ùúụủũưừứựửữ',
    'y': 'ỳýỵỷỹ',
    'd': 'đ',
  };

  static final Map<String, String> _plainByAccented = _buildLookup();

  static Map<String, String> _buildLookup() {
    final Map<String, String> lookup = {};
    _accentGroups.forEach((plain, accented) {
      for (final String letter in accented.split('')) {
        lookup[letter] = plain;
      }
    });
    return lookup;
  }

  static String normalize(String text) {
    final StringBuffer buffer = StringBuffer();
    for (final String letter in text.toLowerCase().split('')) {
      buffer.write(_plainByAccented[letter] ?? letter);
    }
    return buffer.toString();
  }
}
