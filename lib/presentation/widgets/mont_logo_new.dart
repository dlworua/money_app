import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 몬트(Mont) 로고 - 완전 새 디자인
/// AI 절약 코칭 앱의 정체성을 표현
class MontLogo extends StatelessWidget {
  final double size;

  const MontLogo({
    super.key,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _MontLogoPainter(),
    );
  }
}

/// 몬트 로고 페인터 - 동전 + AI 업그레이드 화살표
class _MontLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final teal = const Color(0xFF14B8A6);
    final center = Offset(size.width / 2, size.height / 2);

    // 1. 동전 외곽선 (절약의 상징)
    final coinPaint = Paint()
      ..color = teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08;

    canvas.drawCircle(center, size.width * 0.35, coinPaint);

    // 2. M 글자 (Mont)
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'M',
        style: TextStyle(
          fontSize: size.width * 0.45,
          fontWeight: FontWeight.w900,
          color: teal,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    // 3. 상승 화살표 (AI가 도와주는 성장)
    final arrowPaint = Paint()
      ..color = teal
      ..style = PaintingStyle.fill;

    final arrowPath = Path();
    final arrowSize = size.width * 0.12;
    final arrowX = size.width * 0.75;
    final arrowY = size.height * 0.25;

    // 화살표 머리
    arrowPath.moveTo(arrowX, arrowY);
    arrowPath.lineTo(arrowX - arrowSize * 0.5, arrowY + arrowSize * 0.6);
    arrowPath.lineTo(arrowX + arrowSize * 0.5, arrowY + arrowSize * 0.6);
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 옵션 2: 초미니멀 M 로고
class MontLogoMinimal extends StatelessWidget {
  final double size;

  const MontLogoMinimal({
    super.key,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Center(
        child: Text(
          'M',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 0.95,
          ),
        ),
      ),
    );
  }
}

/// 옵션 3: 산 + 동전 조합 (절약으로 목표 달성) + Mont 텍스트
class MontLogoMountain extends StatelessWidget {
  final double size;
  final bool showText;

  const MontLogoMountain({
    super.key,
    this.size = 44,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);

    if (showText) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _MountainCoinPainter(),
          ),
          SizedBox(width: size * 0.3),
          Text(
            'Mont',
            style: GoogleFonts.outfit(
              fontSize: size * 0.58,
              fontWeight: FontWeight.w500,
              color: textColor,
              letterSpacing: 0.5,
              height: 1.0,
            ),
          ),
        ],
      );
    }

    return CustomPaint(
      size: Size(size, size),
      painter: _MountainCoinPainter(),
    );
  }
}

class _MountainCoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final teal = const Color(0xFF14B8A6);

    // 동전 외곽
    final coinPaint = Paint()
      ..color = teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.36,
      coinPaint,
    );

    // 산 모양 (M자 형태)
    final mountainPaint = Paint()
      ..color = teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final baseY = size.height * 0.65;
    final peakY = size.height * 0.35;

    path.moveTo(size.width * 0.3, baseY);
    path.lineTo(size.width * 0.4, peakY);
    path.lineTo(size.width * 0.5, peakY + size.height * 0.08);
    path.lineTo(size.width * 0.6, peakY);
    path.lineTo(size.width * 0.7, baseY);

    canvas.drawPath(path, mountainPaint);

    // 정상에 점 (목표 지점)
    final dotPaint = Paint()
      ..color = teal
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.5, peakY + size.height * 0.08),
      size.width * 0.05,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
