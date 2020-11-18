import 'package:flutter/material.dart';
import 'package:swaptime_flutter/generated/l10n.dart';

class ChatBubbleWidget extends StatefulWidget {
  final bool showImage;
  final String message;
  final String sentDate;
  final bool me;

  ChatBubbleWidget({
    Key key,
    this.message,
    this.sentDate,
    this.me,
    this.showImage,
  });

  @override
  State<StatefulWidget> createState() => ChatBubbleWidgetState();
}

class ChatBubbleWidgetState extends State<ChatBubbleWidget> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: widget.me ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
          width: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: Border.all(),
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateTime.parse(widget.sentDate)
                            .difference(DateTime.now())
                            .inHours <
                        24
                    ? DateTime.parse(widget.sentDate)
                        .toString()
                        .substring(10, 15)
                    : DateTime.parse(widget.sentDate)
                            .difference(DateTime.now())
                            .inHours
                            .toString() +
                        S.of(context).minutesAgo),
                Text(
                  '${widget.message}',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
