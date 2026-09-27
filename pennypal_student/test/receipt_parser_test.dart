import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/utils/category_keywords.dart';
import 'package:pennypal_student/utils/constants.dart';
import 'package:pennypal_student/utils/receipt_parser.dart';
import 'package:pennypal_student/utils/receipt_text_builder.dart';
import 'package:pennypal_student/utils/text_normalizer.dart';

void main() {
  final DateTime now = DateTime(2026, 9, 25, 10);

  group('TextNormalizer', () {
    test('removes Vietnamese accents and lowercases', () {
      expect(TextNormalizer.normalize('Tổng Cộng'), 'tong cong');
      expect(TextNormalizer.normalize('Đi lại, Thanh Toán'), 'di lai, thanh toan');
      expect(TextNormalizer.normalize(''), '');
    });
  });

  group('CategoryKeywords', () {
    test('finds a category by whole-word keyword', () {
      expect(CategoryKeywords.findCategory('Bún bò Huế Cô Ba'), CategoryKeys.food);
      expect(CategoryKeywords.findCategory('GRAB bike'), CategoryKeys.transport);
      expect(CategoryKeywords.findCategory('Hoc phi HK1'), CategoryKeys.education);
      expect(CategoryKeywords.findCategory('Tiền điện tháng 9'), CategoryKeys.bills);
    });

    test('does not match inside another word and returns null when nothing matches', () {
      expect(CategoryKeywords.findCategory('Banh mi'), isNull);
      expect(CategoryKeywords.findCategory('XYZ store'), isNull);
    });

    test('ignored keywords are skipped', () {
      expect(CategoryKeywords.findCategory('HOA DON BAN LE'), CategoryKeys.bills);
      expect(CategoryKeywords.findCategory('HOA DON BAN LE', ignoredKeywords: {'hoa don'}), isNull);
    });
  });

  group('ReceiptParser.parseNumber (BR-92, BR-93)', () {
    test('reads the common money formats', () {
      expect(ReceiptParser.parseNumber('1.234.000'), 1234000);
      expect(ReceiptParser.parseNumber('1,234,000'), 1234000);
      expect(ReceiptParser.parseNumber('1234000'), 1234000);
      expect(ReceiptParser.parseNumber('125.000.'), 125000);
      expect(ReceiptParser.parseNumber('12.50'), 12.5);
      expect(ReceiptParser.parseNumber('1.234,50'), 1234.5);
    });

    test('skips phone numbers and long codes', () {
      expect(ReceiptParser.parseNumber('0901234567'), isNull);
      expect(ReceiptParser.parseNumber('12345678901'), isNull);
      expect(ReceiptParser.parseNumber('1.2345'), isNull);
    });
  });

  group('ReceiptParser.parse', () {
    test('uses the number on the total line, not the largest number', () {
      const String text = 'BUN BO HUE CO BA\n'
          '22/09/2026 12:05\n'
          'Bun bo dac biet   2   120.000\n'
          'Tra da   1   5.000\n'
          'Tong cong   125.000\n'
          'Tien khach dua   200.000\n'
          'Hotline 0901234567';
      final result = ReceiptParser.parse(text, now: now);

      expect(result.hasText, isTrue);
      expect(result.amount, 125000);
      expect(result.description, 'BUN BO HUE CO BA');
      expect(result.date, DateTime(2026, 9, 22));
      expect(result.isDateFromReceipt, isTrue);
      expect(result.categoryId, CategoryKeys.food);
    });

    test('a quantity line that starts with "Tong" is not the total', () {
      const String text = 'Co.op Food\n'
          'Tổng số lượng hàng   1.000\n'
          'Tổng cộng   10,200.00\n'
          'SL   2';
      final result = ReceiptParser.parse(text, now: now);

      expect(result.amount, 10200);
    });

    test('only a quantity line falls back to the largest number', () {
      const String text = 'Co.op Food\nTổng số lượng hàng   1.000\n10,200.00';
      final result = ReceiptParser.parse(text, now: now);

      expect(result.amount, 10200);
    });

    test('blurry Co.op receipt: the amount printed on several lines wins', () {
      const String text = 'Salgan Co.op\n'
          'PHIẾU TINH TIẾN\n'
          'NV 588s4 TN3   05/09/2026 18 24\n'
          'Ten Số Lượng   Đơn Glá\n'
          '833438a 183153\n'
          'VAT 10\n'
          '10 200 00\n'
          '10,200 00\n'
          'Táng t\n'
          '10,200.00\n'
          'Tống số rng hang\n'
          'TEKco t   1000\n'
          '927 27\n'
          'TICN MAT\n'
          '10.200 00';
      final result = ReceiptParser.parse(text, now: now);

      expect(result.amount, 10200);
    });

    test('a repeated quantity without separators is not taken as the amount', () {
      const String text = 'Tap hoa\nBut bi   1\nVo   1\n45.000';
      final result = ReceiptParser.parse(text, now: now);

      expect(result.amount, 45000);
    });

    test('reads the total from the next line when the label stands alone', () {
      const String text = 'Highlands Coffee\nTỔNG CỘNG\n59.000đ';
      final result = ReceiptParser.parse(text, now: now);

      expect(result.amount, 59000);
      expect(result.categoryId, CategoryKeys.food);
    });

    test('falls back to the largest number when there is no total line', () {
      const String text = 'Grab ride\n25/09/2026\n12.000\n45.000';
      final result = ReceiptParser.parse(text, now: now);

      expect(result.amount, 45000);
      expect(result.categoryId, CategoryKeys.transport);
    });

    test('skips the "hoa don" header for description and category', () {
      const String text = 'HOÁ ĐƠN BÁN LẺ\nNhà sách Fahasa\nThanh toán: 150.000';
      final result = ReceiptParser.parse(text, now: now);

      expect(result.description, 'Nhà sách Fahasa');
      expect(result.categoryId, CategoryKeys.education);
      expect(result.amount, 150000);
    });

    test('future or impossible dates fall back to today (BR-94)', () {
      final future = ReceiptParser.parse('Shop ABC\n30/09/2026\nTotal 10.000', now: now);
      final impossible = ReceiptParser.parse('Shop ABC\n31/02/2026\nTotal 10.000', now: now);

      expect(future.date, now);
      expect(future.isDateFromReceipt, isFalse);
      expect(impossible.date, now);
    });

    test('text without a money amount keeps amount empty (BR-96)', () {
      final result = ReceiptParser.parse('Thank you\nSee you again', now: now);

      expect(result.hasText, isTrue);
      expect(result.amount, isNull);
      expect(result.description, 'Thank you');
    });

    test('empty text means nothing was read (BR-96)', () {
      final result = ReceiptParser.parse('  \n \n', now: now);

      expect(result.hasText, isFalse);
      expect(result.amount, isNull);
      expect(result.description, isNull);
      expect(result.date, now);
    });
  });

  group('ReceiptTextBuilder', () {
    TextLinePosition line(String text, double top, double left) {
      return TextLinePosition(text: text, top: top, bottom: top + 40, left: left);
    }

    test('joins the left label and the right amount of the same row', () {
      final List<TextLinePosition> blocksInMlKitOrder = [
        line('TONG CONG', 700, 50),
        line('Tien khach dua', 780, 50),
        line('125.000', 704, 480),
        line('200.000', 782, 480),
      ];

      final String text = ReceiptTextBuilder.buildRows(blocksInMlKitOrder);

      expect(text, 'TONG CONG   125.000\nTien khach dua   200.000');
      expect(ReceiptParser.parse(text, now: now).amount, 125000);
    });

    test('lines on different rows stay separate and keep top-to-bottom order', () {
      final String text = ReceiptTextBuilder.buildRows([line('B', 200, 0), line('A', 100, 0)]);
      expect(text, 'A\nB');
    });

    test('no lines gives empty text', () {
      expect(ReceiptTextBuilder.buildRows([]), '');
    });
  });
}
