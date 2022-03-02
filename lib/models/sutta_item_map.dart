class SuttaItemMap {
  int? suttaItemMapId;
  int suttaItemId;
  int? suttaItemRefId;
  String? customReference;
  int ordering;

  SuttaItemMap({this.suttaItemMapId, required this.suttaItemId, this.suttaItemRefId, this.customReference, this.ordering = 100});
}
