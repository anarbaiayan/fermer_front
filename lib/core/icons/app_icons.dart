import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  static SvgPicture svg(
    String path, {
    double size = 24,
    dynamic color,
  }) {
    return SvgPicture.asset(
      'assets/icons/$path.svg',
      width: size,
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  // удобные геттеры
  static SvgPicture get home => svg('home');
  static SvgPicture get cow => svg('cow');
  static SvgPicture get cowBottom => svg('cow-bottom');
  static SvgPicture get events => svg('events');
  static SvgPicture get checklist => svg('checklist');
  static SvgPicture get user => svg('user');
  static SvgPicture get menu => svg('menu');
  static SvgPicture get bell => svg('bell');
  static SvgPicture get arrow => svg('arrow');
  static SvgPicture get search2 => svg('search2');
  static SvgPicture get search => svg('search');
  static SvgPicture get dots => svg('dots');
  static SvgPicture get refresh => svg('refresh');

  // 🔹 отдельный геттер для divider, у него нестандартные размеры
  static Widget divider({double width = 80}) {
    return SvgPicture.asset(
      'assets/icons/divider.svg',
      width: width,
      fit: BoxFit.contain,
    );
  }
}
