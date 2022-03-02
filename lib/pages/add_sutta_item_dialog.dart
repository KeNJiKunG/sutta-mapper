import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sutta/models/book.dart';
import 'package:sutta/models/sutta_item.dart';
import 'package:sutta/repositories/sutta_item_repository.dart';
import 'package:validators/validators.dart';

class AddSuttaItemDialog extends StatefulWidget {
  final Book book;

  const AddSuttaItemDialog({Key? key, required this.book}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddSuttaItemDialogState();
  }
}

class AddSuttaItemDialogState extends State<AddSuttaItemDialog> {
  String? _name;
  String? _namePL;
  int? _startItemNumber;
  int? _endItemNumber;

  int? _startItemNumberPL;
  int? _endItemNumberPL;
  int? _startItemSubNumberPL;
  int? _endItemSubNumberPL;
  String? _url;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Text(widget.book.name),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: "ชื่อพระสูตร (ไทย)",
                ),
                validator: (val) {
                  if (val == null || val == "") {
                    return "โปรด";
                  }

                  _name = val;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "ชื่อพระสูตร (บาลี)",
                ),
                validator: (val) {
                  if (val == null || val == "") {
                    _namePL = null;
                  } else {
                    _namePL = val;
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "เลขข้อ",
                ),
                validator: (val) {
                  if (val == null) {
                    return "โปรด";
                  }

                  var match = RegExp(r'^(\d+)(-(\d+))?$').firstMatch(val);

                  if (match == null) {
                    return "โปรด \\d+-\\d+";
                  }

                  var start = int.parse(match.group(1)!);
                  var end = match.group(3) == null ? null : int.parse(match.group(3)!);

                  if (end != null && start > end) {
                    return "โปรด <";
                  }

                  _startItemNumber = start;
                  _endItemNumber = end;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "เลขข้อบาลี",
                ),
                validator: (val) {
                  if (val == null) {
                    return "โปรด";
                  }

                  var match = RegExp(r"^(\d+)(\.(\d+))?(-(\d+)(\.(\d+))?)?$").firstMatch(val);

                  if (match == null) {
                    return "โปรด \\d+.\\d+-\\d+.\\d+";
                  }

                  var start = int.parse(match.group(1)!);
                  var startSub = match.group(3) == null ? null : int.parse(match.group(3)!);
                  var end = match.group(5) == null ? null : int.parse(match.group(5)!);
                  var endSub = match.group(7) == null ? null : int.parse(match.group(7)!);

                  _startItemNumberPL = start;
                  _startItemSubNumberPL = startSub;
                  _endItemNumberPL = end;
                  _endItemSubNumberPL = endSub;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "ลิงค์",
                ),
                validator: (val) {
                  if (val == null || val == "") {
                    return null;
                  }

                  if (!isURL(val)) {
                    return "โปรด ลิงต์";
                  }

                  _url = val;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    var item = SuttaItem(
                      bookId: widget.book.bookId,
                      endItemNumber: _endItemNumber == null ? _startItemNumber! : _endItemNumber!,
                      startItemNumber: _startItemNumber!,
                      link: _url ?? "",
                      name: _name!,
                      namePL: _namePL,
                      startItemNumberPL: _startItemNumberPL,
                      startItemSubnumberPL: _startItemSubNumberPL,
                      endItemNumberPL: _endItemNumberPL ?? _startItemNumberPL,
                      endItemSubnumberPL: _endItemNumberPL == null ? _startItemSubNumberPL : _endItemSubNumberPL,
                    );

                    SuttaItemRepository().insert(item).then((id) {
                      item.suttaItemId = id;

                      Navigator.of(context).pop(item);
                    });
                  }
                },
                child: const Text("เพิ่ม"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
