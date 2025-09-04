class NumberFormatter {
  /// 숫자에 천 단위 컴마 추가
  static String formatNumber(num number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// 정수에 천 단위 컴마 추가
  static String formatInt(int number) {
    return formatNumber(number);
  }

  /// 더블에 천 단위 컴마 추가 (소수점 2자리까지)
  static String formatDouble(double number, {int decimals = 0}) {
    if (decimals == 0) {
      return formatNumber(number.round());
    }
    return formatNumber(double.parse(number.toStringAsFixed(decimals)));
  }

  /// 포인트 표시용 (포인트 단위 포함)
  static String formatPoints(int points) {
    return '${formatInt(points)} 포인트';
  }

  /// 원화 표시용 (원 단위 포함, 소수점 제거)
  static String formatWon(num amount) {
    return '${formatNumber(amount.round())}원';
  }
}