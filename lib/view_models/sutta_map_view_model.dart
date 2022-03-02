import 'package:sutta/models/book.dart';
import 'package:sutta/models/sutta_item.dart';

class SuttaBookMap {
  final Book book;
  final Iterable<SuttaItem> maps;

  SuttaBookMap(this.book, this.maps);
}
