import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/receipt_scan_result.dart';
import '../../models/recurring_item.dart';
import '../../models/transaction_record.dart';
import '../../services/category_service.dart';
import '../../services/receipt_scan_service.dart';
import '../../services/recurring_service.dart';
import '../../services/transaction_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/budget_calculator.dart';
import '../../utils/category_display.dart';
import '../../utils/category_keywords.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/labeled_text_field.dart';
import '../categories/categories_screen.dart';
import 'receipt_scan_widgets.dart';
import 'scan_reading_screen.dart';

/// S07 Add / edit transaction: one form for expense and income (BR-02 to BR-05), with receipt scan (BR-90 to BR-97).
class TransactionFormScreen extends StatefulWidget {
  final String type;
  final TransactionRecord? initial;

  const TransactionFormScreen({super.key, required this.type, this.initial});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateController;
  late DateTime _date;
  late String _paymentMode;
  String? _categoryId;
  bool _showCategoryError = false;
  bool _hasTriedToSave = false;
  String? _receiptPath;
  ScanNoticeType _scanNotice = ScanNoticeType.none;
  final Set<String> _filledFields = {};
  String? _suggestedCategoryId;
  late bool _isCategoryPickedByUser;
  bool _isRecurring = false;

  static const String _amountField = 'amount';
  static const String _descriptionField = 'description';
  static const String _dateField = 'date';

  bool get _isIncome => widget.type == TransactionTypes.income;
  bool get _isEditing => widget.initial != null;
  bool get _canScan => !_isIncome && ReceiptScanService.isSupported;

  @override
  void initState() {
    super.initState();
    final TransactionRecord? initial = widget.initial;
    _amountController = TextEditingController(text: initial == null ? '' : Formatters.groupDigits(initial.amount));
    _descriptionController = TextEditingController(text: initial?.description ?? '');
    _date = initial == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(initial.date);
    _dateController = TextEditingController(text: Formatters.fullDate(_date));
    _paymentMode = initial?.paymentMode ?? PaymentModes.cash;
    _categoryId = initial?.categoryId;
    _isCategoryPickedByUser = initial != null;
    _receiptPath = initial?.receiptLocalPath;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _title(AppLocalizations l10n) {
    if (_isEditing) return _isIncome ? l10n.txEditIncomeTitle : l10n.txEditExpenseTitle;
    return _isIncome ? l10n.txAddIncomeTitle : l10n.txAddExpenseTitle;
  }

  String? _validateAmount(String? value, AppLocalizations l10n) {
    final double? amount = Validators.parseAmount(value);
    if (!Validators.isPositiveAmount(amount)) return l10n.validationAmountPositive;
    return Validators.isWithinMaxAmount(amount!) ? null : l10n.validationAmountMax;
  }

  Future<void> _pickDate() async {
    final DateTime today = DateTime.now();
    // Editing a record older than 5 years: the picker must start at its date, or Flutter throws.
    DateTime firstDate = DateTime(today.year - 5);
    if (_date.isBefore(firstDate)) firstDate = DateTime(_date.year, _date.month, _date.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(today) ? today : _date,
      firstDate: firstDate,
      lastDate: today,
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateController.text = Formatters.fullDate(picked);
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _openCategories() async {
    final String? uid = CategoryService.currentUid();
    if (uid == null) return;
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => CategoriesScreen(uid: uid)));
    // A category made there is added to the grid when coming back.
    if (mounted) setState(() {});
  }

  Future<void> _startScan() async {
    final ImageSource? source = await showScanSourceSheet(context);
    if (source == null || !mounted) return;
    await _scanFrom(source);
  }

  Future<void> _scanFrom(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    final PickPhotoResult picked = await ReceiptScanService.pickPhoto(source);
    if (!mounted || picked.status == PickPhotoStatus.cancelled) return;
    if (picked.status == PickPhotoStatus.failed) {
      _showMessage(l10n.scanFailed);
      return;
    }
    if (picked.status == PickPhotoStatus.permissionDenied) {
      final PermissionChoice? choice = await showCameraPermissionSheet(context);
      if (choice == PermissionChoice.gallery && mounted) await _scanFrom(ImageSource.gallery);
      return;
    }

    final String photoPath = picked.imagePath!;
    final ReceiptScanResult? result = await Navigator.of(context).push<ReceiptScanResult>(
      MaterialPageRoute(builder: (context) => ScanReadingScreen(imagePath: photoPath)),
    );
    if (result == null) {
      await ReceiptScanService.deletePhoto(photoPath);
      return;
    }
    if (mounted) _applyScanResult(result);
  }

  /// BR-90: the scan only fills the form; the student still checks and saves it.
  void _applyScanResult(ReceiptScanResult result) {
    _removeOwnPhoto();
    setState(() {
      _receiptPath = result.imagePath;
      _filledFields.clear();
      _suggestedCategoryId = null;
      if (!result.hasText) {
        _scanNotice = ScanNoticeType.noText;
        return;
      }

      final double? amount = result.amount;
      if (amount != null) {
        _amountController.text = Formatters.groupDigits(amount);
        _filledFields.add(_amountField);
      }
      final String? description = result.description;
      if (description != null) {
        _descriptionController.text = description;
        _filledFields.add(_descriptionField);
      }
      _date = result.date;
      _dateController.text = Formatters.fullDate(result.date);
      if (result.isDateFromReceipt) _filledFields.add(_dateField);
      final String? categoryId = result.categoryId;
      if (categoryId != null) {
        _categoryId = categoryId;
        _suggestedCategoryId = categoryId;
        _showCategoryError = false;
      }
      _scanNotice = amount == null ? ScanNoticeType.noAmount : ScanNoticeType.filled;
    });
  }

  /// Suggests an expense category from the description; it only picks the category while the student has not picked one.
  void _onDescriptionChanged(String text) {
    if (_isIncome) return;
    final String? categoryId = CategoryKeywords.findCategory(text);
    setState(() {
      _suggestedCategoryId = categoryId;
      if (categoryId == null || _isCategoryPickedByUser) return;
      _categoryId = categoryId;
      _showCategoryError = false;
    });
  }

  /// Deletes the current photo only when this form created it (the saved transaction keeps its own photo).
  void _removeOwnPhoto() {
    final String? path = _receiptPath;
    if (path != null && path != widget.initial?.receiptLocalPath) ReceiptScanService.deletePhoto(path);
  }

  void _removeReceipt() {
    _removeOwnPhoto();
    setState(() => _receiptPath = null);
  }

  TransactionRecord _buildTransaction() {
    final TransactionRecord? initial = widget.initial;
    final int now = DateTime.now().millisecondsSinceEpoch;
    return TransactionRecord(
      id: initial?.id ?? TransactionService.newId(),
      type: widget.type,
      amount: Validators.parseAmount(_amountController.text)!,
      categoryId: _categoryId!,
      description: _descriptionController.text.trim(),
      date: _date.millisecondsSinceEpoch,
      paymentMode: _paymentMode,
      goalId: initial?.goalId,
      receiptLocalPath: _receiptPath,
      createdAt: initial?.createdAt ?? now,
      updatedAt: initial == null ? null : now,
    );
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    final bool isFormValid = _formKey.currentState!.validate();
    final bool isCategoryValid = Validators.isCategoryAllowed(_categoryId, widget.type);
    setState(() {
      _hasTriedToSave = true;
      _showCategoryError = !isCategoryValid;
    });
    if (!isFormValid || !isCategoryValid) return;

    if (_isRecurring) {
      _saveRecurring();
    } else {
      TransactionService.save(_buildTransaction());
    }
    _showMessage(l10n.txSaved);
    Navigator.of(context).pop(FormResults.saved);
  }

  // This month is the transaction being saved now, so the next one is created next month.
  void _saveRecurring() {
    final TransactionRecord transaction = _buildTransaction();
    final RecurringItem item = RecurringItem(
      id: RecurringService.newId(),
      type: transaction.type,
      amount: transaction.amount,
      categoryId: transaction.categoryId,
      description: transaction.description,
      paymentMode: transaction.paymentMode,
      dayOfMonth: _date.day,
      lastCreatedMonth: BudgetCalculator.monthKey(_date),
      createdAt: transaction.createdAt,
    );
    RecurringService.create(item, transaction);
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final TransactionRecord initial = widget.initial!;
    final String name = initial.description.isEmpty ? CategoryDisplay.name(l10n, initial.categoryId) : initial.description;
    final bool confirmed = await showConfirmDialog(
      context,
      title: l10n.txDeleteTitle,
      message: l10n.txDeleteBody(name, Formatters.signedMoney(initial.amount, isIncome: _isIncome)),
      confirmLabel: l10n.commonDelete,
      isDestructive: true,
      icon: Icons.delete_outline,
    );
    if (!confirmed || !mounted) return;

    TransactionService.delete(initial.id);
    _showMessage(l10n.txDeleted);
    Navigator.of(context).pop(FormResults.deleted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<String> categoryIds = CategoryDisplay.selectableIds(widget.type);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_title(l10n), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _hasTriedToSave ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            if (_scanNotice != ScanNoticeType.none) ...[
              ScanNotice(type: _scanNotice),
              const SizedBox(height: 12),
            ],
            _buildAmountCard(l10n),
            if (_receiptPath != null) ...[
              const SizedBox(height: 12),
              ReceiptPhotoCard(imagePath: _receiptPath!, onRemove: _removeReceipt),
            ],
            const SizedBox(height: 20),
            _SectionLabel(
              text: _isIncome ? l10n.txIncomeSource : l10n.txCategory,
              hint: _suggestedCategoryId == null ? null : l10n.scanSuggested(CategoryDisplay.name(l10n, _suggestedCategoryId!)),
              actionText: l10n.txManage,
              onAction: _openCategories,
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.9,
              children: categoryIds
                  .map((categoryId) => _CategoryOption(
                        categoryId: categoryId,
                        label: CategoryDisplay.name(l10n, categoryId),
                        isSelected: categoryId == _categoryId,
                        onTap: () => setState(() {
                          _categoryId = categoryId;
                          _isCategoryPickedByUser = true;
                          _showCategoryError = false;
                        }),
                      ))
                  .toList(),
            ),
            if (_showCategoryError)
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 4),
                child: Text(
                  l10n.validationCategory,
                  style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 16),
            _SectionLabel(text: l10n.txDate),
            const SizedBox(height: 6),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              validator: (_) => Validators.isNotFutureDate(_date) ? null : l10n.validationDateFuture,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.textMuted, size: 20),
                enabledBorder: _filledFields.contains(_dateField) ? _highlightBorder : null,
              ),
            ),
            const SizedBox(height: 16),
            LabeledTextField(
              label: l10n.txDescription,
              icon: Icons.edit_outlined,
              controller: _descriptionController,
              hintText: l10n.txDescriptionHint,
              maxLength: AppDefaults.descriptionMaxLength,
              textInputAction: TextInputAction.done,
              isHighlighted: _filledFields.contains(_descriptionField),
              onChanged: _onDescriptionChanged,
            ),
            const SizedBox(height: 8),
            _SectionLabel(text: l10n.txPaymentMode),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PaymentModes.values.map((mode) {
                final bool isSelected = mode == _paymentMode;
                return ChoiceChip(
                  label: Text(PaymentModeDisplay.name(l10n, mode)),
                  selected: isSelected,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  onSelected: (_) => setState(() => _paymentMode = mode),
                );
              }).toList(),
            ),
            if (!_isEditing) ...[
              const SizedBox(height: 16),
              _buildRecurringSwitch(l10n),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _buildBottomButtons(l10n),
        ),
      ),
    );
  }

  static final OutlineInputBorder _highlightBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: AppColors.honey, width: 2),
  );

  Widget _buildAmountCard(AppLocalizations l10n) {
    final Color amountColor = _isIncome ? AppColors.income : AppColors.expense;
    final bool isAmountFilled = _filledFields.contains(_amountField);
    final bool isAmountMissing = _scanNotice == ScanNoticeType.noAmount;
    final bool isHighlighted = isAmountFilled || isAmountMissing;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: isHighlighted ? AppColors.honey : AppColors.border, width: isHighlighted ? 2 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          children: [
            Text(l10n.txAmount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsInputFormatter()],
              textAlign: TextAlign.center,
              validator: (value) => _validateAmount(value, l10n),
              style: TextStyle(fontFamily: AppFonts.heading, fontSize: 38, fontWeight: FontWeight.w800, color: amountColor),
              decoration: InputDecoration(
                hintText: isAmountMissing ? l10n.scanEnterAmount : '0',
                hintStyle: const TextStyle(fontFamily: AppFonts.heading, fontSize: 38, fontWeight: FontWeight.w800, color: AppColors.border),
                prefixText: Formatters.isUsd ? '\$ ' : null,
                prefixStyle: TextStyle(fontFamily: AppFonts.heading, fontSize: 30, fontWeight: FontWeight.w800, color: amountColor),
                suffixText: Formatters.isUsd ? null : '₫',
                suffixStyle: TextStyle(fontFamily: AppFonts.heading, fontSize: 30, fontWeight: FontWeight.w800, color: amountColor),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                errorStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            if (isAmountFilled) _AmountHint(icon: Icons.auto_awesome, text: l10n.scanFilledFromReceipt),
            if (isAmountMissing) _AmountHint(icon: Icons.warning_amber_rounded, text: l10n.scanNoAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringSwitch(AppLocalizations l10n) {
    String hint = l10n.recurringSwitchHint(_date.day);
    if (_date.day > 28) hint = '$hint ${l10n.recurringMonthEndNote}';

    return Card(
      child: SwitchListTile(
        value: _isRecurring,
        onChanged: (value) => setState(() => _isRecurring = value),
        secondary: const Icon(Icons.event_repeat, color: AppColors.primary),
        title: Text(l10n.recurringSwitch, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(hint),
      ),
    );
  }

  Widget _buildBottomButtons(AppLocalizations l10n) {
    if (_isEditing) {
      return Row(
        children: [
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.expenseSoft,
              foregroundColor: AppColors.expense,
              minimumSize: const Size(54, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            tooltip: l10n.commonDelete,
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
          ),
          const SizedBox(width: 12),
          Expanded(child: FilledButton(onPressed: _save, child: Text(l10n.txSaveChanges))),
        ],
      );
    }

    if (_isIncome) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: AppColors.mint, foregroundColor: AppColors.textPrimary),
        onPressed: _save,
        icon: const Icon(Icons.check),
        label: Text(l10n.txSaveIncome),
      );
    }

    if (!_canScan) return FilledButton(onPressed: _save, child: Text(l10n.txSaveExpense));

    final bool hasScanned = _receiptPath != null || _scanNotice != ScanNoticeType.none;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border, width: 1.5)),
            onPressed: _startScan,
            icon: const Icon(Icons.photo_camera_outlined),
            label: FittedBox(fit: BoxFit.scaleDown, child: Text(hasScanned ? l10n.scanAgain : l10n.txScanReceipt)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: FilledButton(onPressed: _save, child: Text(l10n.txSaveExpense))),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final String? hint;
  final String? actionText;
  final VoidCallback? onAction;

  const _SectionLabel({required this.text, this.hint, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: text),
                  if (hint != null)
                    TextSpan(text: ' · $hint', style: const TextStyle(color: AppColors.honeyText, fontWeight: FontWeight.w700)),
                ],
              ),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ),
        ),
        if (actionText != null) TextButton(onPressed: onAction, child: Text(actionText!)),
      ],
    );
  }
}

class _CategoryOption extends StatelessWidget {
  final String categoryId;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryOption({required this.categoryId, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isSelected ? AppColors.textPrimary : Colors.transparent, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CategoryIcon(
                iconName: CategoryDisplay.iconName(categoryId),
                color: CategoryDisplay.color(categoryId),
                backgroundColor: CategoryDisplay.softColor(categoryId),
                size: 46,
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label, maxLines: 1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountHint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AmountHint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppColors.honeyText),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.honeyText)),
        ],
      ),
    );
  }
}
