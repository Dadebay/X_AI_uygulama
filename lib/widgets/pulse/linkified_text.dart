import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:atlas/shared/ad_overlay_screen.dart';
import 'package:atlas/themes/colors.dart';

/// İçindeki http(s) linklerini tıklanabilir yapan metin widget'ı.
/// Bir linke dokunulduğunda reklam ekranı üzerinden dış tarayıcıda açılır.
class LinkifiedText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const LinkifiedText({super.key, required this.text, required this.style});

  static final _urlRegex = RegExp(r'https?://\S+');

  void _openLink(String url) {
    AdOverlayScreen.open(url);
  }

  @override
  Widget build(BuildContext context) {
    final matches = _urlRegex.allMatches(text);
    if (matches.isEmpty) {
      return Text(text, style: style);
    }

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in matches) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      final url = match.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: style.copyWith(color: AppColors.primary, decoration: TextDecoration.underline),
        recognizer: TapGestureRecognizer()..onTap = () => _openLink(url),
      ));
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return RichText(text: TextSpan(style: style, children: spans));
  }
}
