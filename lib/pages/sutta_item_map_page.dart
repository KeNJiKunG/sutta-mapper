import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:sutta/models/book.dart';
import 'package:sutta/models/sutta_item.dart';
import 'package:sutta/pages/add_sutta_item_map_dialog.dart';
import 'package:sutta/repositories/book_repository.dart';
import 'package:sutta/repositories/sutta_item_map_repository.dart';
import 'package:sutta/repositories/sutta_item_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class SuttaItemMapPage extends StatefulWidget {
  final int? suttaItemId;

  const SuttaItemMapPage({Key? key, this.suttaItemId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SuttaItemMapPageState();
  }
}

class SuttaItemBookViewModel {
  Book book;
  SuttaItem suttaItem;

  SuttaItemBookViewModel({required this.book, required this.suttaItem});
}

class SuttaItemViewModel {
  String? bookName;
  String? suttaName;

  int? startItemNumber;
  int? endItemNumber;

  String? customText;

  bool isCustomReference;

  SuttaItemViewModel.suttaItem({
    required this.bookName,
    required this.suttaName,
    required this.startItemNumber,
    required this.endItemNumber,
    this.customText,
  }) : this.isCustomReference = false;

  SuttaItemViewModel.customText({required this.customText}) : this.isCustomReference = true;
}

class SuttaItemMapPageState extends State<SuttaItemMapPage> {
  Future<Iterable<SuttaItemViewModel>> _suttaWidgetReferenceFuture() async {
    var references = await SuttaItemMapRepository().getSuttaItemMapsBySuttaItemId(widget.suttaItemId!);

    return Future.wait(references.map((r) async {
      if (r.suttaItemRefId != null) {
        var suttaItem = await SuttaItemRepository().getSuttaItem(r.suttaItemRefId!);
        var book = await BookRepository().getBook(suttaItem.bookId);

        return SuttaItemViewModel.suttaItem(
          bookName: book.name,
          suttaName: suttaItem.name,
          customText: r.customReference,
          startItemNumber: suttaItem.startItemNumber,
          endItemNumber: suttaItem.endItemNumber,
        );
      } else {
        return SuttaItemViewModel.customText(customText: r.customReference);
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.suttaItemId == null) {
      return Text("โปรด");
    }

    return FutureBuilder<SuttaItemBookViewModel>(
      future: Future.sync(() async {
        var item = await SuttaItemRepository().getSuttaItem(widget.suttaItemId!);
        var book = await BookRepository().getBook(item.bookId);

        return SuttaItemBookViewModel(book: book, suttaItem: item);
      }),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text("Loading");
        }

        var children = <Widget>[
          Text(
            snapshot.data!.book.name.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(snapshot.data!.suttaItem.name),
          Text(snapshot.data!.suttaItem.namePL ?? "-"),
          Text(snapshot.data!.suttaItem.startItemNumber == snapshot.data!.suttaItem.endItemNumber
              ? snapshot.data!.suttaItem.startItemNumber.toString()
              : "${snapshot.data!.suttaItem.startItemNumber} - ${snapshot.data!.suttaItem.endItemNumber}"),
        ];

        if (snapshot.data!.suttaItem.link != "") {
          children.add(TextButton(
            onPressed: () {
              launch(snapshot.data!.suttaItem.link!);
            },
            child: Text(snapshot.data!.suttaItem.link ?? ""),
          ));
        }

        children.add(
          Expanded(
            child: FutureBuilder<Iterable<SuttaItemViewModel>>(
              initialData: null,
              future: _suttaWidgetReferenceFuture(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    padding: EdgeInsets.only(bottom: 50),
                    children: snapshot.data!.map((m) {
                      var content = m.isCustomReference
                          ? MarkdownBody(
                              data: m.customText!,
                              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                                textAlign: WrapAlignment.center,
                              ),
                            )
                          : Column(
                              children: [
                                Text(
                                  "${m.bookName}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("${m.suttaName}"),
                                Text(
                                    m.startItemNumber == m.endItemNumber ? m.startItemNumber.toString() : "${m.startItemNumber} - ${m.endItemNumber}")
                              ],
                            );
                      return Card(
                        child: content,
                      );
                    }).toList(),
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }

                return const Text("khjuiernkj");
              },
            ),
          ),
        );

        return Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: children,
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: ElevatedButton(
                onPressed: () {
                  var dialog = showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: AddSuttaItemMapDialog(book: snapshot.data!.book, suttaItem: snapshot.data!.suttaItem),
                        );
                      });

                  dialog.then((val) {
                    setState(() {});
                  });
                },
                child: const Text("เพิ่ม"),
              ),
            )
          ],
        );
      },
    );
  }
}
