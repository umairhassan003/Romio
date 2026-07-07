import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Shows [text] clamped to [trimLines] lines with a "See more" toggle. Once
/// expanded, shows the full text with a "See less" toggle. The toggle only
/// appears when the text actually exceeds [trimLines] lines.
class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;
  final TextStyle? style;
  final String moreLabel;
  final String lessLabel;

  const ExpandableText(
    this.text, {
    super.key,
    this.trimLines = 3,
    this.style,
    this.moreLabel = 'Ver más',
    this.lessLabel = 'Ver menos',
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? AppTextStyles.bodyM.copyWith(height: 1.5);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tp = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: widget.trimLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: style,
              textAlign: TextAlign.justify,
              maxLines: _expanded ? null : widget.trimLines,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (overflows)
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _expanded ? widget.lessLabel : widget.moreLabel,
                    style: AppTextStyles.labelM.copyWith(color: AppColors.primaryBurgundy),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
