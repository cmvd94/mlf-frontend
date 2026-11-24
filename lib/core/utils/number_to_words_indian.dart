/// Utility to convert numbers into Indian numbering system words (Lakh, Crore, Thousand, Hundred)
class NumberToWordsIndian {
  static const List<String> _units = [
    '',
    'ONE',
    'TWO',
    'THREE',
    'FOUR',
    'FIVE',
    'SIX',
    'SEVEN',
    'EIGHT',
    'NINE',
    'TEN',
    'ELEVEN',
    'TWELVE',
    'THIRTEEN',
    'FOURTEEN',
    'FIFTEEN',
    'SIXTEEN',
    'SEVENTEEN',
    'EIGHTEEN',
    'NINETEEN'
  ];

  static const List<String> _tens = [
    '',
    '',
    'TWENTY',
    'THIRTY',
    'FORTY',
    'FIFTY',
    'SIXTY',
    'SEVENTY',
    'EIGHTY',
    'NINETY'
  ];

  static String convert(double amount) {
    if (amount == 0) return 'ZERO ONLY';

    final intPart = amount.floor();
    final paisePart = ((amount - intPart) * 100).round();

    String words = _convertInteger(intPart);
    if (words.isEmpty) words = 'ZERO';

    if (paisePart > 0) {
      final paiseWords = _convertInteger(paisePart);
      return '$words AND $paiseWords PAISE ONLY';
    }

    return '$words ONLY';
  }

  static String _convertInteger(int n) {
    if (n == 0) return '';
    if (n < 20) return _units[n];
    if (n < 100) {
      final rem = n % 10;
      return '${_tens[n ~/ 10]}${rem > 0 ? " ${_units[rem]}" : ""}';
    }
    if (n < 1000) {
      final rem = n % 100;
      return '${_units[n ~/ 100]} HUNDRED${rem > 0 ? " ${_convertInteger(rem)}" : ""}';
    }
    if (n < 100000) {
      final rem = n % 1000;
      return '${_convertInteger(n ~/ 1000)} THOUSAND${rem > 0 ? " ${_convertInteger(rem)}" : ""}';
    }
    if (n < 10000000) {
      final rem = n % 100000;
      return '${_convertInteger(n ~/ 100000)} LAKH${rem > 0 ? " ${_convertInteger(rem)}" : ""}';
    }
    final rem = n % 10000000;
    return '${_convertInteger(n ~/ 10000000)} CRORE${rem > 0 ? " ${_convertInteger(rem)}" : ""}';
  }
}
