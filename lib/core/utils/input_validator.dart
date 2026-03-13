class InputValidator {
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter an amount';
    final amount = double.tryParse(value.trim());
    if (amount == null) return 'Please enter a valid number';
    if (amount < 0) return 'Amount cannot be negative';
    if (amount > 999999999) return 'Amount is too large';
    return null;
  }

  static bool isValidAmount(String value) {
    if (value.trim().isEmpty) return false;
    final amount = double.tryParse(value.trim());
    return amount != null && amount >= 0;
  }
}
