class SuttaItem {
  int? suttaItemId;
  int bookId;
  int? bookSectionId;
  String name;
  String? namePL;
  String? description;
  String? comment;
  int startItemNumber;
  int endItemNumber;
  String? link;

  int? startItemNumberPL;
  int? endItemNumberPL;
  int? startItemSubnumberPL;
  int? endItemSubnumberPL;

  SuttaItem({
    this.suttaItemId,
    required this.bookId,
    this.name = "",
    this.bookSectionId,
    this.namePL,
    this.description,
    this.comment,
    this.link = "",
    required this.startItemNumber,
    required this.endItemNumber,
    this.startItemNumberPL,
    this.endItemNumberPL,
    this.startItemSubnumberPL,
    this.endItemSubnumberPL,
  });
}
