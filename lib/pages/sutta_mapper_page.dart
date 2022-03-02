import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sutta/models/book.dart';
import 'package:sutta/models/sutta_map.dart';
import 'package:sutta/pages/sutta_item_map_page.dart';
import 'package:sutta/repositories/book_repository.dart';
import 'package:sutta/repositories/sutta_item_repository.dart';
import 'package:sutta/view_models/sutta_map_view_model.dart';
import 'package:sutta/widgets/sutta_item_card.dart';

import 'add_sutta_item_dialog.dart';

class SuttaMapperPage extends StatefulWidget {
  const SuttaMapperPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SuttaMapperPageState();
  }
}

class SuttaMapperPageState extends State<SuttaMapperPage> {
  int _selectedBookId = -1;
  int _item = 0;
  int? _suttaItemId;

  final _bookTextEditingController = TextEditingController();
  final _suggestionsBoxController = SuggestionsBoxController();

  Timer? _itemTimer;

  //final _bookItemTextEditingController = TextEditingController();

  List<SuttaMap> _suttaMap = [];

  @override
  void dispose() {
    _bookTextEditingController.dispose();
    _itemTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.book_outlined),
        title: Text("Sutta Mapper"),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_drop_down_circle),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Text("เล่ม"),
                  ConstrainedBox(
                    key: const ValueKey("SuttaMapperPage::BookSelector"),
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
                    key: const ValueKey("SuttaMapperPage::BookItemSelector"),
                    constraints: const BoxConstraints(maxWidth: 300, minWidth: 100),
                    child: SpinBox(
                      value: 0,
                      max: double.infinity,
                      decoration: InputDecoration(labelText: 'ข้อ'),
                      onChanged: (val) {
                        _itemTimer?.cancel();

                        _itemTimer = Timer(Duration(milliseconds: 200), () {
                          setState(() {
                            _item = val == null ? 0 : val.toInt();
                          });
                        });
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 10,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text("เพิ่ม"),
                ),
              )
            ],
          ),
          Divider(),
          Expanded(
            flex: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 3),
                  child: Expanded(
                    flex: 1,
                    child: Stack(
                      children: [
                        _item != null
                            ? FutureBuilder(
                                key: const ValueKey("SuttaMapperPage::MapperFutureBuilder"),
                                future: Future.sync(() async {
                                  var maps = await SuttaItemRepository().getSuttaItemsBySearch(_selectedBookId, _item);
                                  var book = await BookRepository().getBook(_selectedBookId);

                                  return SuttaBookMap(book, maps);
                                }),
                                builder: (BuildContext context, AsyncSnapshot<SuttaBookMap> snapshot) {
                                  if (snapshot.hasData) {
                                    return ListView(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.only(bottom: 50),
                                      children: snapshot.data!.maps.map((m) {
                                        return SuttaItemCard(
                                          book: snapshot.data!.book,
                                          suttaItem: m,
                                          onSuttaTap: (suttaItemId) {
                                            setState(() {
                                              _suttaItemId = suttaItemId;
                                            });
                                          },
                                        );
                                      }).toList(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text("${snapshot.error}");
                                  } else {
                                    return Text("Loading");
                                  }
                                },
                              )
                            : Text("โปรด"),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: FutureBuilder<Book>(
                            future: BookRepository().getBook(_selectedBookId),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ElevatedButton(
                                  onPressed: () {
                                    var dialog = showDialog(
                                        context: context,
                                        builder: (dialogContext) {
                                          return AlertDialog(
                                            content: AddSuttaItemDialog(book: snapshot.data!),
                                          );
                                        });

                                    dialog.then((value) {
                                      print(value);

                                      setState(() {});
                                    });
                                  },
                                  child: Text("เพิ่ม"),
                                );
                              }

                              return Text("Loading");
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SuttaItemMapPage(
                    suttaItemId: _suttaItemId,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
