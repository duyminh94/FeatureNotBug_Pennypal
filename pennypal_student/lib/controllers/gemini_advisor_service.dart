import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/budget_plan_proposal.dart';
import '../models/chat_message.dart';
import '../models/recurring_item.dart';
import '../models/savings_goal.dart';
import '../models/transaction_record.dart';
import '../utils/chatbot_engine.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class GeminiAdvisorService {
  static const String _prefApiKey = 'gemini_api_key';
  static final String _defaultBackendApiKey =
      utf8.decode(base64Decode('QVEuQWI4Uk42SlRyYWRpNjYyWnVYQ2R0cmZrMEhRS0lUMk1pdVJpTU9hWHNrdDRvQ2JyTWc='));
  static const List<String> _models = [
    'gemini-2.5-flash',
    'gemini-flash-latest',
    'gemini-2.5-flash-lite',
    'gemini-3.1-flash-lite',
  ];
  static const String _envApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// Retrieves the active Gemini API key. Defaults to built-in backend API key.
  static Future<String> getApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString(_prefApiKey)?.trim();
      if (savedKey != null && savedKey.isNotEmpty) return savedKey;
    } catch (e) {
      debugPrint('GeminiAdvisorService.getApiKey error: $e');
    }
    if (_envApiKey.trim().isNotEmpty) return _envApiKey.trim();
    return _defaultBackendApiKey;
  }

  /// Saves the user-provided Gemini API key to SharedPreferences.
  static Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefApiKey, apiKey.trim());
  }

  /// Checks if Gemini API key is configured.
  static Future<bool> isConfigured() async {
    final key = await getApiKey();
    return key.isNotEmpty;
  }

  /// Parses the target planning month (e.g. "2026-10") from the user's query.
  static String parseTargetMonth(String query, DateTime now, {String? fallbackMonth}) {
    final q = query.toLowerCase();

    // 1. "tháng sau", "tháng tới", "tháng tiếp", "next month"
    if (q.contains('tháng sau') ||
        q.contains('thang sau') ||
        q.contains('tháng tới') ||
        q.contains('thang toi') ||
        q.contains('tháng tiếp') ||
        q.contains('thang tiep') ||
        q.contains('tháng kế') ||
        q.contains('thang ke') ||
        q.contains('next month')) {
      final next = DateTime(now.year, now.month + 1);
      return '${next.year}-${next.month.toString().padLeft(2, '0')}';
    }

    // 2. Specific month with year: "tháng 10/2026", "thang 10-2026", "tháng 10.2026"
    final monthYearPattern = RegExp(r'(?:tháng|thang|month)\s*([0-9]{1,2})[\/\-\.]([0-9]{4})');
    final myMatch = monthYearPattern.firstMatch(q);
    if (myMatch != null) {
      final m = int.tryParse(myMatch.group(1)!);
      final y = int.tryParse(myMatch.group(2)!);
      if (m != null && m >= 1 && m <= 12 && y != null && y >= 2020) {
        return '$y-${m.toString().padLeft(2, '0')}';
      }
    }

    // 3. Month number only: "tháng 10", "thang 10", "month 10"
    final monthPattern = RegExp(r'(?:tháng|thang|month)\s*([0-9]{1,2})\b');
    final mMatch = monthPattern.firstMatch(q);
    if (mMatch != null) {
      final m = int.tryParse(mMatch.group(1)!);
      if (m != null && m >= 1 && m <= 12) {
        final y = m < now.month ? now.year + 1 : now.year;
        return '$y-${m.toString().padLeft(2, '0')}';
      }
    }

    if (fallbackMonth != null && fallbackMonth.isNotEmpty) {
      return fallbackMonth;
    }

    // Default to current month
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  /// Parses expected income amount from user query if provided.
  static double? parseIncomeFromQuery(String query) {
    final q = query.toLowerCase();

    // 1. Check compound "XtrY" or "X triệu Y" (e.g. "5tr5", "5 triệu 5")
    final trPatternCompound = RegExp(r'(\d+)\s*(?:tr|triệu|trieu)\s*(\d+)');
    final compoundMatch = trPatternCompound.firstMatch(q);
    if (compoundMatch != null) {
      final double major = double.parse(compoundMatch.group(1)!);
      final rawMinor = compoundMatch.group(2)!;
      double minor;
      if (rawMinor.length == 1) {
        minor = double.parse(rawMinor) * 100000;
      } else if (rawMinor.length == 2) {
        minor = double.parse(rawMinor) * 10000;
      } else if (rawMinor.length == 3) {
        minor = double.parse(rawMinor) * 1000;
      } else {
        minor = double.parse(rawMinor);
      }
      return major * 1000000 + minor;
    }

    // 2. Check "X.Y triệu", "X.Y tr", "X triệu", "X tr", "Xm"
    final trPattern = RegExp(r'(\d+(?:[\.,]\d+)?)\s*(?:triệu|trieu|tr\b|m\b)');
    final trMatch = trPattern.firstMatch(q);
    if (trMatch != null) {
      final valStr = trMatch.group(1)!.replaceAll(',', '.');
      final val = double.tryParse(valStr);
      if (val != null) {
        return val * 1000000;
      }
    }

    // 3. Check "Xk", "X nghìn", "X ngàn"
    final kPattern = RegExp(r'(\d+(?:[\.,]\d+)?)\s*(?:k\b|nghìn|ngàn|nghin|ngan)');
    final kMatch = kPattern.firstMatch(q);
    if (kMatch != null) {
      final valStr = kMatch.group(1)!.replaceAll(',', '.');
      final val = double.tryParse(valStr);
      if (val != null) {
        return val * 1000;
      }
    }

    // 4. Check full formatted or plain number: "5.000.000", "5,000,000", "5000000"
    final fullNumberPattern = RegExp(r'(?:thu nhập|lương|dự kiến|khoảng|có|là)?\s*(\d{1,3}(?:[\.,]\d{3}){1,3}|\d{6,10})\s*(?:đ|vnd|đồng|dong)?');
    for (final match in fullNumberPattern.allMatches(q)) {
      final raw = match.group(1);
      if (raw != null) {
        final clean = raw.replaceAll('.', '').replaceAll(',', '');
        final val = double.tryParse(clean);
        if (val != null && val >= 500000) {
          return val;
        }
      }
    }

    return null;
  }

  /// Checks if the user's message is asking for a budget plan or answering an income prompt.
  static bool isBudgetPlanningRequest(String query) {
    final q = query.toLowerCase();
    final bool hasPlanningKeyword = q.contains('kế hoạch') ||
        q.contains('ke hoach') ||
        q.contains('ngân sách') ||
        q.contains('ngan sach') ||
        q.contains('chia tiền') ||
        q.contains('chia tien') ||
        q.contains('phân bổ') ||
        q.contains('phan bo') ||
        q.contains('lập bảng') ||
        q.contains('lap bang') ||
        q.contains('budget') ||
        q.contains('plan');

    if (hasPlanningKeyword) return true;

    // Answering an expected income prompt (e.g. "Thu nhập 5 triệu", "Lương 6tr")
    final bool isQuestioning = q.contains('bao nhiêu') || q.contains('bao nhieu') || q.contains('how much');
    if (!isQuestioning && (q.contains('thu nhập') || q.contains('thu nhap') || q.contains('lương') || q.contains('luong'))) {
      if (parseIncomeFromQuery(query) != null) {
        return true;
      }
    }

    return false;
  }

  /// Calculates total recorded income for a specific month string (e.g. "2026-10").
  static double calculateMonthIncomeForMonth(List<TransactionRecord> transactions, String monthStr) {
    try {
      final parts = monthStr.split('-');
      final int year = int.parse(parts[0]);
      final int month = int.parse(parts[1]);
      final int startOfMonth = DateTime(year, month, 1).millisecondsSinceEpoch;
      final int endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59).millisecondsSinceEpoch;

      double income = 0;
      for (final tx in transactions) {
        if (tx.type == TransactionTypes.income && tx.date >= startOfMonth && tx.date <= endOfMonth) {
          income += tx.amount;
        }
      }
      return income;
    } catch (_) {
      return 0.0;
    }
  }

  /// Calls Gemini API to get advice or a structured budget plan.
  /// Falls back to offline heuristic plan if no key, offline, or request fails.
  static Future<ChatMessage> generateResponse({
    required String query,
    required ChatbotData data,
    required String languageCode,
    required DateTime now,
    String? pendingMonth,
  }) async {
    final String currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final bool isPlanning = isBudgetPlanningRequest(query);

    if (isPlanning) {
      final String targetMonth = parseTargetMonth(query, now, fallbackMonth: pendingMonth);
      final double? explicitIncome = parseIncomeFromQuery(query);
      final double recordedIncome = calculateMonthIncomeForMonth(data.transactions, targetMonth);
      final double targetIncome = explicitIncome ?? recordedIncome;

      // Missing income scenario: target month has no recorded income and user did not specify one
      if (targetIncome <= 0) {
        final targetParts = targetMonth.split('-');
        final displayMonth = '${targetParts[1]}/${targetParts[0]}';
        return ChatMessage(
          isUser: false,
          text: languageCode == 'vi'
              ? '🐷 Để Penny giúp bạn lập kế hoạch chi tiêu tháng $displayMonth thật sát với thực tế, bạn dự kiến thu nhập tháng này (tiền lương làm thêm, trợ cấp gia đình...) là bao nhiêu nè?\n\nBạn có thể chọn nhanh gợi ý bên dưới hoặc gõ trực tiếp (Ví dụ: "Thu nhập tháng ${targetParts[1]} là 5 triệu"):'
              : '🐷 To help you plan an accurate budget for $displayMonth, what is your expected income (allowance, part-time salary, etc.) for this month?\n\nYou can select a suggestion below or type directly (e.g. "Expected income $displayMonth is 5 million"):',
          suggestions: languageCode == 'vi'
              ? [
                  'Thu nhập tháng ${targetParts[1]} là 4 triệu',
                  'Thu nhập tháng ${targetParts[1]} là 5 triệu',
                  'Thu nhập tháng ${targetParts[1]} là 6 triệu',
                  'Thu nhập tháng ${targetParts[1]} là 7 triệu',
                ]
              : [
                  'Expected income 4 million',
                  'Expected income 5 million',
                  'Expected income 6 million',
                  'Expected income 7 million',
                ],
          pendingMonth: targetMonth,
          sentAt: now.millisecondsSinceEpoch,
        );
      }

      // We have targetIncome > 0
      final apiKey = await getApiKey();
      if (apiKey.isEmpty) {
        return _buildHeuristicBudgetPlanMessage(
          data: data,
          month: targetMonth,
          income: targetIncome,
          languageCode: languageCode,
          now: now,
        );
      }

      try {
        final responseText = await _callGeminiApi(
          apiKey: apiKey,
          query: query,
          data: data,
          languageCode: languageCode,
          now: now,
          isPlanning: true,
          targetMonth: targetMonth,
          targetIncome: targetIncome,
        );

        final plan = _tryParseBudgetPlan(responseText, targetMonth, data, targetIncome);
        if (plan != null) {
          final summary = _extractSummary(responseText, plan, languageCode);
          return ChatMessage(
            isUser: false,
            text: summary,
            budgetPlan: plan,
            suggestions: languageCode == 'vi'
                ? ['Kiểm tra số dư', 'Chi tiêu tháng này', 'Xem mục tiêu tiết kiệm']
                : ['Check balance', 'This month spending', 'View savings goals'],
            sentAt: now.millisecondsSinceEpoch,
          );
        }

        return _buildHeuristicBudgetPlanMessage(
          data: data,
          month: targetMonth,
          income: targetIncome,
          languageCode: languageCode,
          now: now,
        );
      } catch (e) {
        debugPrint('GeminiAdvisorService planning API call failed: $e');
        return _buildHeuristicBudgetPlanMessage(
          data: data,
          month: targetMonth,
          income: targetIncome,
          languageCode: languageCode,
          now: now,
        );
      }
    }

    // General AI chat query
    final apiKey = await getApiKey();
    if (apiKey.isEmpty) {
      return ChatMessage(
        isUser: false,
        text: languageCode == 'vi'
            ? 'Penny đang hoạt động ở chế độ ngoại tuyến. Bạn có thể hỏi về số dư, chi tiêu hoặc lập kế hoạch chi tiêu nhé!'
            : 'Penny is running in offline mode. You can ask about balance, spending, or budget planning!',
        sentAt: now.millisecondsSinceEpoch,
      );
    }

    try {
      final double monthIncome = calculateMonthIncomeForMonth(data.transactions, currentMonth);
      final responseText = await _callGeminiApi(
        apiKey: apiKey,
        query: query,
        data: data,
        languageCode: languageCode,
        now: now,
        isPlanning: false,
        targetMonth: currentMonth,
        targetIncome: monthIncome > 0 ? monthIncome : 5000000,
      );

      return ChatMessage(
        isUser: false,
        text: responseText.trim(),
        suggestions: languageCode == 'vi'
            ? ['Lập kế hoạch chi tiêu tháng', 'Tháng này chi bao nhiêu?', 'Tiết kiệm thế nào?']
            : ['Plan monthly budget', 'How much spent this month?', 'How to save?'],
        sentAt: now.millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('GeminiAdvisorService API call failed: $e');
      rethrow;
    }
  }

  static Future<String> _callGeminiApi({
    required String apiKey,
    required String query,
    required ChatbotData data,
    required String languageCode,
    required DateTime now,
    required bool isPlanning,
    required String targetMonth,
    required double targetIncome,
  }) async {
    final double fixedExpenses = _calculateFixedExpenses(data.recurringItems);
    final double monthlySavings = _calculateMonthlySavingsTarget(data.goals);
    final bool isDeficit = targetIncome > 0 && targetIncome < fixedExpenses;
    final double deficitAmount = isDeficit ? fixedExpenses - targetIncome : 0.0;

    final contextInfo = {
      'user_name': data.userName,
      'target_month': targetMonth,
      'estimated_income': targetIncome,
      'fixed_expenses': fixedExpenses,
      'monthly_savings_goal': monthlySavings,
      'is_deficit': isDeficit,
      'deficit_amount': deficitAmount,
      'active_goals': data.goals.map((g) => '${g.name} (${Formatters.money(g.targetAmount)})').toList(),
      'fixed_items': data.recurringItems
          .where((r) => r.isActive)
          .map((r) => '${r.description.isNotEmpty ? r.description : r.categoryId}: ${Formatters.money(r.amount)}')
          .toList(),
    };

    final systemInstruction = '''
Bạn là Penny - chú heo trợ lý tài chính thông minh, dễ thương, thực tế và chu đáo của ứng dụng PennyPal dành cho sinh viên Việt Nam.
Ngôn ngữ trả lời: ${languageCode == 'vi' ? 'Tiếng Việt' : 'English'}.
Thông tin tài chính của sinh viên:
${jsonEncode(contextInfo)}

${isPlanning ? '''
Người dùng đang yêu cầu lập kế hoạch chi tiêu / ngân sách cho tháng $targetMonth với mức thu nhập dự kiến là ${Formatters.money(targetIncome)}.
${isDeficit ? '''
CẢNH BÁO TÌNH HUỐNG KHẨN CẤP:
Thu nhập dự kiến (${Formatters.money(targetIncome)}) ĐANG THẤP HƠN tổng chi phí cố định (${Formatters.money(fixedExpenses)}).
Mức thâm hụt: -${Formatters.money(deficitAmount)}.
BẮT BUỘC:
1. Đặt "savingsTotal": 0.
2. Cắt giảm hoàn toàn chi tiêu không thiết yếu: "shopping" amount = 0, "entertainment" amount = 0 (với note ghi rõ: "Tạm ngừng để bù thâm hụt").
3. Phân bổ các khoản thiết yếu tối thiểu ("food", "transport", "bills") trong giới hạn tiền hiện có.
4. Trong "summary", đưa ra cảnh báo thâm hụt rõ ràng và 4 lời khuyên tài chính khẩn cấp cho sinh viên (1. Cắt giảm triệt để; 2. Giữ ăn uống sinh tồn; 3. Đàm phán dãn hạn tiền phòng/cố định; 4. Tìm thêm việc làm thêm hoặc nhờ trợ cấp khẩn cấp).
''' : '''
Hãy phân bổ ngân sách thật hợp lý dựa trên quy tắc 50/30/20 phù hợp với đời sống sinh viên, trừ đi các khoản chi cố định và mục tiêu tiết kiệm.
'''}
BẠN BẮT BUỘC PHẢI TRẢ VỀ DUY NHẤT MỘT ĐỐI TƯỢNG JSON CÓ CẤU TRÚC NHƯ SAU (KHÔNG THÊM BẤT KỲ VĂN BẢN NÀO BÊN NGOÀI JSON):
{
  "summary": "Lời khuyên ngắn gọn, thân thiện, vui vẻ và sâu sắc từ chú heo Penny về kế hoạch này",
  "estimatedIncome": $targetIncome,
  "fixedExpensesTotal": $fixedExpenses,
  "savingsTotal": ${isDeficit ? 0 : 'số_tiền_tiết_kiệm'},
  "allocations": [
    {"categoryId": "food", "categoryName": "Ăn uống", "amount": số_tiền, "note": "Ghi chú ngắn"},
    {"categoryId": "transport", "categoryName": "Đi lại", "amount": số_tiền, "note": "Ghi chú ngắn"},
    {"categoryId": "education", "categoryName": "Học tập", "amount": số_tiền, "note": "Ghi chú ngắn"},
    {"categoryId": "shopping", "categoryName": "Mua sắm", "amount": số_tiền, "note": "Ghi chú ngắn"},
    {"categoryId": "entertainment", "categoryName": "Giải trí", "amount": số_tiền, "note": "Ghi chú ngắn"},
    {"categoryId": "bills", "categoryName": "Hoá đơn & Cố định", "amount": số_tiền, "note": "Ghi chú ngắn"},
    {"categoryId": "savings", "categoryName": "Tiết kiệm", "amount": số_tiền, "note": "Ghi chú ngắn"}
  ]
}
Chỉ dùng các categoryId: "food", "transport", "education", "shopping", "entertainment", "bills", "savings", "miscellaneous".
''' : '''
Hãy trả lời thân thiện, súc tích, mang tính khuyến khích, có emoji vui nhộn, tư vấn đúng tâm lý sinh viên.
'''}
''';

    final requestBody = {
      'system_instruction': {
        'parts': [
          {'text': systemInstruction}
        ]
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': query}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        if (isPlanning) 'response_mime_type': 'application/json',
      }
    };

    final httpClient = HttpClient()..connectionTimeout = const Duration(seconds: 12);
    try {
      Object? lastError;
      for (final model in _models) {
        try {
          final url = Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey');
          final request = await httpClient.postUrl(url);
          request.headers.set('content-type', 'application/json; charset=utf-8');
          request.add(utf8.encode(jsonEncode(requestBody)));
          final response = await request.close();
          final responseBody = await response.transform(utf8.decoder).join();

          if (response.statusCode != 200) {
            debugPrint('Gemini model $model returned ${response.statusCode}: $responseBody');
            lastError = HttpException('Gemini API ($model) returned status ${response.statusCode}: $responseBody');
            continue;
          }

          final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
          final candidates = jsonResponse['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'];
            final parts = content?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              return parts[0]['text']?.toString() ?? '';
            }
          }
        } catch (e) {
          debugPrint('Error calling Gemini model $model: $e');
          lastError = e;
        }
      }
      throw lastError ?? const FormatException('Empty response from Gemini');
    } finally {
      httpClient.close();
    }
  }

  static BudgetPlanProposal? _tryParseBudgetPlan(
    String jsonStr,
    String targetMonth,
    ChatbotData data,
    double targetIncome,
  ) {
    try {
      String cleanJson = jsonStr.trim();
      if (cleanJson.startsWith('```json')) cleanJson = cleanJson.substring(7);
      if (cleanJson.startsWith('```')) cleanJson = cleanJson.substring(3);
      if (cleanJson.endsWith('```')) cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      cleanJson = cleanJson.trim();

      final parsed = jsonDecode(cleanJson);
      if (parsed is! Map<String, dynamic>) return null;

      final double estimatedIncome = (parsed['estimatedIncome'] is num)
          ? (parsed['estimatedIncome'] as num).toDouble()
          : targetIncome;
      final double fixedExpensesTotal = (parsed['fixedExpensesTotal'] is num)
          ? (parsed['fixedExpensesTotal'] as num).toDouble()
          : _calculateFixedExpenses(data.recurringItems);
      final double savingsTotal = (parsed['savingsTotal'] is num)
          ? (parsed['savingsTotal'] as num).toDouble()
          : (estimatedIncome < fixedExpensesTotal ? 0.0 : _calculateMonthlySavingsTarget(data.goals));

      final allocationsList = parsed['allocations'] as List?;
      if (allocationsList == null || allocationsList.isEmpty) return null;

      final List<BudgetPlanItem> items = [];
      for (final a in allocationsList) {
        if (a is Map<String, dynamic>) {
          items.add(BudgetPlanItem.fromMap(a));
        }
      }

      if (items.isEmpty) return null;

      return BudgetPlanProposal(
        month: targetMonth,
        estimatedIncome: estimatedIncome,
        fixedExpensesTotal: fixedExpensesTotal,
        savingsTotal: savingsTotal,
        items: items,
      );
    } catch (e) {
      debugPrint('_tryParseBudgetPlan error: $e');
      return null;
    }
  }

  static String _extractSummary(String jsonStr, BudgetPlanProposal plan, String languageCode) {
    try {
      String cleanJson = jsonStr.trim();
      if (cleanJson.startsWith('```json')) cleanJson = cleanJson.substring(7);
      if (cleanJson.startsWith('```')) cleanJson = cleanJson.substring(3);
      if (cleanJson.endsWith('```')) cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      final parsed = jsonDecode(cleanJson.trim());
      if (parsed is Map && parsed['summary'] != null) {
        return parsed['summary'].toString();
      }
    } catch (_) {}

    if (plan.isDeficit) {
      return languageCode == 'vi'
          ? '⚠️ **CẢNH BÁO THÂM HỤT TÀI CHÍNH THÁNG ${plan.month}**\n\n'
            'Khoản chi cố định (${Formatters.money(plan.fixedExpensesTotal)}) đang lớn hơn thu nhập dự kiến (${Formatters.money(plan.estimatedIncome)}), thâm hụt **-${Formatters.money(plan.deficitAmount)}**!\n\n'
            '🐷 Penny đã chuyển sang chế độ sinh tồn: Cắt giảm mua sắm, giải trí về 0đ và giữ lại mức sinh hoạt tối thiểu. Hãy xem kế hoạch dưới đây:'
          : '⚠️ **FINANCIAL DEFICIT ALERT FOR ${plan.month}**\n\n'
            'Fixed expenses exceed expected income by **-${Formatters.money(plan.deficitAmount)}**!\n\n'
            '🐷 Penny created an emergency survival plan: Non-essentials zeroed out, essential sustenance prioritized.';
    }

    return languageCode == 'vi'
        ? '🐷 Penny đã phân tích thu nhập và các khoản chi cố định của bạn để tạo ra kế hoạch chi tiêu tối ưu cho tháng ${plan.month}! Hãy xem và bấm "Áp dụng vào Ngân sách" bên dưới nhé:'
        : '🐷 Penny has analyzed your income and fixed expenses to design an optimal budget for month ${plan.month}! Review and tap "Apply to Budget" below:';
  }

  /// Fallback offline heuristic budget plan generator.
  /// Handles both standard 50/30/20 rule and deficit survival mode when income < fixedExpenses.
  static BudgetPlanProposal generateHeuristicPlan({
    required ChatbotData data,
    required String month,
    double? incomeOverride,
  }) {
    double income = incomeOverride ?? calculateMonthIncomeForMonth(data.transactions, month);
    if (income <= 0) {
      income = 5000000;
    }

    final double fixedExpenses = _calculateFixedExpenses(data.recurringItems);
    final double savingsGoal = _calculateMonthlySavingsTarget(data.goals);
    final bool isDeficit = income < fixedExpenses;

    if (isDeficit) {
      // Deficit mode: Survival budget allocation
      final List<BudgetPlanItem> items = [
        BudgetPlanItem(
          categoryId: CategoryKeys.food,
          categoryName: 'Ăn uống',
          amount: _roundToTenThousand(income * 0.40),
          note: 'Mức ăn uống sinh tồn, tự nấu ăn tại nhà',
        ),
        BudgetPlanItem(
          categoryId: CategoryKeys.transport,
          categoryName: 'Đi lại',
          amount: _roundToTenThousand(income * 0.15),
          note: 'Xăng xe / xe buýt di chuyển bắt buộc',
        ),
        BudgetPlanItem(
          categoryId: CategoryKeys.education,
          categoryName: 'Học tập',
          amount: _roundToTenThousand(income * 0.10),
          note: 'Chỉ in ấn tài liệu cấp bách',
        ),
        BudgetPlanItem(
          categoryId: CategoryKeys.bills,
          categoryName: 'Hoá đơn & Cố định',
          amount: _roundToTenThousand(income * 0.35),
          note: 'Ưu tiên chi gấp, xin dãn nợ phần còn lại',
        ),
        BudgetPlanItem(
          categoryId: CategoryKeys.shopping,
          categoryName: 'Mua sắm',
          amount: 0.0,
          note: 'Tạm ngưng hoàn toàn để bù thâm hụt',
        ),
        BudgetPlanItem(
          categoryId: CategoryKeys.entertainment,
          categoryName: 'Giải trí',
          amount: 0.0,
          note: 'Tạm ngưng hoàn toàn để bù thâm hụt',
        ),
      ];

      return BudgetPlanProposal(
        month: month,
        estimatedIncome: income,
        fixedExpensesTotal: fixedExpenses,
        savingsTotal: 0.0,
        items: items,
      );
    }

    // Normal mode: 50/30/20 rule
    double available = income - fixedExpenses - savingsGoal;
    if (available <= 0) available = income * 0.5;

    final List<BudgetPlanItem> items = [
      BudgetPlanItem(
        categoryId: CategoryKeys.food,
        categoryName: 'Ăn uống',
        amount: _roundToTenThousand(available * 0.45),
        note: 'Cơm trưa, nước uống sinh hoạt',
      ),
      BudgetPlanItem(
        categoryId: CategoryKeys.transport,
        categoryName: 'Đi lại',
        amount: _roundToTenThousand(available * 0.15),
        note: 'Xăng xe, xe buýt',
      ),
      BudgetPlanItem(
        categoryId: CategoryKeys.education,
        categoryName: 'Học tập',
        amount: _roundToTenThousand(available * 0.15),
        note: 'Sách vở, in ấn, tài liệu',
      ),
      BudgetPlanItem(
        categoryId: CategoryKeys.shopping,
        categoryName: 'Mua sắm',
        amount: _roundToTenThousand(available * 0.125),
        note: 'Vật dụng cá nhân',
      ),
      BudgetPlanItem(
        categoryId: CategoryKeys.entertainment,
        categoryName: 'Giải trí',
        amount: _roundToTenThousand(available * 0.125),
        note: 'Cà phê bạn bè, thư giãn',
      ),
    ];

    if (savingsGoal > 0) {
      items.add(BudgetPlanItem(
        categoryId: CategoryKeys.savings,
        categoryName: 'Tiết kiệm',
        amount: _roundToTenThousand(savingsGoal),
        note: 'Đóng góp mục tiêu',
      ));
    }

    return BudgetPlanProposal(
      month: month,
      estimatedIncome: income,
      fixedExpensesTotal: fixedExpenses,
      savingsTotal: savingsGoal,
      items: items,
    );
  }

  static ChatMessage _buildHeuristicBudgetPlanMessage({
    required ChatbotData data,
    required String month,
    required double income,
    required String languageCode,
    required DateTime now,
  }) {
    final plan = generateHeuristicPlan(data: data, month: month, incomeOverride: income);
    String text;
    if (plan.isDeficit) {
      text = languageCode == 'vi'
          ? '⚠️ **CẢNH BÁO THÂM HỤT TÀI CHÍNH THÁNG ${plan.month}**\n\n'
            'Khoản chi cố định (${Formatters.money(plan.fixedExpensesTotal)}) đang lớn hơn thu nhập dự kiến (${Formatters.money(plan.estimatedIncome)}), thâm hụt **-${Formatters.money(plan.deficitAmount)}**!\n\n'
            '🐷 **Kế hoạch tài chính sinh tồn khẩn cấp:**\n'
            '1. 🚫 **Cắt bỏ hoàn toàn**: Mua sắm & giải trí giảm về 0đ.\n'
            '2. 🍲 **Chi tiêu tối thiểu**: Giữ tiền ăn uống và đi lại ở mức sinh tồn.\n'
            '3. 🤝 **Đàm phán chi phí**: Xin chủ nhà dãn hạn đóng tiền phòng hoặc chia nhỏ 2 đợt.\n'
            '4. 💼 **Gia tăng thu nhập**: Tìm thêm việc part-time hoặc đề xuất gia đình hỗ trợ khẩn cấp.'
          : '⚠️ **FINANCIAL DEFICIT ALERT FOR ${plan.month}**\n\n'
            'Fixed expenses (${Formatters.money(plan.fixedExpensesTotal)}) exceed expected income (${Formatters.money(plan.estimatedIncome)}) by **-${Formatters.money(plan.deficitAmount)}**!\n\n'
            '🐷 **Emergency Survival Budget:**\n'
            '1. 🚫 **Zero Non-Essentials**: Shopping and entertainment set to 0.\n'
            '2. 🍲 **Sustenance Only**: Basic food and transport only.\n'
            '3. 🤝 **Negotiate Fixed Bills**: Ask for rent delay or installment.\n'
            '4. 💼 **Boost Income**: Find quick gigs or emergency support.';
    } else {
      text = languageCode == 'vi'
          ? '🐷 Dựa trên thu nhập ${Formatters.money(plan.estimatedIncome)} và các khoản chi tiêu của bạn, Penny đã thiết kế một bảng phân bổ ngân sách thông minh (quy tắc 50/30/20) để bạn kiểm soát chi tiêu tốt nhất trong tháng ${plan.month}:'
          : '🐷 Based on your income of ${Formatters.money(plan.estimatedIncome)} and fixed expenses, Penny designed a smart budget allocation (50/30/20 rule) to help you stay on track for month ${plan.month}:';
    }

    return ChatMessage(
      isUser: false,
      text: text,
      budgetPlan: plan,
      suggestions: languageCode == 'vi'
          ? ['Kiểm tra số dư', 'Chi tiêu tháng này', 'Xem mục tiêu']
          : ['Check balance', 'This month spending', 'View goals'],
      sentAt: now.millisecondsSinceEpoch,
    );
  }

  static double _calculateFixedExpenses(List<RecurringItem> items) {
    double total = 0;
    for (final item in items) {
      if (item.isActive && item.type == TransactionTypes.expense) {
        total += item.amount;
      }
    }
    return total;
  }

  static double _calculateMonthlySavingsTarget(List<SavingsGoal> goals) {
    double total = 0;
    for (final goal in goals) {
      if (goal.status != GoalStatuses.completed) {
        if (goal.monthlyContribution > 0) {
          total += goal.monthlyContribution;
        } else {
          final double remaining = (goal.targetAmount - goal.currentAmount).clamp(0, double.infinity);
          if (remaining > 0) {
            total += remaining > 500000 ? 500000 : remaining;
          }
        }
      }
    }
    return total;
  }

  static double _roundToTenThousand(double amount) {
    return (amount / 10000).round() * 10000.0;
  }
}
