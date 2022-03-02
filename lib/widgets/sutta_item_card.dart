import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sutta/models/book.dart';
import 'package:sutta/models/sutta_item.dart';

class SuttaItemCard extends StatefulWidget {
  final Book book;
  final SuttaItem suttaItem;

  final void Function(int?)? onSuttaTap;

  const SuttaItemCard({Key? key, required this.book, required this.suttaItem, this.onSuttaTap}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SuttaItemCardState();
  }
}

class SuttaItemCardState extends State<SuttaItemCard> {
  Color _cardColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      Text(
        widget.book.name,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(widget.suttaItem.name),
    ];

    if (widget.suttaItem.startItemNumber != widget.suttaItem.endItemNumber) {
      children.add(Text("${widget.suttaItem.startItemNumber} - ${widget.suttaItem.endItemNumber}"));
    } else {
      children.add(Text("${widget.suttaItem.startItemNumber}"));
    }

    return MouseRegion(
      onEnter: (ev) {
        setState(() {
          _cardColor = Colors.yellow.shade100;
        });
      },
      onExit: (ev) {
        setState(() {
          _cardColor = Colors.white;
        });
      },
      child: GestureDetector(
        onTap: () {
          if (widget.onSuttaTap != null) {
            widget.onSuttaTap!(widget.suttaItem.suttaItemId);
          }
        },
        child: Card(
          color: _cardColor,
          child: Column(
            children: children,
          ),
        ),
      ),
      cursor: SystemMouseCursors.click,
    );
  }
}
