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
  static const List<String> _models = [
    'gemini-3.1-flash-lite',
    'gemini-flash-latest',
    'gemini-3.8-flash',
    'gemini-2.5-flash',
    'gemini-1.5-flash',
  ];
  static const String _envApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// Retrieves the active Gemini API key (from SharedPreferences or dart-define).
  static Future<String> getApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString(_prefApiKey)?.trim();
      if (savedKey != null && savedKey.isNotEmpty) return savedKey;
    } catch (e) {
      debugPrint('GeminiAdvisorService.getApiKey error: $e');
    }
    return _envApiKey.trim();
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

  /// Checks if the user's message is asking for a budget plan.
  static bool isBudgetPlanningRequest(String query) {
    final q = query.toLowerCase();
    return q.contains('kế hoạch') ||
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
  }

  /// Calls Gemini API to get advice or a structured budget plan.
  /// Falls back to offline heuristic plan if no key, offline, or request fails.
  static Future<ChatMessage> generateResponse({
    required String query,
    required ChatbotData data,
    required String languageCode,
    required DateTime now,
  }) async {
    final String currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final bool isPlanning = isBudgetPlanningRequest(query);

    final apiKey = await getApiKey();
    if (apiKey.isEmpty) {
      // Offline fallback
      if (isPlanning) {
        return _buildHeuristicBudgetPlanMessage(data: data, month: currentMonth, languageCode: languageCode, now: now);
      }
      return ChatMessage(
        isUser: false,
        text: languageCode == 'vi'
            ? 'Bạn chưa cài đặt Gemini API Key. Bạn có thể nhấn vào biểu tượng ✨ trên thanh tiêu đề để cài đặt, hoặc Penny sẽ trả lời tự động nhé!'
            : 'Gemini API Key is not configured. Tap the ✨ icon on the top bar to set it up, or Penny will assist offline!',
        sentAt: now.millisecondsSinceEpoch,
      );
    }

    try {
      final responseText = await _callGeminiApi(
        apiKey: apiKey,
        query: query,
        data: data,
        languageCode: languageCode,
        now: now,
        isPlanning: isPlanning,
      );

      if (isPlanning) {
        // Try parsing JSON budget plan from response
        final plan = _tryParseBudgetPlan(responseText, currentMonth, data);
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
      }

      // Regular text response
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
      if (isPlanning) {
        return _buildHeuristicBudgetPlanMessage(data: data, month: currentMonth, languageCode: languageCode, now: now);
      }
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
  }) async {
    // 1. Gather context data
    final double monthIncome = _calculateMonthIncome(data.transactions, now);
    final double fixedExpenses = _calculateFixedExpenses(data.recurringItems);
    final double monthlySavings = _calculateMonthlySavingsTarget(data.goals);

    final contextInfo = {
      'user_name': data.userName,
      'month': '${now.month}/${now.year}',
      'estimated_income': monthIncome,
      'fixed_expenses': fixedExpenses,
      'monthly_savings_goal': monthlySavings,
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
Người dùng đang yêu cầu lập kế hoạch chi tiêu / ngân sách cho tháng này.
Hãy phân bổ ngân sách thật hợp lý dựa trên thu nhập (nếu thu nhập = 0 thì giả định mức trung bình sinh viên khoảng 4.000.000 - 5.000.000 đ), trừ đi các khoản chi cố định và mục tiêu tiết kiệm.
BẠN BẮT BUỘC PHẢI TRẢ VỀ DUY NHẤT MỘT ĐỐI TƯỢNG JSON CÓ CẤU TRÚC NHƯ SAU (KHÔNG THÊM BẤT KỲ VĂN BẢN NÀO BÊN NGOÀI JSON):
{
  "summary": "Lời khuyên ngắn gọn, thân thiện, vui vẻ từ chú heo Penny về kế hoạch này",
  "estimatedIncome": số_tiền_thu_nhập,
  "fixedExpensesTotal": tổng_tiền_cố_định,
  "savingsTotal": tổng_tiền_tiết_kiệm,
  "allocations": [
    {"categoryId": "food", "categoryName": "Ăn uống", "amount": số_tiền, "note": "Ghi chú ngắn"},
    {"categoryId": "transport", "categoryName": "Đi lại", "amount": số_tiền, "note": "Ghi chú ngắn"},
    {"categoryId": "education", "categoryName": "Học tập", "amount": số_tiền, "note": "Ghi chú ngắn"},
    {"categoryId": "shopping", "categoryName": "Mua sắm", "amount": số_tiền, "note": "Ghi chú ngắn"},
    {"categoryId": "entertainment", "categoryName": "Giải trí", "amount": số_tiền, "note": "Ghi chú ngắn"},
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

  static BudgetPlanProposal? _tryParseBudgetPlan(String jsonStr, String currentMonth, ChatbotData data) {
    try {
      String cleanJson = jsonStr.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      }
      if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.substring(3);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();

      final parsed = jsonDecode(cleanJson);
      if (parsed is! Map<String, dynamic>) return null;

      final double estimatedIncome = (parsed['estimatedIncome'] is num)
          ? (parsed['estimatedIncome'] as num).toDouble()
          : _calculateMonthIncome(data.transactions, DateTime.now());
      final double fixedExpensesTotal = (parsed['fixedExpensesTotal'] is num)
          ? (parsed['fixedExpensesTotal'] as num).toDouble()
          : _calculateFixedExpenses(data.recurringItems);
      final double savingsTotal = (parsed['savingsTotal'] is num)
          ? (parsed['savingsTotal'] as num).toDouble()
          : _calculateMonthlySavingsTarget(data.goals);

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
        month: currentMonth,
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

    return languageCode == 'vi'
        ? '🐷 Penny đã phân tích thu nhập và các khoản chi cố định của bạn để tạo ra kế hoạch chi tiêu tối ưu cho tháng này! Hãy xem và bấm "Áp dụng vào Ngân sách" bên dưới nhé:'
        : '🐷 Penny has analyzed your income and fixed expenses to design an optimal budget for this month! Review and tap "Apply to Budget" below:';
  }

  /// Fallback offline heuristic budget plan generator (uses 50/30/20 standard)
  static BudgetPlanProposal generateHeuristicPlan({
    required ChatbotData data,
    required String month,
  }) {
    final DateTime now = DateTime.now();
    double income = _calculateMonthIncome(data.transactions, now);
    if (income <= 0) {
      // Default estimated student allowance if no income logged yet
      income = 5000000;
    }

    final double fixedExpenses = _calculateFixedExpenses(data.recurringItems);
    final double savingsGoal = _calculateMonthlySavingsTarget(data.goals);

    double available = income - fixedExpenses - savingsGoal;
    if (available <= 0) available = income * 0.5;

    // Distribute available funds
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
    required String languageCode,
    required DateTime now,
  }) {
    final plan = generateHeuristicPlan(data: data, month: month);
    final text = languageCode == 'vi'
        ? '🐷 Dựa trên thu nhập và các khoản chi tiêu của bạn, Penny đã thiết kế một bảng phân bổ ngân sách thông minh (quy tắc 50/30/20) để bạn kiểm soát chi tiêu tốt nhất trong tháng này:'
        : '🐷 Based on your income and expenses, Penny designed a smart budget allocation (50/30/20 rule) to help you stay on track this month:';

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

  static double _calculateMonthIncome(List<TransactionRecord> transactions, DateTime now) {
    final int startOfMonth = DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
    final int endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59).millisecondsSinceEpoch;

    double income = 0;
    for (final tx in transactions) {
      if (tx.type == TransactionTypes.income && tx.date >= startOfMonth && tx.date <= endOfMonth) {
        income += tx.amount;
      }
    }
    return income;
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
          // Approximate monthly need
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
