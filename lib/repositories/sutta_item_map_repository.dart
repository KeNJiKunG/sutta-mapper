import 'package:sutta/models/book.dart';
import 'package:sutta/models/sutta_item.dart';
import 'package:sutta/models/sutta_item_map.dart';
import 'package:sutta/repositories/repository.dart';

class SuttaItemMapRepository extends Repository {
  SuttaItemMapRepository() : super("SuttaItemMaps");

  Future<Iterable<SuttaItemMap>> getSuttaItemMapsBySuttaItemId(int suttaItemId) async {
    var connection = await getConnection();

    var bookItems = connection.select(
      """
    SELECT suttaItemMapId, suttaItemId, suttaItemRefId, customReference, ordering
    FROM SuttaItemMaps
    WHERE suttaItemId = ?
    ORDER BY ordering""",
      [suttaItemId],
    );

    return _parseSuttaItemMaps(bookItems);
  }

  static Iterable<SuttaItemMap> _parseSuttaItemMaps(Iterable<Map<String, Object?>> suttaItemMaps) {
    return suttaItemMaps.map((m) => _parseSuttaItemMap(m));
  }

  static SuttaItemMap _parseSuttaItemMap(Map<String, Object?> suttaItemMap) {
    return SuttaItemMap(
      suttaItemMapId: suttaItemMap["suttaItemMapId"] as int,
      suttaItemId: suttaItemMap["suttaItemId"] as int,
      suttaItemRefId: suttaItemMap["suttaItemRefId"] as int?,
      customReference: suttaItemMap["customReference"] as String?,
      ordering:  suttaItemMap["ordering"] as int,
    );
  }
}
