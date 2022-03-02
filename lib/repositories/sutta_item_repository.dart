import 'package:sutta/models/book.dart';
import 'package:sutta/models/sutta_item.dart';
import 'package:sutta/repositories/repository.dart';

class SuttaItemRepository extends Repository {
  SuttaItemRepository() : super("SuttaItems");

  Future<Iterable<SuttaItem>> getSuttaItemsBySearch(int bookId, int itemNumber) async {
    var connection = await getConnection();

    if (itemNumber == 0) {
      var bookItems = connection.select(
        """
    SELECT
      suttaItemId, bookId, name, namePL, description, comment, startItemNumber, endItemNumber, bookSectionId,
      link
    FROM SuttaItems
    WHERE bookId = ?
    ORDER BY startItemNumber""",
        [bookId],
      );

      return _parseSuttaItems(bookItems);
    } else {
      var bookItems = connection.select(
        """
    SELECT
      suttaItemId, bookId, name, namePL, description, comment, startItemNumber, endItemNumber, bookSectionId,
      link
    FROM SuttaItems
    WHERE bookId = ? AND startItemNumber <= ? AND endItemNumber >= ?
    ORDER BY startItemNumber""",
        [bookId, itemNumber, itemNumber],
      );

      return _parseSuttaItems(bookItems);
    }
  }

  Future<SuttaItem> getSuttaItem(int suttaItemId) async {
    var connection = await getConnection();

    var books = connection.select("""
    SELECT
      suttaItemId, bookId, name, namePL, description, comment, startItemNumber, endItemNumber, bookSectionId,
      link
    FROM SuttaItems
    WHERE suttaItemId = ?""", [suttaItemId]);

    return _parseSuttaItems(books).first;
  }

  Future<int> insert(SuttaItem item) async {
    if (item.suttaItemId != null) {
      return item.suttaItemId!;
    }

    var connection = await getConnection();

    connection.execute("""
    INSERT INTO SuttaItems (
      bookId, name, namePL, description, comment, startItemNumber, endItemNumber,
      bookSectionId, link, startItemNumberPL, endItemNumberPL, startItemNumberPL, endItemNumberPL 
    ) VALUES (
      ?, ?, ?, ?, ?, ?, ?,
      ?, ?, ?, ?, ?, ?
    )
    """, [
      item.bookId,
      item.name,
      item.namePL,
      item.description,
      item.comment,
      item.startItemNumber,
      item.endItemNumber,
      item.bookSectionId,
      item.link,
      item.startItemNumberPL,
      item.endItemNumberPL,
      item.startItemSubnumberPL,
      item.endItemSubnumberPL,
    ]);

    return getLastSeq(connection);
  }

  static Iterable<SuttaItem> _parseSuttaItems(Iterable<Map<String, Object?>> books) {
    return books.map((b) => _parseSuttaItem(b));
  }

  static SuttaItem _parseSuttaItem(Map<String, Object?> suttaItem) {
    return SuttaItem(
      suttaItemId: suttaItem["suttaItemId"] as int,
      bookId: suttaItem["bookId"] as int,
      name: suttaItem["name"] as String,
      namePL: suttaItem["namePL"] as String?,
      description: suttaItem["description"] as String?,
      startItemNumber: suttaItem["startItemNumber"] as int,
      endItemNumber: suttaItem["endItemNumber"] as int,
      link: suttaItem["link"] as String?,
    );
  }
}
