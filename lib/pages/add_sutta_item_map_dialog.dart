import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sutta/models/book.dart';
import 'package:sutta/models/sutta_item.dart';
import 'package:sutta/repositories/book_repository.dart';
import 'package:sutta/repositories/sutta_item_repository.dart';
import 'package:sutta/widgets/sutta_item_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/validators.dart';

import 'add_sutta_item_dialog.dart';

class AddSuttaItemMapDialog extends StatefulWidget {
  final Book book;
  final SuttaItem suttaItem;

  const AddSuttaItemMapDialog({Key? key, required this.book, required this.suttaItem}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddSuttaItemMapDialogState();
  }
}

class BookSuttaItemsViewModel {
  Book book;
  List<SuttaItem> suttaItems;

  BookSuttaItemsViewModel({required this.book, required this.suttaItems});
}

class AddSuttaItemMapDialogState extends State<AddSuttaItemMapDialog> {
  final _formKey = GlobalKey<FormState>();

  int _selectedBookId = -1;
  int _item = 0;

  final _bookTextEditingController = TextEditingController();
  final _suggestionsBoxController = SuggestionsBoxController();

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      Text(
        widget.book.name.toString(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(widget.suttaItem.name),
      Text(widget.suttaItem.namePL ?? "-"),
      Text(widget.suttaItem.startItemNumber == widget.suttaItem.endItemNumber
          ? widget.suttaItem.startItemNumber.toString()
          : "${widget.suttaItem.startItemNumber} - ${widget.suttaItem.endItemNumber}"),
    ];

    if (widget.suttaItem.link != "") {
      children.add(TextButton(
        onPressed: () {
          launch(widget.suttaItem.link!);
        },
        child: Text(widget.suttaItem.link ?? ""),
      ));
    }

    children.addAll([
      ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500),
        child: TypeAheadField<Book>(
          suggestionsCallback: (val) {
            return BookRepository().getBooks();
          },
          itemBuilder: (context, item) {
            return Text("${item.ordering}. ${item.name}");
          },
          onSuggestionSelected: (book) {
            _bookTextEditingController.text = "${book.ordering}. ${book.name}";
            setState(() {
              _selectedBookId = book.bookId;
            });
          },
          suggestionsBoxController: _suggestionsBoxController,
          textFieldConfiguration: TextFieldConfiguration(
            controller: _bookTextEditingController,
            decoration: const InputDecoration(labelText: "เล่ม"),
          ),
        ),
      ),
      ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 300),
        child: SpinBox(
          value: 0,
          decoration: InputDecoration(labelText: 'ข้อ'),
          onChanged: (val) {
            setState(() {
              _item = val == null ? 0 : val.toInt();
            });
          },
          keyboardType: TextInputType.number,
        ),
      ),
      Expanded(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height / 2,
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: _selectedBookId == -1
                ? Text("โปรด")
                : FutureBuilder<BookSuttaItemsViewModel>(
                    future: Future.sync(() async {
                      var items = SuttaItemRepository().getSuttaItemsBySearch(_selectedBookId, _item);
                      var book = BookRepository().getBook(_selectedBookId);

                      return BookSuttaItemsViewModel(book: await book, suttaItems: (await items).toList(growable: false));
                    }),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var data = snapshot.data!;
                        return Stack(
                          children: [
                            GridView.builder(
                              padding: EdgeInsets.only(top: 20, bottom: 10),
                              itemCount: data.suttaItems.length,
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                mainAxisExtent: 120,
                              ),
                              itemBuilder: (context, index) {
                                var sutta = data.suttaItems[index];

                                return SuttaItemCard(
                                  book: data.book,
                                  suttaItem: sutta,
                                  onSuttaTap: (suttaItemId) {
                                    print(suttaItemId);
                                  },
                                );
                              },
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: ElevatedButton(
                                onPressed: () {
                                  var dialog = showDialog(
                                      context: context,
                                      builder: (dialogContext) {
                                        return AlertDialog(
                                          content: AddSuttaItemDialog(book: data.book),
                                        );
                                      });

                                  dialog.then((value) {
                                    print(value);

                                    setState(() {});
                                  });
                                },
                                child: Text("เพิ่ม"),
                              ),
                            )
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      } else {
                        return Text("Loading");
                      }
                    },
                  ),
          ),
        ),
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            //   var item = SuttaItem(
            //     bookId: widget.book.bookId,
            //     endItemNumber: _endItemNumber == null ? _startItemNumber! : _endItemNumber!,
            //     startItemNumber: _startItemNumber!,
            //     link: _url ?? "",
            //     name: _name!,
            //     namePL: _namePL,
            //     startItemNumberPL: _startItemNumberPL,
            //     startItemSubnumberPL: _startItemSubNumberPL,
            //     endItemNumberPL: _endItemNumberPL ?? _startItemNumberPL,
            //     endItemSubnumberPL: _endItemNumberPL == null ? _startItemSubNumberPL : _endItemSubNumberPL,
            //   );
            //
            //   SuttaItemRepository().insert(item).then((id) {
            //     item.suttaItemId = id;
            //
            //     Navigator.of(context).pop(item);
            //   });
          }
        },
        child: const Text("เพิ่ม"),
      )
    ]);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }
}
