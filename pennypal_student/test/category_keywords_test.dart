import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/utils/category_keywords.dart';
import 'package:pennypal_student/utils/constants.dart';

void main() {
  group('CategoryKeywords.findCategory', () {
    test('Vietnamese text with accents is matched', () {
      expect(CategoryKeywords.findCategory('Cà phê với bạn'), CategoryKeys.food);
      expect(CategoryKeywords.findCategory('Tiền điện tháng 9'), CategoryKeys.bills);
    });

    test('text without accents is matched', () {
      expect(CategoryKeywords.findCategory('ca phe voi ban'), CategoryKeys.food);
    });

    test('English text is matched', () {
      expect(CategoryKeywords.findCategory('Coffee with friends'), CategoryKeys.food);
      expect(CategoryKeywords.findCategory('Milk tea'), CategoryKeys.food);
      expect(CategoryKeywords.findCategory('Grab to school'), CategoryKeys.transport);
      expect(CategoryKeywords.findCategory('New textbook'), CategoryKeys.education);
      expect(CategoryKeywords.findCategory('Netflix monthly'), CategoryKeys.entertainment);
      expect(CategoryKeywords.findCategory('Wifi for the room'), CategoryKeys.bills);
    });

    test('mixed English and Vietnamese text is matched', () {
      expect(CategoryKeywords.findCategory('Coffee với bạn'), CategoryKeys.food);
      expect(CategoryKeywords.findCategory('Mua shoes mới'), CategoryKeys.shopping);
    });

    test('only whole words are matched', () {
      expect(CategoryKeywords.findCategory('bàn học'), CategoryKeys.education);
      expect(CategoryKeywords.findCategory('banh'), isNull);
    });

    test('the first category in the list wins when two match', () {
      expect(CategoryKeywords.findCategory('mua cơm'), CategoryKeys.food);
    });

    test('ignored keywords are skipped for the receipt scan', () {
      expect(CategoryKeywords.findCategory('Hóa đơn bán hàng'), CategoryKeys.bills);
      expect(CategoryKeywords.findCategory('Hóa đơn bán hàng', ignoredKeywords: {'hoa don'}), isNull);
    });

    test('empty or unknown text returns null', () {
      expect(CategoryKeywords.findCategory(''), isNull);
      expect(CategoryKeywords.findCategory('   '), isNull);
      expect(CategoryKeywords.findCategory('abc xyz'), isNull);
    });
  });
}
