import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hashpro/views/components/rich_text/base_text.dart';
import 'package:hashpro/views/components/rich_text/link_text.dart';

class RichTextWidget extends StatelessWidget {
  final TextStyle? styleForAll;
  final Iterable<BaseText> texts;

  const RichTextWidget({
    super.key,
    required this.texts,
    this.styleForAll,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: texts.map(
          (currBaseText) {
            if (currBaseText is LinkText) {
              return TextSpan(
                text: currBaseText.text,
                style: styleForAll?.merge(currBaseText.style),
                recognizer: TapGestureRecognizer()
                  ..onTap = currBaseText.onTapped,
              );
            } else {
              return TextSpan(
                text: currBaseText.text,
                style: styleForAll?.merge(currBaseText.style),
              );
            }
          },
        ).toList(),
      ),
    );
  }
}
