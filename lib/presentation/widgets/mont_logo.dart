import 'package:flutter/material.dart';

/// 몬트(Mont) 로고 위젯
/// 앱 내에서 사용하는 브랜드 로고
class MontLogo extends StatelessWidget {
  final double height;
  final bool showText;

  const MontLogo({
    super.key,
    this.height = 40,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);

    if (showText) {
      // 로고 + 텍스트 조합
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MountainIcon(height: height),
          SizedBox(width: height * 0.3),
          Text(
            'Mont',
            style: TextStyle(
              fontSize: height * 0.7,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: -1,
              height: 1.0,
            ),
          ),
        ],
      );
    } else {
      // 아이콘만
      return _MountainIcon(height: height);
    }
  }
}

/// M자 산 모양 아이콘
class _MountainIcon extends StatelessWidget {
  final double height;

  const _MountainIcon({required this.height});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(height, height),
      painter: _MountainPainter(),
    );
  }
}

/// 산 모양 페인터
class _MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF14B8A6) // Teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final centerY = size.height * 0.6;
    final peakY = size.height * 0.25;

    // 왼쪽 산
    path.moveTo(size.width * 0.15, centerY); // 시작점
    path.lineTo(size.width * 0.15, peakY + size.height * 0.1); // 왼쪽 상단
    path.lineTo(size.width * 0.35, centerY - size.height * 0.1); // 중간 계곡
    path.lineTo(size.width * 0.5, peakY); // 중앙 봉우리

    // 오른쪽 산
    path.lineTo(size.width * 0.65, centerY - size.height * 0.1); // 중간 계곡
    path.lineTo(size.width * 0.85, peakY + size.height * 0.1); // 오른쪽 상단
    path.lineTo(size.width * 0.85, centerY); // 끝점

    canvas.drawPath(path, paint);

    // 중앙 포인트 (목표 지점)
    final pointPaint = Paint()
      ..color = const Color(0xFF14B8A6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.5, peakY),
      size.width * 0.08,
      pointPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 심플한 M 아이콘 (대안)
class MontIconSimple extends StatelessWidget {
  final double size;
  final Color? color;

  const MontIconSimple({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? const Color(0xFF14B8A6);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            iconColor,
            iconColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Center(
        child: Text(
          'M',
          style: TextStyle(
            fontSize: size * 0.55,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
